$ = require('jqueryify')

module.exports = class UserStringGetter
  ANONYMOUS : "(anonymous)"
  currentUserID : @ANONYMOUS
  zooniverseCurrentUserChecker : null

  returnAnonymous: =>
    @ANONYMOUS

  constructor: (@zooniverseCurrentUserCheckerFunction) ->
    if zooniverseCurrentUserCheckerFunction instanceof Function
      @zooniverseCurrentUserChecker = zooniverseCurrentUserCheckerFunction
    else
      @zooniverseCurrentUserChecker = @returnAnonymous

  checkZooniverseCurrentUser: =>
    if @zooniverseCurrentUserChecker != null && @zooniverseCurrentUserChecker instanceof Function && @zooniverseCurrentUserChecker() != null
      @currentUserID = @zooniverseCurrentUserChecker()
    else
      @currentUserID = @ANONYMOUS
    return @currentUserID

  getClientOrigin: ->
    eventualIP = new $.Deferred
    $.get('https://api.ipify.org')
    .then (ip) =>
      eventualIP.resolve {ip: ip, address: ip}
    .fail =>
      eventualIP.resolve {ip: '?.?.?.?', address: @ANONYMOUS}
    eventualIP.promise()

  getNiceOriginString: (data) ->
    if data.ip? && data.address?
      if data.ip == '?.?.?.?'
        @ANONYMOUS
      else if data.ip == data.address
        "(#{ data.ip })"
      else
        "(#{ data.address } [#{ data.ip }])"
    else
      @ANONYMOUS

  getUserIDorIPAddress: =>
    eventualUserID = new $.Deferred
    if @zooniverseCurrentUserChecker != null
      checkUserNow = @checkZooniverseCurrentUser()
      if checkUserNow && @currentUserID!=checkUserNow
        # if a current ID is stored, but user's current ID is something different (e.g. anon IP), overwrite previous
        eventualUserID.resolve @currentUserID
      else if @currentUserID? and @currentUserID != @ANONYMOUS
        eventualUserID.resolve @currentUserID
      else
        @getClientOrigin()
        .then (data) =>
          if data?
            @currentUserID = @getNiceOriginString data
        .always =>
          eventualUserID.resolve @currentUserID
    else
      eventualUserID.resolve @ANONYMOUS
    eventualUserID.promise()
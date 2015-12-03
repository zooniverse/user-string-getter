$ = require('jqueryify')

module.exports = class UserStringGetter
  ANONYMOUS : "(anonymous)"
  currentUserID : @ANONYMOUS
  zooniverseCurrentUserChecker : null

  returnAnonymous: =>
    @ANONYMOUS

  constructor: (@zooniverseCurrentUserCheckerFunction) ->
    console.log "in constructor of zoo user string getter"
    if @zooniverseCurrentUserCheckerFunction instanceof Function
      @zooniverseCurrentUserChecker = @zooniverseCurrentUserCheckerFunction
    else
      @zooniverseCurrentUserChecker = @returnAnonymous

  checkZooniverseCurrentUser: =>
    if @zooniverseCurrentUserChecker != null && @zooniverseCurrentUserChecker instanceof Function && @zooniverseCurrentUserChecker() != null
      newValueForCurrentUser = @zooniverseCurrentUserChecker()
      if newValueForCurrentUser!=null
        console.log "checkZoo method: The callback user getter function returned "+newValueForCurrentUser
      else
        console.log "checkZoo method: The callback user getter function returned null."
      if !!newValueForCurrentUser
        console.log "checkZoo method setting current UserID in getter to that value."
        @currentUserID = @zooniverseCurrentUserChecker()
      else
        console.log "checkZoo method setting current UserID in getter to " + @ANONYMOUS + " (1)."
        @currentUserID = @ANONYMOUS
    else
      console.log "checkZoo method setting current UserID in getter to " + @ANONYMOUS + " (1)."
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
            console.log "service returned: "
            console.log data
            @currentUserID = @getNiceOriginString data
            console.log "getUserID method set currentUserID to "+@currentUserID
        .always =>
          eventualUserID.resolve @currentUserID
    else
      eventualUserID.resolve @ANONYMOUS
    eventualUserID.promise()
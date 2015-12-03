$ = require('jqueryify')

module.exports = class UserStringGetter
  ANONYMOUS : "(anonymous)"
  UNAVAILABLE : "(unavailable)"
  currentUserID : @ANONYMOUS
  zooniverseCurrentUserChecker : null
  gettingIP: false

  returnAnonymous: =>
    @ANONYMOUS

  constructor: (@zooniverseCurrentUserCheckerFunction) ->
    if @zooniverseCurrentUserCheckerFunction instanceof Function
      @zooniverseCurrentUserChecker = @zooniverseCurrentUserCheckerFunction
    else
      @zooniverseCurrentUserChecker = @returnAnonymous

  # update current user ID if the callback was able to determine a new non-null, non-undefined, non-ANONYMOUS value
  #  - in this case no need to use the external IP service
  # returns a boolean to indicate whether a change has been made
  setCurrentUserIDFromCallback: =>
    if @zooniverseCurrentUserChecker != null && @zooniverseCurrentUserChecker instanceof Function && @zooniverseCurrentUserChecker() != null
      newValueForCurrentUser = @zooniverseCurrentUserChecker()
      if newValueForCurrentUser? && newValueForCurrentUser != @ANONYMOUS
        console.log "checkZoo method: The callback user getter function returned "+newValueForCurrentUser
        console.log "checkZoo method setting current UserID in getter to that value."
        @currentUserID = @zooniverseCurrentUserChecker()
        return true
    return false

  # external instruction to forget current user (e.g. on known user log out)
  forgetCurrentUserID: =>
    console.log "at app request, set currentUserID back to "+@ANONYMOUS
    @currentUserID = @ANONYMOUS

  # externally set the user ID to be returned - no validation
  rememberCurrentUserID: (newUserID) =>
    console.log "at app request, set currentUserID to "+newUserID
    @currentUserID = newUserID

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
    if @currentUserID != @ANONYMOUS
      # a non-anonymous user ID is already known (perhaps set by rememberCurrentUserID),
      # so we keep on using that until forgetCurrentUserID is called
      eventualUserID.resolve @currentUserID
    else
      # try to set the user ID using the callback
      if @setCurrentUserIDFromCallback()
        # current User ID has been set from callback - just return it
        eventualUserID.resolve @currentUserID
      else
        # the callback didn't help, so we need to use the external service - but only if a request is not already in progress
        if !@gettingIP
          @getClientOrigin()
          .then (data) =>
            if data?
              console.log "service returned: "
              console.log data
              @currentUserID = @getNiceOriginString data
              console.log "getUserID method set currentUserID to "+@currentUserID
          .always =>
            @gettingIP = false
            # in the event of success, this returns an IP string - otherwise it will just return @ANONYMOUS
            eventualUserID.resolve @currentUserID
    eventualUserID.promise()
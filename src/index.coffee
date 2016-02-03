# TODO: remove jquery dependency
$ = require('jqueryify')

module.exports = class UserStringGetter
  ANONYMOUS : "(anonymous)"
  currentUserID : @ANONYMOUS
  zooniverseCurrentUserChecker : null
  gettingIP: false

  returnAnonymous: =>
    @ANONYMOUS

  constructor: (@zooniverseCurrentUserCheckerFunction,@zooniverseCurrentUserCheckerFunctionParameter) ->
    if @zooniverseCurrentUserCheckerFunction instanceof Function
      @zooniverseCurrentUserChecker = @zooniverseCurrentUserCheckerFunction
      @zooniverseCurrentUserCheckerParameter = @zooniverseCurrentUserCheckerFunctionParameter
    else
      @zooniverseCurrentUserChecker = @returnAnonymous
      @zooniverseCurrentUserCheckerParameter = null

  # update current user ID if the callback was able to determine a new non-null, non-undefined, non-ANONYMOUS value
  # returns a boolean to indicate whether a change has been made
  setCurrentUserIDFromCallback: =>
    if @zooniverseCurrentUserChecker != null && @zooniverseCurrentUserChecker instanceof Function
      userID = @zooniverseCurrentUserChecker(@zooniverseCurrentUserCheckerParameter)
      if userID != null && userID != @ANONYMOUS
        @currentUserID = userID
        return true
    return false

  # external instruction to forget current user (e.g. on known user log out)
  forgetCurrentUserID: =>
    @currentUserID = @ANONYMOUS

  # externally set the user ID to be returned - no validation
  rememberCurrentUserID: (newUserID) =>
    @currentUserID = newUserID

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
        # the callback didn't help, so we just return anonymous
        eventualUserID.resolve @ANONYMOUS
    eventualUserID.promise()
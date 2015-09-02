$ = require('jqueryify')
ANONYMOUS = "(anonymous)"
currentUserID = ANONYMOUS
zooniverseCurrentUserChecker = null

setZooniverseCurrentUserChecker = (zooniverseCurrentUserCheckerFunction) =>
  if zooniverseCurrentUserCheckerFunction instanceof Function
    zooniverseCurrentUserChecker = zooniverseCurrentUserCheckerFunction
    true
  else
    false

checkZooniverseCurrentUser = =>
  if zooniverseCurrentUserChecker && zooniverseCurrentUserChecker instanceof Function && zooniverseCurrentUserChecker() != null
    currentUserID = zooniverseCurrentUserChecker()
  else
    currentUserID = ANONYMOUS
  return currentUserID

getClientOrigin = ->
  eventualIP = new $.Deferred
  $.get('https://api.ipify.org')
  .then (ip) =>
    console.log 'returned IP was ' + ip
    eventualIP.resolve {ip: ip, address: ip}
  .fail =>
    eventualIP.resolve {ip: '?.?.?.?', address: ANONYMOUS}
  eventualIP.promise()

getNiceOriginString = (data) ->
  if data.ip? && data.address?
    if data.ip == '?.?.?.?'
      ANONYMOUS
    else if data.ip == data.address
      "(#{ data.ip })"
    else
      "(#{ data.address } [#{ data.ip }])"
  else
    ANONYMOUS

getUserIDorIPAddress = =>
  eventualUserID = new $.Deferred
  if zooniverseCurrentUserChecker is not null
    checkUserNow = checkZooniverseCurrentUser()
    if checkUserNow && currentUserID!=checkUserNow
      # if a current ID is stored, but user's current ID is something different (e.g. anon IP), overwrite previous
      eventualUserID.resolve currentUserID
    else if currentUserID? and currentUserID != ANONYMOUS
      eventualUserID.resolve currentUserID
    else
      getClientOrigin()
      .then (data) =>
        if data?
          currentUserID = getNiceOriginString data
      .always =>
        eventualUserID.resolve currentUserID
  else
    eventualUserID.resolve ANONYMOUS
  eventualUserID.promise()

exports.getClientOrigin = getClientOrigin
exports.getNiceOriginString = getNiceOriginString
exports.getUserIDorIPAddress = getUserIDorIPAddress
exports.setZooniverseCurrentUserChecker = setZooniverseCurrentUserChecker
exports.checkZooniverseCurrentUser = checkZooniverseCurrentUser
exports.currentUserID = currentUserID
exports.ANONYMOUS = ANONYMOUS

window?.UserGetter = exports
module?.exports = exports

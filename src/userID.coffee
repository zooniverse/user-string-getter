$ = require('jqueryify')
currentUserID = null
zooniverseCurrentUserChecker = null

setZooniverseCurrentUserChecker = (zooniverseCurrentUserCheckerFunction) =>
  if zooniverseCurrentUserCheckerFunction instanceof Function
    zooniverseCurrentUserChecker = zooniverseCurrentUserCheckerFunction
    true
  else
    false

checkZooniverseCurrentUser = =>
  if zooniverseCurrentUserChecker && zooniverseCurrentUserChecker instanceof Function
    currentUserID = zooniverseCurrentUserChecker()
  else
    null

getClientOrigin = ->
  eventualIP = new $.Deferred
  $.get('https://api.ipify.org')
  .then (ip) =>
    eventualIP.resolve {ip: ip, address: ip}
  .fail =>
    eventualIP.resolve {ip: '?.?.?.?', address: '(anonymous)'}
  eventualIP.promise()

getNiceOriginString = (data) ->
  if data.ip? && data.address?
    if data.ip == '?.?.?.?'
      "(anonymous)"
    else if data.ip == data.address
      "(#{ data.ip })"
    else
      "(#{ data.address } [#{ data.ip }])"
  else
    "(anonymous)"

getUserIDorIPAddress = =>
  eventualUserID = new $.Deferred
  if zooniverseCurrentUserChecker is not null
    checkUserNow = zooniverseCurrentUserChecker()
    if checkUserNow && currentUserID!=checkUserNow
      # if a current ID is stored, but user's current ID is something different (e.g. anon IP), overwrite previous
      checkZooniverseCurrentUser()
      eventualUserID.resolve currentUserID
    else if currentUserID?
      eventualUserID.resolve currentUserID
    else if checkZooniverseCurrentUser()?
      eventualUserID.resolve currentUserID
    else
      getClientOrigin()
      .then (data) =>
        if data?
          currentUserID = getNiceOriginString data
      .always =>
        eventualUserID.resolve currentUserID
  else
    eventualUserID.resolve null
  eventualUserID.promise()

exports.getClientOrigin = getClientOrigin
exports.getNiceOriginString = getNiceOriginString
exports.getUserIDorIPAddress = getUserIDorIPAddress
exports.setZooniverseCurrentUserChecker = setZooniverseCurrentUserChecker
exports.checkZooniverseCurrentUser = checkZooniverseCurrentUser
exports.currentUserID = currentUserID

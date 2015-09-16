module.exports = Notifications =
  packageName: 'Elastic Twitter Stream'
  addInfo: (message, {detail}={}) ->
    atom.notifications?.addInfo("#{@packageName}: #{message}", detail: detail)
  addError: (message, {detail}={}) ->
    atom.notifications.addError(
      "#{@packageName}: #{message}", detail: detail, dismissable: true)

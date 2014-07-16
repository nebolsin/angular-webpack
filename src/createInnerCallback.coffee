#
#	MIT License http://www.opensource.org/licenses/mit-license.php
#	Author Tobias Koppers @sokra
#
module.exports = createInnerCallback = (callback, options, message) ->
  if log = options.log
    theLog = []

    loggingCallbackWrapper = ->
      log message
      log "  #{msg}" for msg in theLog

      callback.apply this, arguments

    loggingCallbackWrapper.log = (msg) ->
      theLog.push msg

    loggingCallbackWrapper.stack = options.stack
    loggingCallbackWrapper
  else if options.stack isnt callback.stack
    callbackWrapper = ->
      callback.apply this, arguments
    callbackWrapper.stack = options.stack
    callbackWrapper
  else
    callback


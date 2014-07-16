createInnerCallback = require './createInnerCallback'

class AngularModuleResolverPlugin
  constructor: (@options) ->

  this.applyDebug = (resolver) ->
    resolver.plugin "file", (request, callback) ->
      console.log "F: #{JSON.stringify(request)}"
      callback()

    resolver.plugin "directory", (request, callback) ->
      console.log "D: #{JSON.stringify(request)}"
      callback()

    resolver.plugin "module", (request, callback) ->
      console.log "M: #{JSON.stringify(request)}"
      callback()

    resolver.plugin "module-module", (request, callback) ->
      console.log "MM: #{JSON.stringify(request)}"
      callback()

    resolver.plugin "module-loader", (request, callback) ->
      console.log "ML: #{JSON.stringify(request)}"
      callback()

    resolver.plugin "module-context", (request, callback) ->
      console.log "MC: #{JSON.stringify(request)}"
      callback()

    resolver.plugin "module-loader-module", (request, callback) ->
      console.log "MLM: #{JSON.stringify(request)}"
      callback()

    resolver.plugin "result", (request, callback) ->
      console.log "RESULT: #{JSON.stringify(request)}"
      callback()

  apply: (resolver) ->

    # AngularModuleResolverPlugin.applyDebug(resolver);

    # angular module aliases
    # - ngRoute -> (ng-route, angular-route)
    # - my.cool.module -> (my/cool.module, my/cool/module)
    resolver.plugin "module", (request, callback) ->
      #console.log "Resolve module: #{JSON.stringify(request)}"
      topLevelCallback = callback
      requests = [request.request]

      # ngRoute -> angular-route
      moduleReqStr = request.request.replace(/([a-z])([A-Z])/g, "$1-$2").replace(/^ng(-.+)?$/, "angular$1").toLowerCase()
      requests.push moduleReqStr unless moduleReqStr in requests

      # my.cool.module -> my-cool-module
      moduleReqStr = request.request.replace(/\./g, "-")
      requests.push moduleReqStr unless moduleReqStr in requests

      # whatms.common -> whatms/common
      moduleReqStr = request.request.replace(/\./, "/")
      requests.push moduleReqStr unless moduleReqStr in requests

      # dowb.angular-pusher -> angular-pusher
      moduleReqStr = request.request.replace(/[\w-]+\./, "")
      requests.push moduleReqStr unless moduleReqStr in requests

      requests.shift()

      @forEachBail requests, (moduleReqStr, callback) =>
        moduleReq = @parse(moduleReqStr)
        innerRequest =
          path: request.path
          request: moduleReq.path
          query: moduleReq.query
          directory: moduleReq.directory
        innerCallbackFn = (err, result) ->
          if not err and result then callback(result) else callback()

        innerCallback = createInnerCallback(innerCallbackFn, topLevelCallback, "aliased as angular module #{request.request} -> #{innerRequest.request}")

        @doResolve "module", innerRequest, innerCallback, true
      , (result) ->
        if result then callback(null, result) else callback()


    # directory with same name file
    resolver.plugin "directory", (request, callback) ->
      topLevelCallback = callback
      fs = @fileSystem
      directory = @join(request.path, request.request)
      dirName = directory.substr(directory.lastIndexOf('/') + 1)

      fs.stat directory, (err, stat) =>
        if err or not stat
          callback.log directory + " doesn't exist (directory same name file)"  if callback.log
          return callback()
        unless stat.isDirectory()
          callback.log directory + " is not a directory (directory same name file)"  if callback.log
          return callback()

        files = ["#{dirName}.module", dirName]

        @forEachBail files, (fileName, callback) =>
          innerRequest =
            path: directory
            request: fileName
            query: request.query
            directory: false
          innerCallbackFn = (err, result) ->
            if not err and result then callback(result) else callback()

          innerCallback = createInnerCallback(innerCallbackFn, topLevelCallback, "directory default module file")

          @doResolve "file", innerRequest, innerCallback, true
        , (result) ->
          if result then callback(null, result) else callback()

module.exports = AngularModuleResolverPlugin

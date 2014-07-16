LocalModulesHelpers = require("webpack/lib/dependencies/LocalModulesHelpers")
ModuleParserHelpers = require("webpack/lib/ModuleParserHelpers")
RequireHeaderDependency = require("webpack/lib/dependencies/RequireHeaderDependency")

AngularModuleDefinition = require './AngularModuleDefinition'
AngularModuleDependency = require './AngularModuleDependency'

class AngularParserPlugin
  constructor: (@options) ->

  apply: (parser) ->
    bindCallbackMethod = (source, plugname, obj, method) ->
      source.plugin plugname, method.bind(obj, source)

    #bindCallbackMethod parser, "expression angular", this, @addAngularVariable
    bindCallbackMethod parser, "call angular.module", this, @parseModuleCall

  # This injects the angular module wherever it's used.
  addAngularVariable: (parser) ->
    ModuleParserHelpers.addParsedVariable parser, "angular", "require('angular')"


  # Each call to `angular.module()` is analysed here
  parseModuleCall: (parser, expr) ->
    #@addAngularVariable parser
    switch expr.arguments.length
      when 1
        @_parseModuleCallSingleArgument parser, expr
      when 2
        @_parseModuleCallTwoArgument parser, expr
      when 3
        @_parseModuleCallThreeArgument parser, expr
      else
        console.warn "Don't recognise angular.module() with " + expr.arguments.length + " args"


  # #### Private Methods

  # A single argument is the equivalent of `require()`
  # angular.module(name)
  _parseModuleCallSingleArgument: (parser, expr) ->
    mod = parser.evaluateExpression(expr.arguments[0])
    @_addDependency parser, expr, mod


  # 2 arguments mean a module definition if the 2nd is an array.
  # angular.module(name, requires)
  # angular.module(name, configFn)
  _parseModuleCallTwoArgument: (parser, expr) ->
    mod = parser.evaluateExpression(expr.arguments[0])
    deps = parser.evaluateExpression(expr.arguments[1])
    @_addModuleDefinition parser, expr, mod
    return deps.items.every(@_addDependency.bind(this, parser, expr))  if deps.items
    @_addDependency parser, expr, mod


  # 3 arguments must be a module definition
  # angular.module(name, requires, configFn)
  _parseModuleCallThreeArgument: (parser, expr) ->
    mod = parser.evaluateExpression(expr.arguments[0])
    deps = parser.evaluateExpression(expr.arguments[1])
    @_addModuleDefinition parser, expr, mod
    deps.items.every @_addDependency.bind(this, parser, expr)

  _addModuleDefinition: (parser, expr, mod) ->
    dep = new AngularModuleDefinition(expr.range, mod.string)
    dep.loc = expr.loc
    dep.localModule = LocalModulesHelpers.addLocalModule(parser.state, mod.string)
    parser.state.current.addDependency dep
    true


  # A dependency (module) has been found
  _addDependency: (parser, expr, param) ->
    if param.isConditional()

      # TODO: not sure what this will output
      parser.state.current.addDependency new RequireHeaderDependency(expr.callee.range)
      param.options.forEach (param) ->
        result = parser.applyPluginsBailResult("call require:commonjs:item", expr, param)
        throw new Error("Cannot convert options with mixed known and unknown stuff")  if result is `undefined`
        return

      return true
    if param.isString()
      dep = undefined
      localModule = LocalModulesHelpers.getLocalModule(parser.state, param.string)
      return true  if localModule
      dep = new AngularModuleDependency(param.string, param.range)
      dep.loc = param.loc
      parser.state.current.addDependency dep
      return true

    parser.applyPluginsBailResult "call require:commonjs:context", expr, param
    true


module.exports = AngularParserPlugin
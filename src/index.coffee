NullFactory = require 'webpack/lib/NullFactory'

AngularModuleDependency = require './AngularModuleDependency'
AngularModuleDefinition = require './AngularModuleDefinition'

AngularParserPlugin = require './AngularParserPlugin'
AngularModuleResolverPlugin = require './AngularModuleResolverPlugin'


class AngularPlugin
  constructor: (@options, @ngOptions) ->

  apply: (compiler) ->
    compiler.plugin 'compilation', (compilation, params) ->
      compilation.dependencyFactories.set AngularModuleDependency, params.normalModuleFactory
      compilation.dependencyTemplates.set AngularModuleDependency, new AngularModuleDependency.Template()

      compilation.dependencyFactories.set AngularModuleDefinition, new NullFactory()
      compilation.dependencyTemplates.set AngularModuleDefinition, new AngularModuleDefinition.Template()

    compiler.parser.apply new AngularParserPlugin(@options)
    compiler.resolvers.normal.apply new AngularModuleResolverPlugin(@options)

module.exports = AngularPlugin

// Generated by CoffeeScript 1.7.1
(function() {
  var AngularModuleDefinition, AngularModuleDependency, AngularModuleResolverPlugin, AngularParserPlugin, AngularPlugin, NullFactory;

  NullFactory = require('webpack/lib/NullFactory');

  AngularModuleDependency = require('./AngularModuleDependency');

  AngularModuleDefinition = require('./AngularModuleDefinition');

  AngularParserPlugin = require('./AngularParserPlugin');

  AngularModuleResolverPlugin = require('./AngularModuleResolverPlugin');

  AngularPlugin = (function() {
    function AngularPlugin(options, ngOptions) {
      this.options = options;
      this.ngOptions = ngOptions;
    }

    AngularPlugin.prototype.apply = function(compiler) {
      compiler.plugin('compilation', function(compilation, params) {
        compilation.dependencyFactories.set(AngularModuleDependency, params.normalModuleFactory);
        compilation.dependencyTemplates.set(AngularModuleDependency, new AngularModuleDependency.Template());
        compilation.dependencyFactories.set(AngularModuleDefinition, new NullFactory());
        return compilation.dependencyTemplates.set(AngularModuleDefinition, new AngularModuleDefinition.Template());
      });
      compiler.parser.apply(new AngularParserPlugin(this.options));
      return compiler.resolvers.normal.apply(new AngularModuleResolverPlugin(this.options));
    };

    return AngularPlugin;

  })();

  module.exports = AngularPlugin;

}).call(this);
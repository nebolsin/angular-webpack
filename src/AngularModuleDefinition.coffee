# © Copyright 2014 Sergey Nebolsin
# Licensed under the MIT license.
#
# Module definition for angular modules
NullDependency = require("webpack/lib/dependencies/NullDependency")

# The definition template leaves the call to angular.module as-is, but assigns
# the result to an export with the module name.
class AngularModuleDefinitionTemplate
  apply: (dep, source) ->
    source.insert dep.range[0], "exports['" + dep.name + "'] = "

class AngularModuleDefinition extends NullDependency
  @Template: AngularModuleDefinitionTemplate
  type: "angular module define"

  constructor: (@range, @name) ->
    super
    @Class = AngularModuleDefinition


module.exports = AngularModuleDefinition

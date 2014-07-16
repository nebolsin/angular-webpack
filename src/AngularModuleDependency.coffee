# © Copyright 2014 Paul Thomas <paul@stackfull.com>.
# Licensed under the MIT license.
#
# Dependency definitions for angular modules

ModuleDependency = require("webpack/lib/dependencies/ModuleDependency")
WebpackMissingModule = require("webpack/lib/dependencies/WebpackMissingModule")

# The dependency template leaves the dependency array as the original strings
# so that angular can deal with out-of-order definitions. But a
# __webpack_require__ is inserted at the top to make sure the file is pulled
# in.
class AngularModuleDependencyTemplate
  apply: (dep, source, outputOptions, requestShortener) ->
    return  unless dep.range
    comment = if outputOptions.pathinfo then "/*! " + requestShortener.shorten(dep.request) + " */ " else ""
    if dep.module
      content = "__webpack_require__(" + comment + dep.module.id + ");\n"
    else
      content = WebpackMissingModule.module(dep.request);
    source.insert 0, content

  applyAsTemplateArgument: (name, dep, source) ->
    return  unless dep.range
    source.replace dep.range[0], dep.range[1] - 1, name

class AngularModuleDependency extends ModuleDependency
  @Template: AngularModuleDependencyTemplate
  type: "angular module"

  constructor: (@request, @range) ->
    super request
    @Class = AngularModuleDependency

module.exports = AngularModuleDependency


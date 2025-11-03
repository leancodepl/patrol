'use strict'
const _package = require('./package.json.js')
const sortVariableDeclarations = require('./rules/sort-variable-declarations.js')
const sortIntersectionTypes = require('./rules/sort-intersection-types.js')
const sortHeritageClauses = require('./rules/sort-heritage-clauses.js')
const sortArrayIncludes = require('./rules/sort-array-includes.js')
const sortNamedImports = require('./rules/sort-named-imports.js')
const sortNamedExports = require('./rules/sort-named-exports.js')
const sortObjectTypes = require('./rules/sort-object-types.js')
const sortSwitchCase = require('./rules/sort-switch-case.js')
const sortUnionTypes = require('./rules/sort-union-types.js')
const sortInterfaces = require('./rules/sort-interfaces.js')
const sortDecorators = require('./rules/sort-decorators.js')
const sortJsxProps = require('./rules/sort-jsx-props.js')
const sortClasses = require('./rules/sort-classes.js')
const sortImports = require('./rules/sort-imports.js')
const sortExports = require('./rules/sort-exports.js')
const sortObjects = require('./rules/sort-objects.js')
const sortModules = require('./rules/sort-modules.js')
const sortEnums = require('./rules/sort-enums.js')
const sortMaps = require('./rules/sort-maps.js')
const sortSets = require('./rules/sort-sets.js')
let pluginName = 'perfectionist'
let plugin = {
  rules: {
    'sort-variable-declarations': sortVariableDeclarations,
    'sort-intersection-types': sortIntersectionTypes,
    'sort-heritage-clauses': sortHeritageClauses,
    'sort-array-includes': sortArrayIncludes.default,
    'sort-named-imports': sortNamedImports,
    'sort-named-exports': sortNamedExports,
    'sort-object-types': sortObjectTypes.default,
    'sort-union-types': sortUnionTypes.default,
    'sort-switch-case': sortSwitchCase,
    'sort-decorators': sortDecorators,
    'sort-interfaces': sortInterfaces,
    'sort-jsx-props': sortJsxProps,
    'sort-modules': sortModules,
    'sort-classes': sortClasses,
    'sort-imports': sortImports,
    'sort-exports': sortExports,
    'sort-objects': sortObjects,
    'sort-enums': sortEnums,
    'sort-sets': sortSets,
    'sort-maps': sortMaps,
  },
  meta: {
    version: _package.version,
    name: _package.name,
  },
}
function getRules(options) {
  return Object.fromEntries(
    Object.keys(plugin.rules).map(ruleName => [
      `${pluginName}/${ruleName}`,
      ['error', options],
    ]),
  )
}
function createConfig(options) {
  return {
    plugins: {
      [pluginName]: plugin,
    },
    rules: getRules(options),
  }
}
function createLegacyConfig(options) {
  return {
    rules: getRules(options),
    plugins: [pluginName],
  }
}
const index = {
  ...plugin,
  configs: {
    'recommended-alphabetical-legacy': createLegacyConfig({
      type: 'alphabetical',
      order: 'asc',
    }),
    'recommended-line-length-legacy': createLegacyConfig({
      type: 'line-length',
      order: 'desc',
    }),
    'recommended-natural-legacy': createLegacyConfig({
      type: 'natural',
      order: 'asc',
    }),
    'recommended-custom-legacy': createLegacyConfig({
      type: 'custom',
      order: 'asc',
    }),
    'recommended-alphabetical': createConfig({
      type: 'alphabetical',
      order: 'asc',
    }),
    'recommended-line-length': createConfig({
      type: 'line-length',
      order: 'desc',
    }),
    'recommended-natural': createConfig({
      type: 'natural',
      order: 'asc',
    }),
    'recommended-custom': createConfig({
      type: 'custom',
      order: 'asc',
    }),
  },
}
module.exports = index

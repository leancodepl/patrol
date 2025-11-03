'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const commonJsonSchemas = require('../../utils/common-json-schemas.js')
let allSelectors = [
  'side-effect-style',
  'tsconfig-path',
  'side-effect',
  'external',
  'internal',
  'builtin',
  'sibling',
  'subpath',
  'import',
  'parent',
  'index',
  'style',
  'type',
]
let allDeprecatedSelectors = [
  'internal-type',
  'external-type',
  'sibling-type',
  'builtin-type',
  'parent-type',
  'index-type',
  'object',
]
let allModifiers = [
  'default',
  'named',
  'require',
  'side-effect',
  'ts-equals',
  'type',
  'value',
  'wildcard',
]
let singleCustomGroupJsonSchema = {
  modifiers:
    commonJsonSchemas.buildCustomGroupModifiersJsonSchema(allModifiers),
  selector: commonJsonSchemas.buildCustomGroupSelectorJsonSchema(allSelectors),
  elementValuePattern: commonJsonSchemas.regexJsonSchema,
  elementNamePattern: commonJsonSchemas.regexJsonSchema,
}
exports.allDeprecatedSelectors = allDeprecatedSelectors
exports.allModifiers = allModifiers
exports.allSelectors = allSelectors
exports.singleCustomGroupJsonSchema = singleCustomGroupJsonSchema

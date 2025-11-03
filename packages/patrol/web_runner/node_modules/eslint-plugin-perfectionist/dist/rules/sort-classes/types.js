'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const commonJsonSchemas = require('../../utils/common-json-schemas.js')
let allSelectors = [
  'accessor-property',
  'index-signature',
  'constructor',
  'static-block',
  'get-method',
  'set-method',
  'function-property',
  'property',
  'method',
]
let allModifiers = [
  'async',
  'protected',
  'private',
  'public',
  'static',
  'abstract',
  'override',
  'readonly',
  'decorated',
  'declare',
  'optional',
]
let singleCustomGroupJsonSchema = {
  modifiers:
    commonJsonSchemas.buildCustomGroupModifiersJsonSchema(allModifiers),
  selector: commonJsonSchemas.buildCustomGroupSelectorJsonSchema(allSelectors),
  decoratorNamePattern: commonJsonSchemas.regexJsonSchema,
  elementValuePattern: commonJsonSchemas.regexJsonSchema,
  elementNamePattern: commonJsonSchemas.regexJsonSchema,
}
exports.allModifiers = allModifiers
exports.allSelectors = allSelectors
exports.singleCustomGroupJsonSchema = singleCustomGroupJsonSchema

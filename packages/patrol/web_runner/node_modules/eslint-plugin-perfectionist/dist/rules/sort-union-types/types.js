'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const commonJsonSchemas = require('../../utils/common-json-schemas.js')
let allSelectors = [
  'intersection',
  'conditional',
  'function',
  'operator',
  'keyword',
  'literal',
  'nullish',
  'import',
  'object',
  'named',
  'tuple',
  'union',
]
let singleCustomGroupJsonSchema = {
  selector: commonJsonSchemas.buildCustomGroupSelectorJsonSchema(allSelectors),
  elementNamePattern: commonJsonSchemas.regexJsonSchema,
}
exports.allSelectors = allSelectors
exports.singleCustomGroupJsonSchema = singleCustomGroupJsonSchema

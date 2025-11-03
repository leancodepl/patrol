'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const commonJsonSchemas = require('../../utils/common-json-schemas.js')
let allSelectors = [
  'index-signature',
  'member',
  'method',
  'multiline',
  'property',
]
let allModifiers = ['optional', 'required', 'multiline']
let sortByJsonSchema = {
  enum: ['name', 'value'],
  type: 'string',
}
let singleCustomGroupJsonSchema = {
  modifiers:
    commonJsonSchemas.buildCustomGroupModifiersJsonSchema(allModifiers),
  selector: commonJsonSchemas.buildCustomGroupSelectorJsonSchema(allSelectors),
  elementValuePattern: commonJsonSchemas.regexJsonSchema,
  elementNamePattern: commonJsonSchemas.regexJsonSchema,
  sortBy: sortByJsonSchema,
}
exports.allModifiers = allModifiers
exports.allSelectors = allSelectors
exports.singleCustomGroupJsonSchema = singleCustomGroupJsonSchema
exports.sortByJsonSchema = sortByJsonSchema

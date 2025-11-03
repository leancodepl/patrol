'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const commonJsonSchemas = require('../../utils/common-json-schemas.js')
let allSelectors = ['export']
let allModifiers = ['value', 'type']
let singleCustomGroupJsonSchema = {
  modifiers:
    commonJsonSchemas.buildCustomGroupModifiersJsonSchema(allModifiers),
  selector: commonJsonSchemas.buildCustomGroupSelectorJsonSchema(allSelectors),
  elementNamePattern: commonJsonSchemas.regexJsonSchema,
}
exports.allModifiers = allModifiers
exports.allSelectors = allSelectors
exports.singleCustomGroupJsonSchema = singleCustomGroupJsonSchema

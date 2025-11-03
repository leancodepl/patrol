'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const commonJsonSchemas = require('../../utils/common-json-schemas.js')
let allSelectors = ['multiline', 'prop', 'shorthand']
let allModifiers = ['shorthand', 'multiline']
let singleCustomGroupJsonSchema = {
  modifiers:
    commonJsonSchemas.buildCustomGroupModifiersJsonSchema(allModifiers),
  selector: commonJsonSchemas.buildCustomGroupSelectorJsonSchema(allSelectors),
  elementValuePattern: commonJsonSchemas.regexJsonSchema,
  elementNamePattern: commonJsonSchemas.regexJsonSchema,
}
exports.allModifiers = allModifiers
exports.allSelectors = allSelectors
exports.singleCustomGroupJsonSchema = singleCustomGroupJsonSchema

'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const commonJsonSchemas = require('../../utils/common-json-schemas.js')
let allSelectors = ['initialized', 'uninitialized']
let singleCustomGroupJsonSchema = {
  selector: commonJsonSchemas.buildCustomGroupSelectorJsonSchema(allSelectors),
  elementNamePattern: commonJsonSchemas.regexJsonSchema,
}
exports.allSelectors = allSelectors
exports.singleCustomGroupJsonSchema = singleCustomGroupJsonSchema

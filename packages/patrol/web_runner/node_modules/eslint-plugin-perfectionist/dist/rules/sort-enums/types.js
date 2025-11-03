'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const commonJsonSchemas = require('../../utils/common-json-schemas.js')
let singleCustomGroupJsonSchema = {
  elementValuePattern: commonJsonSchemas.regexJsonSchema,
  elementNamePattern: commonJsonSchemas.regexJsonSchema,
}
exports.singleCustomGroupJsonSchema = singleCustomGroupJsonSchema

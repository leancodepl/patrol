'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function getEnumMembers(value) {
  return value.body?.members ?? value.members
}
exports.getEnumMembers = getEnumMembers

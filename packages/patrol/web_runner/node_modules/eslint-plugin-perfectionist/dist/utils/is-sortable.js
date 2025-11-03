'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function isSortable(node) {
  return Array.isArray(node) && node.length > 1
}
exports.isSortable = isSortable

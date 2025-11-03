'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const types = require('@typescript-eslint/types')
function isMemberOptional(node) {
  switch (node.type) {
    case types.AST_NODE_TYPES.TSPropertySignature:
    case types.AST_NODE_TYPES.TSMethodSignature:
      return node.optional
  }
  return false
}
exports.isMemberOptional = isMemberOptional

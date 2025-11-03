'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function isNodeFunctionType(node) {
  if (node.type === 'TSMethodSignature' || node.type === 'TSFunctionType') {
    return true
  }
  if (node.type === 'TSUnionType' || node.type === 'TSIntersectionType') {
    return node.types.every(isNodeFunctionType)
  }
  if (node.type === 'TSPropertySignature' && node.typeAnnotation) {
    return isNodeFunctionType(node.typeAnnotation.typeAnnotation)
  }
  return false
}
exports.isNodeFunctionType = isNodeFunctionType

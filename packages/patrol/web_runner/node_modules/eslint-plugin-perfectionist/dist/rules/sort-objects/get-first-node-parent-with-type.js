'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function getFirstNodeParentWithType({ onlyFirstParent, allowedTypes, node }) {
  let { parent } = node
  if (onlyFirstParent) {
    return parent && allowedTypes.includes(parent.type) ? parent : null
  }
  while (parent) {
    if (allowedTypes.includes(parent.type)) {
      return parent
    }
    ;({ parent } = parent)
  }
  return null
}
exports.getFirstNodeParentWithType = getFirstNodeParentWithType

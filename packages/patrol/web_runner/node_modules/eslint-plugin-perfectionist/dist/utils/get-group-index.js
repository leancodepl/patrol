'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function getGroupIndex(groups, node) {
  for (let max = groups.length, i = 0; i < max; i++) {
    let currentGroup = groups[i]
    if (
      node.group === currentGroup ||
      (Array.isArray(currentGroup) &&
        typeof node.group === 'string' &&
        currentGroup.includes(node.group))
    ) {
      return i
    }
  }
  return groups.length
}
exports.getGroupIndex = getGroupIndex

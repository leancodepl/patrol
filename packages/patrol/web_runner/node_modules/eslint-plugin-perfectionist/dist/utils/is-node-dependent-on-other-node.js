'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function isNodeDependentOnOtherNode(sortingNode1, sortingNode2) {
  if (sortingNode1 === sortingNode2) {
    return false
  }
  return sortingNode1.dependencyNames.some(dependency =>
    sortingNode2.dependencies.includes(dependency),
  )
}
exports.isNodeDependentOnOtherNode = isNodeDependentOnOtherNode

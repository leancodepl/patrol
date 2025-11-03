'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const compare = require('./compare.js')
function sortNodes({
  fallbackSortNodeValueGetter,
  ignoreEslintDisabledNodes,
  nodeValueGetter,
  isNodeIgnored,
  options,
  nodes,
}) {
  let nonIgnoredNodes = []
  let ignoredNodeIndices = []
  for (let [index, sortingNode] of nodes.entries()) {
    if (
      (sortingNode.isEslintDisabled && ignoreEslintDisabledNodes) ||
      isNodeIgnored?.(sortingNode)
    ) {
      ignoredNodeIndices.push(index)
    } else {
      nonIgnoredNodes.push(sortingNode)
    }
  }
  let sortedNodes = [...nonIgnoredNodes].sort((a, b) =>
    compare.compare({
      fallbackSortNodeValueGetter,
      nodeValueGetter,
      options,
      a,
      b,
    }),
  )
  for (let ignoredIndex of ignoredNodeIndices) {
    sortedNodes.splice(ignoredIndex, 0, nodes[ignoredIndex])
  }
  return sortedNodes
}
exports.sortNodes = sortNodes

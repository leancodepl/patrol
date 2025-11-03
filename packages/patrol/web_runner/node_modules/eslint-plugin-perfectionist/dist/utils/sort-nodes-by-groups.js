'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const getGroupIndex = require('./get-group-index.js')
const sortNodes = require('./sort-nodes.js')
function sortNodesByGroups({
  ignoreEslintDisabledNodes,
  getOptionsByGroupIndex,
  isNodeIgnoredForGroup,
  isNodeIgnored,
  groups,
  nodes,
}) {
  let nodesByNonIgnoredGroupIndex = {}
  let ignoredNodeIndices = []
  for (let [index, sortingNode] of nodes.entries()) {
    if (
      (sortingNode.isEslintDisabled && ignoreEslintDisabledNodes) ||
      isNodeIgnored?.(sortingNode)
    ) {
      ignoredNodeIndices.push(index)
      continue
    }
    let groupIndex = getGroupIndex.getGroupIndex(groups, sortingNode)
    nodesByNonIgnoredGroupIndex[groupIndex] ??= []
    nodesByNonIgnoredGroupIndex[groupIndex].push(sortingNode)
  }
  let sortedNodes = []
  for (let groupIndex of Object.keys(nodesByNonIgnoredGroupIndex).sort(
    (a, b) => Number(a) - Number(b),
  )) {
    let { fallbackSortNodeValueGetter, nodeValueGetter, options } =
      getOptionsByGroupIndex(Number(groupIndex))
    let nodesToPush = nodesByNonIgnoredGroupIndex[Number(groupIndex)]
    let groupIgnoredNodes = new Set(
      nodesToPush.filter(node => isNodeIgnoredForGroup?.(node, options)),
    )
    sortedNodes.push(
      ...sortNodes.sortNodes({
        isNodeIgnored: node => groupIgnoredNodes.has(node),
        ignoreEslintDisabledNodes: false,
        fallbackSortNodeValueGetter,
        nodes: nodesToPush,
        nodeValueGetter,
        options,
      }),
    )
  }
  for (let ignoredIndex of ignoredNodeIndices) {
    sortedNodes.splice(ignoredIndex, 0, nodes[ignoredIndex])
  }
  return sortedNodes
}
exports.sortNodesByGroups = sortNodesByGroups

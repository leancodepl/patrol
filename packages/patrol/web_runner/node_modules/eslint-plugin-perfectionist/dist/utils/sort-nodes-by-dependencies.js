'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const computeNodesInCircularDependencies = require('./compute-nodes-in-circular-dependencies.js')
const isNodeDependentOnOtherNode = require('./is-node-dependent-on-other-node.js')
function sortNodesByDependencies(nodes, extraOptions) {
  let nodesInCircularDependencies =
    computeNodesInCircularDependencies.computeNodesInCircularDependencies(nodes)
  let result = []
  let visitedNodes = /* @__PURE__ */ new Set()
  function visitNode(sortingNode) {
    if (visitedNodes.has(sortingNode)) {
      return
    }
    let dependentNodes = nodes
      .filter(node => !nodesInCircularDependencies.has(node))
      .filter(node =>
        isNodeDependentOnOtherNode.isNodeDependentOnOtherNode(
          node,
          sortingNode,
        ),
      )
    for (let dependentNode of dependentNodes) {
      if (
        !extraOptions.ignoreEslintDisabledNodes ||
        !dependentNode.isEslintDisabled
      ) {
        visitNode(dependentNode)
      }
    }
    visitedNodes.add(sortingNode)
    result.push(sortingNode)
  }
  for (let node of nodes) {
    visitNode(node)
  }
  return result
}
exports.sortNodesByDependencies = sortNodesByDependencies

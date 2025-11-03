'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const computeNodesInCircularDependencies = require('./compute-nodes-in-circular-dependencies.js')
const getCommentAboveThatShouldExist = require('./get-comment-above-that-should-exist.js')
const isNodeDependentOnOtherNode = require('./is-node-dependent-on-other-node.js')
const getNewlinesBetweenErrors = require('./get-newlines-between-errors.js')
const createNodeIndexMap = require('./create-node-index-map.js')
const getGroupIndex = require('./get-group-index.js')
const reportErrors = require('./report-errors.js')
const pairwise = require('./pairwise.js')
function reportAllErrors({
  ignoreFirstNodeHighestBlockComment,
  sortNodesExcludingEslintDisabled,
  newlinesBetweenValueGetter,
  availableMessageIds,
  sourceCode,
  context,
  options,
  nodes,
}) {
  let sortedNodes = sortNodesExcludingEslintDisabled(false)
  let sortedNodesExcludingEslintDisabled =
    sortNodesExcludingEslintDisabled(true)
  let nodeIndexMap = createNodeIndexMap.createNodeIndexMap(sortedNodes)
  let nodesInCircularDependencies =
    availableMessageIds.unexpectedDependencyOrder
      ? computeNodesInCircularDependencies.computeNodesInCircularDependencies(
          nodes,
        )
      : /* @__PURE__ */ new Set()
  pairwise.pairwise(nodes, (left, right) => {
    let leftInfo = left
      ? {
          groupIndex: getGroupIndex.getGroupIndex(options.groups, left),
          index: nodeIndexMap.get(left),
        }
      : null
    let rightGroupIndex = getGroupIndex.getGroupIndex(options.groups, right)
    let rightIndex = nodeIndexMap.get(right)
    let indexOfRightExcludingEslintDisabled =
      sortedNodesExcludingEslintDisabled.indexOf(right)
    let messageIds = []
    let firstUnorderedNodeDependentOnRight
    if (availableMessageIds.unexpectedDependencyOrder) {
      firstUnorderedNodeDependentOnRight = getFirstUnorderedNodeDependentOn({
        nodes,
        node: right,
        nodesInCircularDependencies,
      })
    }
    if (
      leftInfo &&
      (firstUnorderedNodeDependentOnRight ||
        leftInfo.index > rightIndex ||
        (left?.isEslintDisabled &&
          leftInfo.index >= indexOfRightExcludingEslintDisabled))
    ) {
      if (firstUnorderedNodeDependentOnRight) {
        messageIds.push(availableMessageIds.unexpectedDependencyOrder)
      } else {
        messageIds.push(
          leftInfo.groupIndex === rightGroupIndex ||
            !availableMessageIds.unexpectedGroupOrder
            ? availableMessageIds.unexpectedOrder
            : availableMessageIds.unexpectedGroupOrder,
        )
      }
    }
    if (
      left &&
      options.newlinesBetween !== void 0 &&
      availableMessageIds.missedSpacingBetweenMembers &&
      availableMessageIds.extraSpacingBetweenMembers
    ) {
      messageIds = [
        ...messageIds,
        ...getNewlinesBetweenErrors.getNewlinesBetweenErrors({
          options: {
            ...options,
            newlinesBetween: options.newlinesBetween,
          },
          missedSpacingError: availableMessageIds.missedSpacingBetweenMembers,
          extraSpacingError: availableMessageIds.extraSpacingBetweenMembers,
          leftGroupIndex: leftInfo.groupIndex,
          newlinesBetweenValueGetter,
          rightGroupIndex,
          sourceCode,
          right,
          left,
        }),
      ]
    }
    let commentAboveMissing
    if (availableMessageIds.missedCommentAbove) {
      let commentAboveThatShouldExist =
        getCommentAboveThatShouldExist.getCommentAboveThatShouldExist({
          leftGroupIndex: leftInfo?.groupIndex ?? null,
          sortingNode: right,
          rightGroupIndex,
          sourceCode,
          options,
        })
      if (commentAboveThatShouldExist && !commentAboveThatShouldExist.exists) {
        commentAboveMissing = commentAboveThatShouldExist.comment
        messageIds = [...messageIds, availableMessageIds.missedCommentAbove]
      }
    }
    reportErrors.reportErrors({
      sortedNodes: sortedNodesExcludingEslintDisabled,
      ignoreFirstNodeHighestBlockComment,
      firstUnorderedNodeDependentOnRight,
      newlinesBetweenValueGetter,
      commentAboveMissing,
      messageIds,
      sourceCode,
      options,
      context,
      nodes,
      right,
      left,
    })
  })
}
function getFirstUnorderedNodeDependentOn({
  nodesInCircularDependencies,
  nodes,
  node,
}) {
  let nodesDependentOnNode = nodes.filter(
    currentlyOrderedNode =>
      !nodesInCircularDependencies.has(currentlyOrderedNode) &&
      isNodeDependentOnOtherNode.isNodeDependentOnOtherNode(
        node,
        currentlyOrderedNode,
      ),
  )
  return nodesDependentOnNode.find(firstNodeDependentOnNode => {
    let currentIndexOfNode = nodes.indexOf(node)
    let currentIndexOfFirstNodeDependentOnNode = nodes.indexOf(
      firstNodeDependentOnNode,
    )
    return currentIndexOfFirstNodeDependentOnNode < currentIndexOfNode
  })
}
exports.reportAllErrors = reportAllErrors

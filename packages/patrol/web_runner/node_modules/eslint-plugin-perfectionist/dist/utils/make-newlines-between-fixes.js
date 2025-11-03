'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const getNewlinesBetweenOption = require('./get-newlines-between-option.js')
const getLinesBetween = require('./get-lines-between.js')
const getGroupIndex = require('./get-group-index.js')
const getNodeRange = require('./get-node-range.js')
function makeNewlinesBetweenFixes({
  newlinesBetweenValueGetter,
  sortedNodes,
  sourceCode,
  options,
  fixer,
  nodes,
}) {
  let fixes = []
  for (let i = 0; i < sortedNodes.length - 1; i++) {
    let sortingNode = nodes.at(i)
    let nextSortingNode = nodes.at(i + 1)
    let sortedSortingNode = sortedNodes.at(i)
    let nextSortedSortingNode = sortedNodes.at(i + 1)
    if (sortedSortingNode.partitionId !== nextSortedSortingNode.partitionId) {
      continue
    }
    let nodeGroupIndex = getGroupIndex.getGroupIndex(
      options.groups,
      sortedSortingNode,
    )
    let nextNodeGroupIndex = getGroupIndex.getGroupIndex(
      options.groups,
      nextSortedSortingNode,
    )
    if (nodeGroupIndex > nextNodeGroupIndex) {
      continue
    }
    let newlinesBetween = getNewlinesBetweenOption.getNewlinesBetweenOption({
      nextNodeGroupIndex,
      nodeGroupIndex,
      options,
    })
    newlinesBetween =
      newlinesBetweenValueGetter?.({
        computedNewlinesBetween: newlinesBetween,
        right: nextSortedSortingNode,
        left: sortedSortingNode,
      }) ?? newlinesBetween
    if (newlinesBetween === 'ignore') {
      continue
    }
    let currentNodeRange = getNodeRange.getNodeRange({
      node: sortingNode.node,
      sourceCode,
    })
    let nextNodeRangeStart = getNodeRange
      .getNodeRange({
        node: nextSortingNode.node,
        sourceCode,
      })
      .at(0)
    let linesBetweenMembers = getLinesBetween.getLinesBetween(
      sourceCode,
      sortingNode,
      nextSortingNode,
    )
    if (linesBetweenMembers === newlinesBetween) {
      continue
    }
    let rangeToReplace = [currentNodeRange.at(1), nextNodeRangeStart]
    let textBetweenNodes = sourceCode.text.slice(
      currentNodeRange.at(1),
      nextNodeRangeStart,
    )
    let rangeReplacement = computeRangeReplacement({
      isOnSameLine:
        sortingNode.node.loc.end.line === nextSortingNode.node.loc.start.line,
      textBetweenNodes,
      newlinesBetween,
    })
    if (rangeReplacement) {
      fixes.push(fixer.replaceTextRange(rangeToReplace, rangeReplacement))
    }
  }
  return fixes
}
function computeRangeReplacement({
  textBetweenNodes,
  newlinesBetween,
  isOnSameLine,
}) {
  let textBetweenNodesWithoutInvalidNewlines =
    getStringWithoutInvalidNewlines(textBetweenNodes)
  if (newlinesBetween === 0) {
    return textBetweenNodesWithoutInvalidNewlines
  }
  let rangeReplacement = textBetweenNodesWithoutInvalidNewlines
  for (let index = 0; index < newlinesBetween; index++) {
    rangeReplacement = addNewlineBeforeFirstNewline(rangeReplacement)
  }
  if (!isOnSameLine) {
    return rangeReplacement
  }
  return addNewlineBeforeFirstNewline(rangeReplacement)
}
function addNewlineBeforeFirstNewline(value) {
  let firstNewlineIndex = value.indexOf('\n')
  if (firstNewlineIndex === -1) {
    return `${value}
`
  }
  return `${value.slice(0, firstNewlineIndex)}
${value.slice(firstNewlineIndex)}`
}
function getStringWithoutInvalidNewlines(value) {
  return value.replaceAll(/\n\s*\n/gu, '\n').replaceAll(/\n+/gu, '\n')
}
exports.makeNewlinesBetweenFixes = makeNewlinesBetweenFixes

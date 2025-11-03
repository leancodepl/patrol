'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const getCommentAboveThatShouldExist = require('./get-comment-above-that-should-exist.js')
const isCommentAboveOption = require('./is-comment-above-option.js')
const getCommentsBefore = require('./get-comments-before.js')
const getGroupIndex = require('./get-group-index.js')
function makeCommentAboveFixes({ sortedNodes, sourceCode, options, fixer }) {
  let allAutoAddedComments = new Set(
    options.groups
      .filter(group => isCommentAboveOption.isCommentAboveOption(group))
      .map(({ commentAbove }) => commentAbove),
  )
  let fixes = []
  let firstNodeFixes = makeCommentAboveFix({
    nextSortedSortingNode: sortedNodes[0],
    sortedSortingNode: null,
    allAutoAddedComments,
    sourceCode,
    options,
    fixer,
  })
  fixes.push(...firstNodeFixes)
  for (let i = 0; i < sortedNodes.length - 1; i++) {
    let sortedSortingNode = sortedNodes.at(i)
    let nextSortedSortingNode = sortedNodes.at(i + 1)
    let nodeFixes = makeCommentAboveFix({
      nextSortedSortingNode,
      allAutoAddedComments,
      sortedSortingNode,
      sourceCode,
      options,
      fixer,
    })
    fixes.push(...nodeFixes)
  }
  return fixes
}
function makeCommentAboveFix({
  nextSortedSortingNode,
  allAutoAddedComments,
  sortedSortingNode,
  sourceCode,
  options,
  fixer,
}) {
  let leftGroupIndex = sortedSortingNode
    ? getGroupIndex.getGroupIndex(options.groups, sortedSortingNode)
    : -1
  let rightGroupIndex = getGroupIndex.getGroupIndex(
    options.groups,
    nextSortedSortingNode,
  )
  let commentAboveThatShouldExist =
    getCommentAboveThatShouldExist.getCommentAboveThatShouldExist({
      options: {
        ...options,
        groups: options.groups,
      },
      sortingNode: nextSortedSortingNode,
      rightGroupIndex,
      leftGroupIndex,
      sourceCode,
    })
  let commentsBefore = getCommentsBefore.getCommentsBefore({
    node: nextSortedSortingNode.node,
    sourceCode,
  })
  let autoAddedCommentsAboveToRemove = commentsBefore
    .filter(
      comment =>
        !commentAboveThatShouldExist?.comment ||
        comment.value.slice(1) !== commentAboveThatShouldExist.comment,
    )
    .filter(
      comment =>
        comment.type === 'Line' &&
        allAutoAddedComments.has(comment.value.slice(1)),
    )
  let fixes = []
  for (let autoAddedCommentAboveToRemove of autoAddedCommentsAboveToRemove) {
    let nextToken = sourceCode.getTokenAfter(autoAddedCommentAboveToRemove)
    fixes.push(
      fixer.removeRange([
        autoAddedCommentAboveToRemove.range[0],
        nextToken.range[0],
      ]),
    )
  }
  if (commentAboveThatShouldExist && !commentAboveThatShouldExist.exists) {
    let nodeToPutCommentBefore
    let isFirstToken = !sourceCode.getTokenBefore(nextSortedSortingNode.node)
    if (isFirstToken || !commentsBefore[0]) {
      nodeToPutCommentBefore = nextSortedSortingNode.node
    } else {
      ;[nodeToPutCommentBefore] = commentsBefore
    }
    fixes.push(
      fixer.insertTextBeforeRange(
        nodeToPutCommentBefore.range,
        `// ${commentAboveThatShouldExist.comment}
`,
      ),
    )
  }
  return fixes
}
exports.makeCommentAboveFixes = makeCommentAboveFixes

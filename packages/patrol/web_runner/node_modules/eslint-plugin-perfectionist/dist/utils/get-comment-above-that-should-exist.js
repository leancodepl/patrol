'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const isCommentAboveOption = require('./is-comment-above-option.js')
const getCommentsBefore = require('./get-comments-before.js')
function getCommentAboveThatShouldExist({
  rightGroupIndex,
  leftGroupIndex,
  sortingNode,
  sourceCode,
  options,
}) {
  if (leftGroupIndex !== null && leftGroupIndex >= rightGroupIndex) {
    return null
  }
  let groupAboveRight = options.groups[rightGroupIndex - 1]
  if (!isCommentAboveOption.isCommentAboveOption(groupAboveRight)) {
    return null
  }
  let matchingCommentsAbove = getCommentsBefore
    .getCommentsBefore({
      node: sortingNode.node,
      sourceCode,
    })
    .find(comment =>
      commentMatches(comment.value, groupAboveRight.commentAbove),
    )
  return {
    comment: groupAboveRight.commentAbove,
    exists: !!matchingCommentsAbove,
  }
}
function commentMatches(comment, expected) {
  return comment.toLowerCase().includes(expected.toLowerCase().trim())
}
exports.getCommentAboveThatShouldExist = getCommentAboveThatShouldExist

'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const isPartitionComment = require('./is-partition-comment.js')
const getCommentsBefore = require('./get-comments-before.js')
const getLinesBetween = require('./get-lines-between.js')
function shouldPartition({
  tokenValueToIgnoreBefore,
  lastSortingNode,
  sortingNode,
  sourceCode,
  options,
}) {
  let shouldPartitionByComment =
    options.partitionByComment &&
    hasPartitionComment({
      comments: getCommentsBefore.getCommentsBefore({
        tokenValueToIgnoreBefore,
        node: sortingNode.node,
        sourceCode,
      }),
      partitionByComment: options.partitionByComment,
    })
  if (shouldPartitionByComment) {
    return true
  }
  return !!(
    options.partitionByNewLine &&
    lastSortingNode &&
    getLinesBetween.getLinesBetween(sourceCode, lastSortingNode, sortingNode)
  )
}
function hasPartitionComment({ partitionByComment, comments }) {
  return comments.some(comment =>
    isPartitionComment.isPartitionComment({
      partitionByComment,
      comment,
    }),
  )
}
exports.shouldPartition = shouldPartition

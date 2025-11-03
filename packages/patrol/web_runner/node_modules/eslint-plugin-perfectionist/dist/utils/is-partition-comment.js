'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const types = require('@typescript-eslint/types')
const getEslintDisabledRules = require('./get-eslint-disabled-rules.js')
const matches = require('./matches.js')
function isPartitionComment({ partitionByComment, comment }) {
  if (
    getEslintDisabledRules.getEslintDisabledRules(comment.value) ||
    !partitionByComment
  ) {
    return false
  }
  let trimmedComment = comment.value.trim()
  if (
    Array.isArray(partitionByComment) ||
    typeof partitionByComment === 'boolean' ||
    typeof partitionByComment === 'string'
  ) {
    return isTrimmedCommentPartitionComment({
      partitionByComment,
      trimmedComment,
    })
  }
  let relevantPartitionByComment
  if (
    comment.type === types.AST_TOKEN_TYPES.Block &&
    'block' in partitionByComment
  ) {
    relevantPartitionByComment = partitionByComment.block
  }
  if (
    comment.type === types.AST_TOKEN_TYPES.Line &&
    'line' in partitionByComment
  ) {
    relevantPartitionByComment = partitionByComment.line
  }
  return (
    relevantPartitionByComment !== void 0 &&
    isTrimmedCommentPartitionComment({
      partitionByComment: relevantPartitionByComment,
      trimmedComment,
    })
  )
}
function isTrimmedCommentPartitionComment({
  partitionByComment,
  trimmedComment,
}) {
  if (typeof partitionByComment === 'boolean') {
    return partitionByComment
  }
  return matches.matches(trimmedComment, partitionByComment)
}
exports.isPartitionComment = isPartitionComment

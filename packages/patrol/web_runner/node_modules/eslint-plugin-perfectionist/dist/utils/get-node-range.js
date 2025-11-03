'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const utils = require('@typescript-eslint/utils')
const getEslintDisabledRules = require('./get-eslint-disabled-rules.js')
const isPartitionComment = require('./is-partition-comment.js')
const getCommentsBefore = require('./get-comments-before.js')
function getNodeRange({
  ignoreHighestBlockComment,
  sourceCode,
  options,
  node,
}) {
  let start = node.range.at(0)
  let end = node.range.at(1)
  if (utils.ASTUtils.isParenthesized(node, sourceCode)) {
    let bodyOpeningParen = sourceCode.getTokenBefore(
      node,
      utils.ASTUtils.isOpeningParenToken,
    )
    let bodyClosingParen = sourceCode.getTokenAfter(
      node,
      utils.ASTUtils.isClosingParenToken,
    )
    start = bodyOpeningParen.range.at(0)
    end = bodyClosingParen.range.at(1)
  }
  let comments = getCommentsBefore.getCommentsBefore({
    sourceCode,
    node,
  })
  let highestBlockComment = comments.find(comment => comment.type === 'Block')
  let relevantTopComment
  for (let i = comments.length - 1; i >= 0; i--) {
    let comment = comments[i]
    let eslintDisabledRules = getEslintDisabledRules.getEslintDisabledRules(
      comment.value,
    )
    if (
      isPartitionComment.isPartitionComment({
        partitionByComment: options?.partitionByComment ?? false,
        comment,
      }) ||
      eslintDisabledRules?.eslintDisableDirective === 'eslint-disable' ||
      eslintDisabledRules?.eslintDisableDirective === 'eslint-enable'
    ) {
      break
    }
    let previousCommentOrNodeStartLine =
      i === comments.length - 1
        ? node.loc.start.line
        : comments[i + 1].loc.start.line
    if (comment.loc.end.line !== previousCommentOrNodeStartLine - 1) {
      break
    }
    if (ignoreHighestBlockComment && comment === highestBlockComment) {
      break
    }
    relevantTopComment = comment
  }
  if (relevantTopComment) {
    start = relevantTopComment.range.at(0)
  }
  return [start, end]
}
exports.getNodeRange = getNodeRange

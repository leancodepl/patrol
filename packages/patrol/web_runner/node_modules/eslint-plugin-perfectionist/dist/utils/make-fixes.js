'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const makeNewlinesBetweenFixes = require('./make-newlines-between-fixes.js')
const makeCommentAfterFixes = require('./make-comment-after-fixes.js')
const makeCommentAboveFixes = require('./make-comment-above-fixes.js')
const makeOrderFixes = require('./make-order-fixes.js')
function makeFixes({
  ignoreFirstNodeHighestBlockComment,
  newlinesBetweenValueGetter,
  hasCommentAboveMissing,
  sortedNodes,
  sourceCode,
  options,
  fixer,
  nodes,
}) {
  let orderFixes = makeOrderFixes.makeOrderFixes({
    ignoreFirstNodeHighestBlockComment,
    sortedNodes,
    sourceCode,
    options,
    nodes,
    fixer,
  })
  let commentAfterFixes = makeCommentAfterFixes.makeCommentAfterFixes({
    sortedNodes,
    sourceCode,
    nodes,
    fixer,
  })
  if (commentAfterFixes.length > 0) {
    return [...orderFixes, ...commentAfterFixes]
  }
  if (options?.groups && options.newlinesBetween !== void 0) {
    let newlinesFixes = makeNewlinesBetweenFixes.makeNewlinesBetweenFixes({
      options: {
        ...options,
        newlinesBetween: options.newlinesBetween,
        groups: options.groups,
      },
      newlinesBetweenValueGetter,
      sortedNodes,
      sourceCode,
      fixer,
      nodes,
    })
    if (newlinesFixes.length > 0) {
      return [...orderFixes, ...newlinesFixes]
    }
  }
  if (orderFixes.length > 0) {
    return orderFixes
  }
  if (!hasCommentAboveMissing || !options?.groups) {
    return []
  }
  return makeCommentAboveFixes.makeCommentAboveFixes({
    options: {
      ...options,
      groups: options.groups,
    },
    sortedNodes,
    sourceCode,
    fixer,
  })
}
exports.makeFixes = makeFixes

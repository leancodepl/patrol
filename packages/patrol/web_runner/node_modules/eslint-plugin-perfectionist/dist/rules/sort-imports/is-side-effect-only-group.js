'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const isNewlinesBetweenOption = require('../../utils/is-newlines-between-option.js')
const isCommentAboveOption = require('../../utils/is-comment-above-option.js')
function isSideEffectOnlyGroup(group) {
  if (
    isNewlinesBetweenOption.isNewlinesBetweenOption(group) ||
    isCommentAboveOption.isCommentAboveOption(group)
  ) {
    return false
  }
  if (typeof group === 'string') {
    return group === 'side-effect' || group === 'side-effect-style'
  }
  return group.every(isSideEffectOnlyGroup)
}
exports.isSideEffectOnlyGroup = isSideEffectOnlyGroup

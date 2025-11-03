'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function isCommentAboveOption(groupOption) {
  return typeof groupOption === 'object' && 'commentAbove' in groupOption
}
exports.isCommentAboveOption = isCommentAboveOption

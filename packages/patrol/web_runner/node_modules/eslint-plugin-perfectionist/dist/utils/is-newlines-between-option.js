'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function isNewlinesBetweenOption(groupOption) {
  return typeof groupOption === 'object' && 'newlinesBetween' in groupOption
}
exports.isNewlinesBetweenOption = isNewlinesBetweenOption

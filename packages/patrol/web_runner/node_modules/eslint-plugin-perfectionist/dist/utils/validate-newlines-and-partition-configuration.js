'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const isNewlinesBetweenOption = require('./is-newlines-between-option.js')
function validateNewlinesAndPartitionConfiguration({
  partitionByNewLine,
  newlinesBetween,
  groups,
}) {
  if (!partitionByNewLine) {
    return
  }
  if (newlinesBetween !== 'ignore') {
    throw new Error(
      "The 'partitionByNewLine' and 'newlinesBetween' options cannot be used together",
    )
  }
  let hasNewlinesBetweenGroup = groups.some(group =>
    isNewlinesBetweenOption.isNewlinesBetweenOption(group),
  )
  if (hasNewlinesBetweenGroup) {
    throw new Error(
      "'newlinesBetween' objects can not be used in 'groups' alongside 'partitionByNewLine'",
    )
  }
}
exports.validateNewlinesAndPartitionConfiguration =
  validateNewlinesAndPartitionConfiguration

'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const getNewlinesBetweenOption = require('./get-newlines-between-option.js')
const getLinesBetween = require('./get-lines-between.js')
function getNewlinesBetweenErrors({
  newlinesBetweenValueGetter,
  missedSpacingError,
  extraSpacingError,
  rightGroupIndex,
  leftGroupIndex,
  sourceCode,
  options,
  right,
  left,
}) {
  if (
    leftGroupIndex > rightGroupIndex ||
    left.partitionId !== right.partitionId
  ) {
    return []
  }
  let newlinesBetween = getNewlinesBetweenOption.getNewlinesBetweenOption({
    nextNodeGroupIndex: rightGroupIndex,
    nodeGroupIndex: leftGroupIndex,
    options,
  })
  newlinesBetween =
    newlinesBetweenValueGetter?.({
      computedNewlinesBetween: newlinesBetween,
      right,
      left,
    }) ?? newlinesBetween
  let numberOfEmptyLinesBetween = getLinesBetween.getLinesBetween(
    sourceCode,
    left,
    right,
  )
  if (newlinesBetween === 'ignore') {
    return []
  }
  if (numberOfEmptyLinesBetween < newlinesBetween) {
    return [missedSpacingError]
  }
  if (numberOfEmptyLinesBetween > newlinesBetween) {
    return [extraSpacingError]
  }
  return []
}
exports.getNewlinesBetweenErrors = getNewlinesBetweenErrors

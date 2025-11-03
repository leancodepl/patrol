'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function validateObjectsInsideGroups({ groups }) {
  let isPreviousElementObject = false
  for (let group of groups) {
    if (typeof group === 'string' || Array.isArray(group)) {
      isPreviousElementObject = false
      continue
    }
    if (isPreviousElementObject) {
      throw new Error(
        'Consecutive objects (`newlinesBetween` or `commentAbove` are not allowed: merge them into a single object',
      )
    }
    isPreviousElementObject = true
  }
}
exports.validateObjectsInsideGroups = validateObjectsInsideGroups

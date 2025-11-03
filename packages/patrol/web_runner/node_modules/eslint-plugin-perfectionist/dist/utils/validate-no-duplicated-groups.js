'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const isNewlinesBetweenOption = require('./is-newlines-between-option.js')
const isCommentAboveOption = require('./is-comment-above-option.js')
function validateNoDuplicatedGroups({ groups }) {
  let flattenGroups = groups.flat()
  let seenGroups = /* @__PURE__ */ new Set()
  let duplicatedGroups = /* @__PURE__ */ new Set()
  for (let group of flattenGroups) {
    if (
      isNewlinesBetweenOption.isNewlinesBetweenOption(group) ||
      isCommentAboveOption.isCommentAboveOption(group)
    ) {
      continue
    }
    if (seenGroups.has(group)) {
      duplicatedGroups.add(group)
    } else {
      seenGroups.add(group)
    }
  }
  if (duplicatedGroups.size > 0) {
    throw new Error(`Duplicated group(s): ${[...duplicatedGroups].join(', ')}`)
  }
}
exports.validateNoDuplicatedGroups = validateNoDuplicatedGroups

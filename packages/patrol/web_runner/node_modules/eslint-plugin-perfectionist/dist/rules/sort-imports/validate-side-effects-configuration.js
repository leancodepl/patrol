'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const isSideEffectOnlyGroup = require('./is-side-effect-only-group.js')
function validateSideEffectsConfiguration({ sortSideEffects, groups }) {
  if (sortSideEffects) {
    return
  }
  let hasInvalidGroup = groups
    .filter(group => Array.isArray(group))
    .some(
      nestedGroup =>
        !isSideEffectOnlyGroup.isSideEffectOnlyGroup(nestedGroup) &&
        nestedGroup.some(
          subGroup =>
            subGroup === 'side-effect' || subGroup === 'side-effect-style',
        ),
    )
  if (hasInvalidGroup) {
    throw new Error(
      "Side effect groups cannot be nested with non side effect groups when 'sortSideEffects' is 'false'.",
    )
  }
}
exports.validateSideEffectsConfiguration = validateSideEffectsConfiguration

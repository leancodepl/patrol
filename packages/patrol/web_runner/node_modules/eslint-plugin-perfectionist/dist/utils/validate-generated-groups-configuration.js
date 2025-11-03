'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const validateObjectsInsideGroups = require('./validate-objects-inside-groups.js')
const validateNoDuplicatedGroups = require('./validate-no-duplicated-groups.js')
function validateGeneratedGroupsConfiguration({
  selectors,
  modifiers,
  options,
}) {
  let availableCustomGroupNames = new Set(
    Array.isArray(options.customGroups)
      ? options.customGroups.map(customGroup => customGroup.groupName)
      : Object.keys(options.customGroups),
  )
  let invalidGroups = options.groups
    .flat()
    .filter(group => typeof group === 'string')
    .filter(
      group =>
        !isPredefinedGroup(selectors, modifiers, group) &&
        !availableCustomGroupNames.has(group),
    )
  if (invalidGroups.length > 0) {
    throw new Error(`Invalid group(s): ${invalidGroups.join(', ')}`)
  }
  validateNoDuplicatedGroups.validateNoDuplicatedGroups(options)
  validateObjectsInsideGroups.validateObjectsInsideGroups(options)
}
function isPredefinedGroup(allSelectors, allModifiers, input) {
  if (input === 'unknown') {
    return true
  }
  let elementsSeparatedWithDash = input.split('-')
  let longestAllowedSelector = computeLongestAllowedWord({
    allowedValues: allSelectors,
    elementsSeparatedWithDash,
  })
  if (!longestAllowedSelector) {
    return false
  }
  let modifiersToParse = elementsSeparatedWithDash.slice(
    0,
    -longestAllowedSelector.wordCount,
  )
  let parsedModifiers = /* @__PURE__ */ new Set()
  while (modifiersToParse.length > 0) {
    let longestAllowedModifier = computeLongestAllowedWord({
      elementsSeparatedWithDash: modifiersToParse,
      allowedValues: allModifiers,
    })
    if (!longestAllowedModifier) {
      return false
    }
    if (parsedModifiers.has(longestAllowedModifier.word)) {
      return false
    }
    parsedModifiers.add(longestAllowedModifier.word)
    modifiersToParse = modifiersToParse.slice(
      0,
      -longestAllowedModifier.wordCount,
    )
  }
  return true
}
function computeLongestAllowedWord({
  elementsSeparatedWithDash,
  allowedValues,
}) {
  let match = [
    { word: elementsSeparatedWithDash.slice(-3).join('-'), wordCount: 3 },
    { word: elementsSeparatedWithDash.slice(-2).join('-'), wordCount: 2 },
    { word: elementsSeparatedWithDash.at(-1), wordCount: 1 },
  ]
    .filter(({ wordCount }) => elementsSeparatedWithDash.length >= wordCount)
    .find(({ word }) => word && allowedValues.includes(word))
  if (!match) {
    return null
  }
  return match
}
exports.validateGeneratedGroupsConfiguration =
  validateGeneratedGroupsConfiguration

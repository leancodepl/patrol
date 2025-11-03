'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const getArrayCombinations = require('./get-array-combinations.js')
function generatePredefinedGroups({ selectors, modifiers, cache }) {
  let modifiersAndSelectorsKey = `${modifiers.join('&')}/${selectors.join('&')}`
  let cachedValue = cache.get(modifiersAndSelectorsKey)
  if (cachedValue) {
    return cachedValue
  }
  let allModifiersCombinations = []
  for (let i = modifiers.length; i > 0; i--) {
    allModifiersCombinations = [
      ...allModifiersCombinations,
      ...getArrayCombinations.getArrayCombinations(modifiers, i),
    ]
  }
  let allModifiersCombinationPermutations = allModifiersCombinations.flatMap(
    result => getPermutations(result),
  )
  let returnValue = []
  for (let selector of selectors) {
    returnValue = [
      ...returnValue,
      ...allModifiersCombinationPermutations.map(
        modifiersCombinationPermutation =>
          [...modifiersCombinationPermutation, selector].join('-'),
      ),
      selector,
    ]
  }
  cache.set(modifiersAndSelectorsKey, returnValue)
  return returnValue
}
function getPermutations(elements) {
  let result = []
  function backtrack(first) {
    if (first === elements.length) {
      result.push([...elements])
      return
    }
    for (let i = first; i < elements.length; i++) {
      ;[elements[first], elements[i]] = [elements[i], elements[first]]
      backtrack(first + 1)
      ;[elements[first], elements[i]] = [elements[i], elements[first]]
    }
  }
  backtrack(0)
  return result
}
exports.generatePredefinedGroups = generatePredefinedGroups

'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function getArrayCombinations(array, number) {
  let result = []
  function backtrack(start, comb) {
    if (comb.length === number) {
      result.push([...comb])
      return
    }
    for (let i = start; i < array.length; i++) {
      comb.push(array[i])
      backtrack(i + 1, comb)
      comb.pop()
    }
  }
  backtrack(0, [])
  return result
}
exports.getArrayCombinations = getArrayCombinations

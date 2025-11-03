'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const naturalOrderby = require('natural-orderby')
const convertBooleanToSign = require('./convert-boolean-to-sign.js')
const unreachableCaseError = require('./unreachable-case-error.js')
let alphabetCache = /* @__PURE__ */ new Map()
function compare({
  fallbackSortNodeValueGetter,
  nodeValueGetter,
  options,
  a,
  b,
}) {
  if (options.type === 'unsorted') {
    return 0
  }
  let finalNodeValueGetter = nodeValueGetter ?? (node => node.name)
  let compareValue = computeCompareValue({
    nodeValueGetter: finalNodeValueGetter,
    options,
    a,
    b,
  })
  if (compareValue) {
    return compareValue
  }
  let { fallbackSort, order } = options
  return computeCompareValue({
    options: {
      ...options,
      order: fallbackSort.order ?? order,
      type: fallbackSort.type,
    },
    nodeValueGetter: fallbackSortNodeValueGetter ?? finalNodeValueGetter,
    a,
    b,
  })
}
function getCustomSortingFunction(
  { specialCharacters, ignoreCase, alphabet },
  nodeValueGetter,
) {
  let formatString = getFormatStringFunction(ignoreCase, specialCharacters)
  let indexByCharacters = alphabetCache.get(alphabet)
  if (!indexByCharacters) {
    indexByCharacters = /* @__PURE__ */ new Map()
    for (let [index, character] of [...alphabet].entries()) {
      indexByCharacters.set(character, index)
    }
    alphabetCache.set(alphabet, indexByCharacters)
  }
  return (aNode, bNode) => {
    let aValue = formatString(nodeValueGetter(aNode))
    let bValue = formatString(nodeValueGetter(bNode))
    let minLength = Math.min(aValue.length, bValue.length)
    for (let i = 0; i < minLength; i++) {
      let aCharacter = aValue[i]
      let bCharacter = bValue[i]
      let indexOfA = indexByCharacters.get(aCharacter)
      let indexOfB = indexByCharacters.get(bCharacter)
      indexOfA ??= Infinity
      indexOfB ??= Infinity
      if (indexOfA !== indexOfB) {
        return convertBooleanToSign.convertBooleanToSign(
          indexOfA - indexOfB > 0,
        )
      }
    }
    if (aValue.length === bValue.length) {
      return 0
    }
    return convertBooleanToSign.convertBooleanToSign(
      aValue.length - bValue.length > 0,
    )
  }
}
function computeCompareValue({ nodeValueGetter, options, a, b }) {
  let sortingFunction
  switch (options.type) {
    case 'alphabetical':
      sortingFunction = getAlphabeticalSortingFunction(options, nodeValueGetter)
      break
    case 'line-length':
      sortingFunction = getLineLengthSortingFunction()
      break
    case 'unsorted':
      return 0
    case 'natural':
      sortingFunction = getNaturalSortingFunction(options, nodeValueGetter)
      break
    case 'custom':
      sortingFunction = getCustomSortingFunction(options, nodeValueGetter)
      break
    /* v8 ignore next 2 */
    default:
      throw new unreachableCaseError.UnreachableCaseError(options.type)
  }
  return (
    convertBooleanToSign.convertBooleanToSign(options.order === 'asc') *
    sortingFunction(a, b)
  )
}
function getFormatStringFunction(ignoreCase, specialCharacters) {
  return value => {
    let valueToCompare = value
    if (ignoreCase) {
      valueToCompare = valueToCompare.toLowerCase()
    }
    switch (specialCharacters) {
      case 'remove':
        valueToCompare = valueToCompare.replaceAll(
          /[^a-z\u{C0}-\u{24F}\u{1E00}-\u{1EFF}]+/giu,
          '',
        )
        break
      case 'trim':
        valueToCompare = valueToCompare.replaceAll(
          /^[^a-z\u{C0}-\u{24F}\u{1E00}-\u{1EFF}]+/giu,
          '',
        )
        break
      case 'keep':
        break
      /* v8 ignore next 2 */
      default:
        throw new unreachableCaseError.UnreachableCaseError(specialCharacters)
    }
    return valueToCompare.replaceAll(/\s/gu, '')
  }
}
function getNaturalSortingFunction(
  { specialCharacters, ignoreCase, locales },
  nodeValueGetter,
) {
  let naturalCompare = naturalOrderby.compare({
    locale: locales.toString(),
  })
  let formatString = getFormatStringFunction(ignoreCase, specialCharacters)
  return (aNode, bNode) =>
    naturalCompare(
      formatString(nodeValueGetter(aNode)),
      formatString(nodeValueGetter(bNode)),
    )
}
function getAlphabeticalSortingFunction(
  { specialCharacters, ignoreCase, locales },
  nodeValueGetter,
) {
  let formatString = getFormatStringFunction(ignoreCase, specialCharacters)
  return (aNode, bNode) =>
    formatString(nodeValueGetter(aNode)).localeCompare(
      formatString(nodeValueGetter(bNode)),
      locales,
    )
}
function getLineLengthSortingFunction() {
  return (aNode, bNode) => {
    let aSize = aNode.size
    let bSize = bNode.size
    return aSize - bSize
  }
}
exports.compare = compare

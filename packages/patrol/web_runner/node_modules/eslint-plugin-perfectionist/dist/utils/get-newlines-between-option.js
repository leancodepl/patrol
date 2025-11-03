'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const isNewlinesBetweenOption = require('./is-newlines-between-option.js')
const unreachableCaseError = require('./unreachable-case-error.js')
function getNewlinesBetweenOption({
  nextNodeGroupIndex,
  nodeGroupIndex,
  options,
}) {
  let globalNewlinesBetweenOption = getGlobalNewlinesBetweenOption({
    newlinesBetween: options.newlinesBetween,
    nextNodeGroupIndex,
    nodeGroupIndex,
  })
  let nodeGroup = options.groups[nodeGroupIndex]
  let nextNodeGroup = options.groups[nextNodeGroupIndex]
  if (
    Array.isArray(options.customGroups) &&
    typeof nodeGroup === 'string' &&
    typeof nextNodeGroup === 'string' &&
    nodeGroup === nextNodeGroup
  ) {
    let nodeCustomGroup = options.customGroups.find(
      customGroup => customGroup.groupName === nodeGroup,
    )
    let nextNodeCustomGroup = options.customGroups.find(
      customGroup => customGroup.groupName === nextNodeGroup,
    )
    if (
      nodeCustomGroup &&
      nextNodeCustomGroup &&
      nodeCustomGroup.groupName === nextNodeCustomGroup.groupName
    ) {
      if (nodeCustomGroup.newlinesInside !== void 0) {
        return convertNewlinesBetweenOptionToNumber(
          nodeCustomGroup.newlinesInside,
        )
      }
      return globalNewlinesBetweenOption
    }
  }
  if (nextNodeGroupIndex >= nodeGroupIndex + 2) {
    if (nextNodeGroupIndex === nodeGroupIndex + 2) {
      let groupBetween = options.groups[nodeGroupIndex + 1]
      if (isNewlinesBetweenOption.isNewlinesBetweenOption(groupBetween)) {
        return convertNewlinesBetweenOptionToNumber(
          groupBetween.newlinesBetween,
        )
      }
    } else {
      let relevantGroups = options.groups.slice(
        nodeGroupIndex,
        nextNodeGroupIndex + 1,
      )
      let groupsWithAllNewlinesBetween = buildGroupsWithAllNewlinesBetween(
        relevantGroups,
        globalNewlinesBetweenOption,
      )
      let newlinesBetweenOptions = new Set(
        groupsWithAllNewlinesBetween
          .filter(isNewlinesBetweenOption.isNewlinesBetweenOption)
          .map(group => group.newlinesBetween)
          .map(convertNewlinesBetweenOptionToNumber),
      )
      let numberNewlinesBetween = [...newlinesBetweenOptions].filter(
        option => typeof option === 'number',
      )
      let maxNewlinesBetween =
        numberNewlinesBetween.length > 0
          ? Math.max(...numberNewlinesBetween)
          : null
      if (maxNewlinesBetween !== null && maxNewlinesBetween >= 1) {
        return maxNewlinesBetween
      }
      if (newlinesBetweenOptions.has('ignore')) {
        return 'ignore'
      }
      if (maxNewlinesBetween === 0) {
        return 0
      }
    }
  }
  return globalNewlinesBetweenOption
}
function buildGroupsWithAllNewlinesBetween(
  groups,
  globalNewlinesBetweenOption,
) {
  let returnValue = []
  for (let i = 0; i < groups.length; i++) {
    let group = groups[i]
    if (!isNewlinesBetweenOption.isNewlinesBetweenOption(group)) {
      let previousGroup = groups[i - 1]
      if (
        previousGroup &&
        !isNewlinesBetweenOption.isNewlinesBetweenOption(previousGroup)
      ) {
        returnValue.push({
          newlinesBetween: globalNewlinesBetweenOption,
        })
      }
    }
    returnValue.push(group)
  }
  return returnValue
}
function getGlobalNewlinesBetweenOption({
  nextNodeGroupIndex,
  newlinesBetween,
  nodeGroupIndex,
}) {
  let numberNewlinesBetween =
    convertNewlinesBetweenOptionToNumber(newlinesBetween)
  if (numberNewlinesBetween === 'ignore') {
    return 'ignore'
  }
  if (nodeGroupIndex === nextNodeGroupIndex) {
    return 0
  }
  return numberNewlinesBetween
}
function convertNewlinesBetweenOptionToNumber(newlinesBetween) {
  if (typeof newlinesBetween === 'number') {
    return newlinesBetween
  }
  switch (newlinesBetween) {
    case 'ignore':
      return 'ignore'
    case 'always':
      return 1
    case 'never':
      return 0
    /* v8 ignore next 2 */
    default:
      throw new unreachableCaseError.UnreachableCaseError(newlinesBetween)
  }
}
exports.getNewlinesBetweenOption = getNewlinesBetweenOption

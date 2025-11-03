'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function getCustomGroupsCompareOptions(options, groupIndex) {
  let { customGroups, fallbackSort, groups, order, type } = options
  if (Array.isArray(customGroups)) {
    let group = groups[groupIndex]
    let customGroup =
      typeof group === 'string'
        ? customGroups.find(currentGroup => group === currentGroup.groupName)
        : null
    if (customGroup) {
      fallbackSort = {
        type: customGroup.fallbackSort?.type ?? fallbackSort.type,
      }
      let fallbackOrder = customGroup.fallbackSort?.order ?? fallbackSort.order
      if (fallbackOrder) {
        fallbackSort.order = fallbackOrder
      }
      order = customGroup.order ?? order
      type = customGroup.type ?? type
    }
  }
  return {
    fallbackSort,
    order,
    type,
  }
}
function buildGetCustomGroupOverriddenOptionsFunction(options) {
  return groupIndex => ({
    options: getCustomGroupOverriddenOptions({
      groupIndex,
      options,
    }),
  })
}
function getCustomGroupOverriddenOptions({ groupIndex, options }) {
  return {
    ...options,
    ...getCustomGroupsCompareOptions(options, groupIndex),
  }
}
exports.buildGetCustomGroupOverriddenOptionsFunction =
  buildGetCustomGroupOverriddenOptionsFunction
exports.getCustomGroupOverriddenOptions = getCustomGroupOverriddenOptions
exports.getCustomGroupsCompareOptions = getCustomGroupsCompareOptions

'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const getCustomGroupsCompareOptions$1 = require('../../utils/get-custom-groups-compare-options.js')
const buildNodeValueGetter = require('./build-node-value-getter.js')
function getCustomGroupsCompareOptions(options, groupIndex) {
  let baseCompareOptions =
    getCustomGroupsCompareOptions$1.getCustomGroupsCompareOptions(
      options,
      groupIndex,
    )
  let { fallbackSort, customGroups, sortBy, groups } = options
  let fallbackSortBy = fallbackSort.sortBy
  if (Array.isArray(customGroups)) {
    let group = groups[groupIndex]
    let customGroup =
      typeof group === 'string'
        ? customGroups.find(currentGroup => group === currentGroup.groupName)
        : null
    if (customGroup) {
      fallbackSortBy = customGroup.fallbackSort?.sortBy ?? fallbackSortBy
      if ('sortBy' in customGroup && customGroup.sortBy) {
        ;({ sortBy } = customGroup)
      }
    }
  }
  return {
    options: {
      ...baseCompareOptions,
      fallbackSort: {
        ...baseCompareOptions.fallbackSort,
        sortBy: fallbackSortBy,
      },
      sortBy,
    },
    fallbackSortNodeValueGetter: fallbackSortBy
      ? buildNodeValueGetter.buildNodeValueGetter(fallbackSortBy)
      : null,
    nodeValueGetter: buildNodeValueGetter.buildNodeValueGetter(sortBy),
  }
}
exports.getCustomGroupsCompareOptions = getCustomGroupsCompareOptions

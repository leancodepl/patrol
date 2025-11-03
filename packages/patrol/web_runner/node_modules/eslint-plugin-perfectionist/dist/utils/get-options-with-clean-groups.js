'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function getOptionsWithCleanGroups(options) {
  return {
    ...options,
    groups: options.groups
      .filter(group => !Array.isArray(group) || group.length > 0)
      .map(group =>
        Array.isArray(group) ? getCleanedNestedGroups(group) : group,
      ),
  }
}
function getCleanedNestedGroups(nestedGroup) {
  return nestedGroup.length === 1 && nestedGroup[0]
    ? nestedGroup[0]
    : nestedGroup
}
exports.getOptionsWithCleanGroups = getOptionsWithCleanGroups

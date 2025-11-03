'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const matches = require('./matches.js')
function computeGroup({ customGroupMatcher, predefinedGroups, options, name }) {
  let group
  let groupsSet = new Set(options.groups.flat())
  function defineGroup(value) {
    if (Array.isArray(value)) {
      return value.some(defineGroup)
    }
    if (group || !groupsSet.has(value)) {
      return false
    }
    group = value
    return true
  }
  if (options.customGroups) {
    if (Array.isArray(options.customGroups)) {
      for (let customGroup of options.customGroups) {
        if (customGroupMatcher?.(customGroup)) {
          let groupDefined = defineGroup(customGroup.groupName)
          if (groupDefined) {
            break
          }
        }
      }
    } else if (name) {
      for (let [key, pattern] of Object.entries(options.customGroups)) {
        if (matches.matches(name, pattern)) {
          let groupDefined = defineGroup(key)
          if (groupDefined) {
            break
          }
        }
      }
    }
  }
  defineGroup(predefinedGroups)
  return group ?? 'unknown'
}
exports.computeGroup = computeGroup

'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function buildNodeValueGetter(sortBy) {
  return sortBy === 'value' ? node => node.value ?? '' : null
}
exports.buildNodeValueGetter = buildNodeValueGetter

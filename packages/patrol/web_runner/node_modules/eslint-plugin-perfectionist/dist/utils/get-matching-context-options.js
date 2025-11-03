'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const matches = require('./matches.js')
function getMatchingContextOptions({ contextOptions, nodeNames }) {
  return contextOptions.filter(options => {
    let allNamesMatchPattern = options.useConfigurationIf?.allNamesMatchPattern
    return (
      !allNamesMatchPattern ||
      nodeNames.every(nodeName =>
        matches.matches(nodeName, allNamesMatchPattern),
      )
    )
  })
}
exports.getMatchingContextOptions = getMatchingContextOptions

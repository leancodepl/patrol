'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function isNodeEslintDisabled(node, eslintDisabledLines) {
  return eslintDisabledLines.includes(node.loc.start.line)
}
exports.isNodeEslintDisabled = isNodeEslintDisabled

'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function rangeToDiff(node, sourceCode) {
  let nodeText = sourceCode.getText(node)
  let endsWithCommaOrSemicolon =
    nodeText.endsWith(';') || nodeText.endsWith(',')
  let [from, to] = node.range
  return to - from - (endsWithCommaOrSemicolon ? 1 : 0)
}
exports.rangeToDiff = rangeToDiff

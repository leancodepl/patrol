'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function getLinesBetween(source, left, right) {
  let linesBetween = source.lines.slice(
    left.node.loc.end.line,
    right.node.loc.start.line - 1,
  )
  return linesBetween.filter(line => line.trim().length === 0).length
}
exports.getLinesBetween = getLinesBetween

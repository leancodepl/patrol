'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function makeSingleNodeCommentAfterFixes({
  sortedNode,
  sourceCode,
  fixer,
  node,
}) {
  let commentAfter = getCommentAfter(sortedNode, sourceCode)
  let areNodesOnSameLine = node.loc.start.line === sortedNode.loc.end.line
  if (!commentAfter || areNodesOnSameLine) {
    return []
  }
  let fixes = []
  let tokenBefore = sourceCode.getTokenBefore(commentAfter)
  let range = [tokenBefore.range.at(1), commentAfter.range.at(1)]
  fixes.push(fixer.replaceTextRange(range, ''))
  let tokenAfterNode = sourceCode.getTokenAfter(node)
  fixes.push(
    fixer.insertTextAfter(
      tokenAfterNode?.loc.end.line === node.loc.end.line
        ? tokenAfterNode
        : node,
      sourceCode.text.slice(...range),
    ),
  )
  return fixes
}
function getCommentAfter(node, source) {
  let token = source.getTokenAfter(node, {
    filter: ({ value, type }) =>
      type !== 'Punctuator' || ![',', ';', ':'].includes(value),
    includeComments: true,
  })
  if (
    (token?.type === 'Block' || token?.type === 'Line') &&
    node.loc.end.line === token.loc.end.line
  ) {
    return token
  }
  return null
}
exports.makeSingleNodeCommentAfterFixes = makeSingleNodeCommentAfterFixes

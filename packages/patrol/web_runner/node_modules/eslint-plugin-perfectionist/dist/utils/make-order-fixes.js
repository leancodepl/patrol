'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const getNodeRange = require('./get-node-range.js')
function makeOrderFixes({
  ignoreFirstNodeHighestBlockComment,
  sortedNodes,
  sourceCode,
  options,
  fixer,
  nodes,
}) {
  let fixes = []
  for (let max = nodes.length, i = 0; i < max; i++) {
    let sortingNode = nodes.at(i)
    let sortedSortingNode = sortedNodes.at(i)
    let { node } = sortingNode
    let { addSafetySemicolonWhenInline, node: sortedNode } = sortedSortingNode
    let isNodeFirstNode = node === nodes.at(0).node
    let isSortedNodeFirstNode = sortedNode === nodes.at(0).node
    if (node === sortedNode) {
      continue
    }
    let sortedNodeCode = sourceCode.text.slice(
      ...getNodeRange.getNodeRange({
        ignoreHighestBlockComment:
          ignoreFirstNodeHighestBlockComment && isSortedNodeFirstNode,
        node: sortedNode,
        sourceCode,
        options,
      }),
    )
    let sortedNodeText = sourceCode.getText(sortedNode)
    let tokensAfter = sourceCode.getTokensAfter(node, {
      includeComments: false,
      count: 1,
    })
    let nextToken = tokensAfter.at(0)
    let sortedNextNodeEndsWithSafeCharacter =
      sortedNodeText.endsWith(';') || sortedNodeText.endsWith(',')
    let isNextTokenOnSameLineAsNode =
      nextToken?.loc.start.line === node.loc.end.line
    let isNextTokenSafeCharacter =
      nextToken?.value === ';' || nextToken?.value === ','
    if (
      addSafetySemicolonWhenInline &&
      isNextTokenOnSameLineAsNode &&
      !sortedNextNodeEndsWithSafeCharacter &&
      !isNextTokenSafeCharacter
    ) {
      sortedNodeCode += ';'
    }
    fixes.push(
      fixer.replaceTextRange(
        getNodeRange.getNodeRange({
          ignoreHighestBlockComment:
            ignoreFirstNodeHighestBlockComment && isNodeFirstNode,
          sourceCode,
          options,
          node,
        }),
        sortedNodeCode,
      ),
    )
  }
  return fixes
}
exports.makeOrderFixes = makeOrderFixes

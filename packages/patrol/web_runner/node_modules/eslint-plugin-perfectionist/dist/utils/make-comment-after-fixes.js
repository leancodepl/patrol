'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const makeSingleNodeCommentAfterFixes = require('./make-single-node-comment-after-fixes.js')
function makeCommentAfterFixes({ sortedNodes, sourceCode, fixer, nodes }) {
  let fixes = []
  for (let max = nodes.length, i = 0; i < max; i++) {
    let sortingNode = nodes.at(i)
    let sortedSortingNode = sortedNodes.at(i)
    let { node } = sortingNode
    let { node: sortedNode } = sortedSortingNode
    if (node === sortedNode) {
      continue
    }
    fixes = [
      ...fixes,
      ...makeSingleNodeCommentAfterFixes.makeSingleNodeCommentAfterFixes({
        sortedNode,
        sourceCode,
        fixer,
        node,
      }),
    ]
  }
  return fixes
}
exports.makeCommentAfterFixes = makeCommentAfterFixes

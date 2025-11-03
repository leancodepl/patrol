'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function getCommentsBefore({ tokenValueToIgnoreBefore, sourceCode, node }) {
  let commentsBefore = getRelevantCommentsBeforeNodeOrToken(sourceCode, node)
  let tokenBeforeNode = sourceCode.getTokenBefore(node)
  if (
    commentsBefore.length > 0 ||
    !tokenValueToIgnoreBefore ||
    tokenBeforeNode?.value !== tokenValueToIgnoreBefore
  ) {
    return commentsBefore
  }
  return getRelevantCommentsBeforeNodeOrToken(sourceCode, tokenBeforeNode)
}
function getRelevantCommentsBeforeNodeOrToken(source, node) {
  return source
    .getCommentsBefore(node)
    .filter(comment => !isShebangComment(comment))
    .filter(comment => {
      let tokenBeforeComment = source.getTokenBefore(comment)
      return tokenBeforeComment?.loc.end.line !== comment.loc.end.line
    })
}
function isShebangComment(comment) {
  return comment.type === 'Shebang' || comment.type === 'Hashbang'
}
exports.getCommentsBefore = getCommentsBefore

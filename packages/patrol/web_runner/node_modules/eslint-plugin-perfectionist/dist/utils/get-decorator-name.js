'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function getDecoratorName({ sourceCode, decorator }) {
  let fullName = sourceCode.getText(decorator)
  if (fullName.startsWith('@')) {
    fullName = fullName.slice(1)
  }
  return fullName.split('(')[0]
}
exports.getDecoratorName = getDecoratorName

'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const getEslintDisabledRules = require('./get-eslint-disabled-rules.js')
const unreachableCaseError = require('./unreachable-case-error.js')
function getEslintDisabledLines(props) {
  let { sourceCode, ruleName } = props
  let returnValue = []
  let lineRulePermanentlyDisabled = null
  for (let comment of sourceCode.getAllComments()) {
    let eslintDisabledRules = getEslintDisabledRules.getEslintDisabledRules(
      comment.value,
    )
    if (!eslintDisabledRules) {
      continue
    }
    let includesRule =
      eslintDisabledRules.rules === 'all' ||
      eslintDisabledRules.rules.includes(ruleName)
    if (!includesRule) {
      continue
    }
    switch (eslintDisabledRules.eslintDisableDirective) {
      case 'eslint-disable-next-line':
        returnValue.push(comment.loc.end.line + 1)
        continue
      case 'eslint-disable-line':
        returnValue.push(comment.loc.start.line)
        continue
      case 'eslint-disable':
        lineRulePermanentlyDisabled ??= comment.loc.start.line
        break
      case 'eslint-enable':
        if (!lineRulePermanentlyDisabled) {
          continue
        }
        returnValue.push(
          ...createArrayFromTo(
            lineRulePermanentlyDisabled + 1,
            comment.loc.start.line,
          ),
        )
        lineRulePermanentlyDisabled = null
        break
      /* v8 ignore next 4 */
      default:
        throw new unreachableCaseError.UnreachableCaseError(
          eslintDisabledRules.eslintDisableDirective,
        )
    }
  }
  return returnValue
}
function createArrayFromTo(i, index) {
  return Array.from({ length: index - i + 1 }, (_, item) => i + item)
}
exports.getEslintDisabledLines = getEslintDisabledLines

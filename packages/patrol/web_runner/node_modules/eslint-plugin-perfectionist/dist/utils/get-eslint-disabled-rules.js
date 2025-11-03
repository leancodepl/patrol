'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
let eslintDisableDirectives = [
  'eslint-disable',
  'eslint-enable',
  'eslint-disable-line',
  'eslint-disable-next-line',
]
function getEslintDisabledRules(comment) {
  for (let eslintDisableDirective of eslintDisableDirectives) {
    let disabledRules = getEslintDisabledRulesByType(
      comment,
      eslintDisableDirective,
    )
    if (disabledRules) {
      return {
        eslintDisableDirective,
        rules: disabledRules,
      }
    }
  }
  return null
}
function getEslintDisabledRulesByType(comment, eslintDisableDirective) {
  let trimmedCommentValue = comment.trim()
  if (eslintDisableDirective === trimmedCommentValue) {
    return 'all'
  }
  let regexp = new RegExp(`^${eslintDisableDirective} ((?:.|\\s)*)$`)
  let disabledRulesMatch = trimmedCommentValue.match(regexp)
  let disableRulesMatchValue = disabledRulesMatch?.[1]
  if (!disableRulesMatchValue) {
    return null
  }
  return disableRulesMatchValue
    .split(',')
    .map(rule => rule.trim())
    .filter(rule => !!rule)
}
exports.getEslintDisabledRules = getEslintDisabledRules

'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const utils = require('@typescript-eslint/utils')
let createEslintRule = utils.ESLintUtils.RuleCreator(
  ruleName => `https://perfectionist.dev/rules/${ruleName}`,
)
exports.createEslintRule = createEslintRule

const nx = require("@nx/eslint-plugin")
const { base, imports, a11y } = require("@leancodepl/eslint-config")

const importsConfig = imports
const importsRules = imports[0].rules
delete importsRules["react/jsx-uses-react"]
delete importsRules["react/jsx-uses-vars"]
importsConfig[0].rules = importsRules

module.exports = [
  ...nx.configs["flat/base"],
  ...nx.configs["flat/typescript"],
  ...nx.configs["flat/javascript"],
  ...base,
  ...importsConfig,
  ...a11y,
]

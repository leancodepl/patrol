const tseslint = require("typescript-eslint")
const { base, baseReact, imports, a11y } = require("@leancodepl/eslint-config")
const { resolveFlatConfig } = require("@leancodepl/resolve-eslint-flat-config")

module.exports = resolveFlatConfig([
  {
    plugins: { "@typescript-eslint": tseslint.plugin },
    languageOptions: {
      parser: tseslint.parser,
      ecmaVersion: "latest",
    },
  },
  ...base,
  ...baseReact,
  ...imports,
  ...a11y,
])

const { base, imports, a11y } = require("@leancodepl/eslint-config")

module.exports = [
  ...base,
  ...imports,
  ...a11y,
  {
    ignores: ["node_modules/**", ".next/**", "out/**", "build/**", ".source/**", "next-env.d.ts"],
  },
]

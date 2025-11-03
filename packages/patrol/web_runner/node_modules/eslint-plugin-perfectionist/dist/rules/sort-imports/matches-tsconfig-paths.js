'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
let regexByTsconfigPathCache = /* @__PURE__ */ new Map()
function matchesTsconfigPaths({ tsConfigOutput, name }) {
  if (!tsConfigOutput.compilerOptions.paths) {
    return false
  }
  return Object.keys(tsConfigOutput.compilerOptions.paths).some(key =>
    getRegexByTsconfigPath(key).test(name),
  )
}
function getRegexByTsconfigPath(path) {
  let existingRegex = regexByTsconfigPathCache.get(path)
  if (existingRegex) {
    return existingRegex
  }
  let regex = new RegExp(`^${escapeRegExp(path).replaceAll('*', '(.+)')}$`)
  regexByTsconfigPathCache.set(path, regex)
  return regex
}
function escapeRegExp(value) {
  return value.replaceAll(/[$+.?[\\\]]/gu, String.raw`\$&`)
}
exports.matchesTsconfigPaths = matchesTsconfigPaths

'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const node_module = require('node:module')
const matchesTsconfigPaths = require('./matches-tsconfig-paths.js')
const getTypescriptImport = require('./get-typescript-import.js')
const matches = require('../../utils/matches.js')
function computeCommonSelectors({ tsConfigOutput, filename, options, name }) {
  function matchesInternalPattern(value) {
    return options.internalPattern.some(pattern =>
      matches.matches(value, pattern),
    )
  }
  let internalExternalGroup = matchesInternalPattern(name)
    ? 'internal'
    : getInternalOrExternalGroup({
        tsConfigOutput,
        filename,
        name,
      })
  let commonSelectors = []
  if (
    tsConfigOutput &&
    matchesTsconfigPaths.matchesTsconfigPaths({
      tsConfigOutput,
      name,
    })
  ) {
    commonSelectors.push('tsconfig-path')
  }
  if (isIndex(name)) {
    commonSelectors.push('index')
  }
  if (isSibling(name)) {
    commonSelectors.push('sibling')
  }
  if (isParent(name)) {
    commonSelectors.push('parent')
  }
  if (isSubpath(name)) {
    commonSelectors.push('subpath')
  }
  if (internalExternalGroup === 'internal') {
    commonSelectors.push('internal')
  }
  if (isCoreModule(name, options.environment)) {
    commonSelectors.push('builtin')
  }
  if (internalExternalGroup === 'external') {
    commonSelectors.push('external')
  }
  return commonSelectors
}
let bunModules = /* @__PURE__ */ new Set([
  'detect-libc',
  'bun:sqlite',
  'bun:test',
  'bun:wrap',
  'bun:ffi',
  'bun:jsc',
  'undici',
  'bun',
  'ws',
])
let nodeBuiltinModules = new Set(node_module.builtinModules)
let builtinPrefixOnlyModules = /* @__PURE__ */ new Set([
  'node:sqlite',
  'node:test',
  'node:sea',
])
function getInternalOrExternalGroup({ tsConfigOutput, filename, name }) {
  let typescriptImport = getTypescriptImport.getTypescriptImport()
  if (!typescriptImport) {
    return !name.startsWith('.') && !name.startsWith('/') ? 'external' : null
  }
  let isRelativeImport = typescriptImport.isExternalModuleNameRelative(name)
  if (isRelativeImport) {
    return null
  }
  if (!tsConfigOutput) {
    return 'external'
  }
  let resolution = typescriptImport.resolveModuleName(
    name,
    filename,
    tsConfigOutput.compilerOptions,
    typescriptImport.sys,
    tsConfigOutput.cache,
  )
  if (typeof resolution.resolvedModule?.isExternalLibraryImport !== 'boolean') {
    return 'external'
  }
  return resolution.resolvedModule.isExternalLibraryImport
    ? 'external'
    : 'internal'
}
function isCoreModule(value, environment) {
  function clean(string_) {
    return string_.replace(/^(?:node:){1,2}/u, '')
  }
  let [basePath] = value.split('/')
  let cleanValue = clean(value)
  let cleanBase = clean(basePath)
  if (nodeBuiltinModules.has(cleanValue) || nodeBuiltinModules.has(cleanBase)) {
    return true
  }
  if (
    builtinPrefixOnlyModules.has(value) ||
    builtinPrefixOnlyModules.has(`node:${cleanValue}`) ||
    builtinPrefixOnlyModules.has(basePath) ||
    builtinPrefixOnlyModules.has(`node:${cleanBase}`)
  ) {
    return true
  }
  return environment === 'bun' && bunModules.has(value)
}
function isIndex(value) {
  return [
    './index.d.js',
    './index.d.ts',
    './index.js',
    './index.ts',
    './index',
    './',
    '.',
  ].includes(value)
}
function isSibling(value) {
  return value.startsWith('./')
}
function isParent(value) {
  return value.startsWith('..')
}
function isSubpath(value) {
  return value.startsWith('#')
}
exports.computeCommonSelectors = computeCommonSelectors

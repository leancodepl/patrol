'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const node_module = require('node:module')
var _documentCurrentScript =
  typeof document !== 'undefined' ? document.currentScript : null
let cachedImport
let hasTriedLoadingTypescript = false
function getTypescriptImport() {
  if (cachedImport) {
    return cachedImport
  }
  if (hasTriedLoadingTypescript) {
    return null
  }
  hasTriedLoadingTypescript = true
  try {
    cachedImport = node_module.createRequire(
      typeof document === 'undefined'
        ? require('url').pathToFileURL(__filename).href
        : (_documentCurrentScript &&
            _documentCurrentScript.tagName.toUpperCase() === 'SCRIPT' &&
            _documentCurrentScript.src) ||
            new URL(
              'rules/sort-imports/get-typescript-import.js',
              document.baseURI,
            ).href,
    )('typescript')
  } catch (_error) {
    return null
  }
  return cachedImport
}
exports.getTypescriptImport = getTypescriptImport

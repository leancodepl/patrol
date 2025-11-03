'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const path = require('node:path')
const fs = require('node:fs')
const getTypescriptImport = require('./get-typescript-import.js')
function _interopNamespaceDefault(e) {
  const n = Object.create(null, { [Symbol.toStringTag]: { value: 'Module' } })
  if (e) {
    for (const k in e) {
      if (k !== 'default') {
        const d = Object.getOwnPropertyDescriptor(e, k)
        Object.defineProperty(
          n,
          k,
          d.get
            ? d
            : {
                enumerable: true,
                get: () => e[k],
              },
        )
      }
    }
  }
  n.default = e
  return Object.freeze(n)
}
const path__namespace = /* @__PURE__ */ _interopNamespaceDefault(path)
const fs__namespace = /* @__PURE__ */ _interopNamespaceDefault(fs)
let directoryCacheByPath = /* @__PURE__ */ new Map()
let contentCacheByPath = /* @__PURE__ */ new Map()
function readClosestTsConfigByPath({
  tsconfigFilename,
  tsconfigRootDir,
  contextCwd,
  filePath,
}) {
  let typescriptImport = getTypescriptImport.getTypescriptImport()
  if (!typescriptImport) {
    return null
  }
  let directory = path__namespace.dirname(filePath)
  let checkedDirectories = [directory]
  do {
    let tsconfigPath = path__namespace.join(directory, tsconfigFilename)
    let cachedDirectory = directoryCacheByPath.get(directory)
    if (!cachedDirectory && fs__namespace.existsSync(tsconfigPath)) {
      cachedDirectory = tsconfigPath
    }
    if (cachedDirectory) {
      for (let checkedDirectory of checkedDirectories) {
        directoryCacheByPath.set(checkedDirectory, cachedDirectory)
      }
      return getCompilerOptions(typescriptImport, contextCwd, cachedDirectory)
    }
    directory = path__namespace.dirname(directory)
    checkedDirectories.push(directory)
  } while (directory.length > 1 && directory.length >= tsconfigRootDir.length)
  throw new Error(
    `Couldn't find any ${tsconfigFilename} relative to '${filePath}' within '${tsconfigRootDir}'.`,
  )
}
function getCompilerOptions(typescriptImport, contextCwd, filePath) {
  if (contentCacheByPath.has(filePath)) {
    return contentCacheByPath.get(filePath)
  }
  let configFileRead = typescriptImport.readConfigFile(
    filePath,
    typescriptImport.sys.readFile,
  )
  if (configFileRead.error) {
    throw new Error(
      `Error reading tsconfig file: ${JSON.stringify(configFileRead.error)}`,
    )
  }
  let parsedContent = typescriptImport.parseJsonConfigFileContent(
    configFileRead,
    typescriptImport.sys,
    path__namespace.dirname(filePath),
  )
  let compilerOptionsConverted =
    typescriptImport.convertCompilerOptionsFromJson(
      // eslint-disable-next-line typescript/no-unsafe-member-access
      parsedContent.raw.config.compilerOptions,
      path__namespace.dirname(filePath),
    )
  if (compilerOptionsConverted.errors.length > 0) {
    throw new Error(
      `Error getting compiler options: ${JSON.stringify(
        compilerOptionsConverted.errors,
      )}`,
    )
  }
  let cache = typescriptImport.createModuleResolutionCache(
    contextCwd,
    fileName => typescriptImport.sys.resolvePath(fileName),
    compilerOptionsConverted.options,
  )
  let output = {
    compilerOptions: compilerOptionsConverted.options,
    cache,
  }
  contentCacheByPath.set(filePath, output)
  return output
}
exports.contentCacheByPath = contentCacheByPath
exports.directoryCacheByPath = directoryCacheByPath
exports.readClosestTsConfigByPath = readClosestTsConfigByPath

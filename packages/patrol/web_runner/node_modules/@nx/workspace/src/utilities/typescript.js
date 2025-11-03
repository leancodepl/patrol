"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSourceNodes = exports.compileTypeScript = void 0;
exports.resolveModuleByImport = resolveModuleByImport;
exports.ensureTypescript = ensureTypescript;
const devkit_1 = require("@nx/devkit");
const path_1 = require("path");
const versions_1 = require("../utils/versions");
var compilation_1 = require("./typescript/compilation");
Object.defineProperty(exports, "compileTypeScript", { enumerable: true, get: function () { return compilation_1.compileTypeScript; } });
var get_source_nodes_1 = require("./typescript/get-source-nodes");
Object.defineProperty(exports, "getSourceNodes", { enumerable: true, get: function () { return get_source_nodes_1.getSourceNodes; } });
const normalizedAppRoot = devkit_1.workspaceRoot.replace(/\\/g, '/');
let tsModule;
function readTsConfigOptions(tsConfigPath) {
    if (!tsModule) {
        tsModule = ensureTypescript();
    }
    const readResult = tsModule.readConfigFile(tsConfigPath, tsModule.sys.readFile);
    // we don't need to scan the files, we only care about options
    const host = {
        readDirectory: () => [],
        readFile: () => '',
        fileExists: tsModule.sys.fileExists,
    };
    return tsModule.parseJsonConfigFileContent(readResult.config, host, (0, path_1.dirname)(tsConfigPath)).options;
}
let compilerHost;
/**
 * Find a module based on it's import
 *
 * @param importExpr Import used to resolve to a module
 * @param filePath
 * @param tsConfigPath
 */
function resolveModuleByImport(importExpr, filePath, tsConfigPath) {
    compilerHost = compilerHost || getCompilerHost(tsConfigPath);
    const { options, host, moduleResolutionCache } = compilerHost;
    const { resolvedModule } = tsModule.resolveModuleName(importExpr, filePath, options, host, moduleResolutionCache);
    if (!resolvedModule) {
        return;
    }
    else {
        return resolvedModule.resolvedFileName.replace(`${normalizedAppRoot}/`, '');
    }
}
function getCompilerHost(tsConfigPath) {
    const options = readTsConfigOptions(tsConfigPath);
    const host = tsModule.createCompilerHost(options, true);
    const moduleResolutionCache = tsModule.createModuleResolutionCache(devkit_1.workspaceRoot, host.getCanonicalFileName);
    return { options, host, moduleResolutionCache };
}
function ensureTypescript() {
    return (0, devkit_1.ensurePackage)('typescript', versions_1.typescriptVersion);
}

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.readTsConfig = readTsConfig;
exports.readTsConfigFromTree = readTsConfigFromTree;
exports.getRootTsConfigPathInTree = getRootTsConfigPathInTree;
exports.getRelativePathToRootTsConfig = getRelativePathToRootTsConfig;
exports.getRootTsConfigPath = getRootTsConfigPath;
exports.getRootTsConfigFileName = getRootTsConfigFileName;
exports.addTsConfigPath = addTsConfigPath;
exports.readTsConfigPaths = readTsConfigPaths;
const devkit_1 = require("@nx/devkit");
const fs_1 = require("fs");
const path_1 = require("path");
const ensure_typescript_1 = require("./ensure-typescript");
let tsModule;
function readTsConfig(tsConfigPath, sys) {
    if (!tsModule) {
        tsModule = require('typescript');
    }
    sys ??= tsModule.sys;
    const readResult = tsModule.readConfigFile(tsConfigPath, sys.readFile);
    return tsModule.parseJsonConfigFileContent(readResult.config, sys, (0, path_1.dirname)(tsConfigPath));
}
function readTsConfigFromTree(tree, tsConfigPath) {
    if (!tsModule) {
        tsModule = (0, ensure_typescript_1.ensureTypescript)();
    }
    const tsSysFromTree = {
        ...tsModule.sys,
        readFile: (path) => tree.read(path, 'utf-8'),
    };
    return readTsConfig(tsConfigPath, tsSysFromTree);
}
function getRootTsConfigPathInTree(tree) {
    for (const path of ['tsconfig.base.json', 'tsconfig.json']) {
        if (tree.exists(path)) {
            return path;
        }
    }
    return 'tsconfig.base.json';
}
function getRelativePathToRootTsConfig(tree, targetPath) {
    return (0, devkit_1.offsetFromRoot)(targetPath) + getRootTsConfigPathInTree(tree);
}
function getRootTsConfigPath() {
    const tsConfigFileName = getRootTsConfigFileName();
    return tsConfigFileName ? (0, path_1.join)(devkit_1.workspaceRoot, tsConfigFileName) : null;
}
function getRootTsConfigFileName(tree) {
    for (const tsConfigName of ['tsconfig.base.json', 'tsconfig.json']) {
        const pathExists = tree
            ? tree.exists(tsConfigName)
            : (0, fs_1.existsSync)((0, path_1.join)(devkit_1.workspaceRoot, tsConfigName));
        if (pathExists) {
            return tsConfigName;
        }
    }
    return null;
}
function addTsConfigPath(tree, importPath, lookupPaths) {
    (0, devkit_1.updateJson)(tree, getRootTsConfigPathInTree(tree), (json) => {
        json.compilerOptions ??= {};
        const c = json.compilerOptions;
        c.paths ??= {};
        if (c.paths[importPath]) {
            throw new Error(`You already have a library using the import path "${importPath}". Make sure to specify a unique one.`);
        }
        c.paths[importPath] = lookupPaths;
        return json;
    });
}
function readTsConfigPaths(tsConfig) {
    tsConfig ??= getRootTsConfigPath();
    try {
        if (!tsModule) {
            tsModule = (0, ensure_typescript_1.ensureTypescript)();
        }
        let config;
        if (typeof tsConfig === 'string') {
            const configFile = tsModule.readConfigFile(tsConfig, tsModule.sys.readFile);
            config = tsModule.parseJsonConfigFileContent(configFile.config, tsModule.sys, (0, path_1.dirname)(tsConfig));
        }
        else {
            config = tsConfig;
        }
        if (config.options?.paths) {
            return config.options.paths;
        }
        else {
            return null;
        }
    }
    catch (e) {
        return null;
    }
}

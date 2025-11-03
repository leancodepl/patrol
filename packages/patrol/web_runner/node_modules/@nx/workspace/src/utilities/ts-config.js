"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.readTsConfig = readTsConfig;
exports.getRootTsConfigPathInTree = getRootTsConfigPathInTree;
exports.getRelativePathToRootTsConfig = getRelativePathToRootTsConfig;
exports.getRootTsConfigFileName = getRootTsConfigFileName;
exports.findNodes = findNodes;
const devkit_1 = require("@nx/devkit");
const fs_1 = require("fs");
const path_1 = require("path");
const typescript_1 = require("./typescript");
let tsModule;
function readTsConfig(tsConfigPath) {
    if (!tsModule) {
        tsModule = (0, typescript_1.ensureTypescript)();
    }
    const readResult = tsModule.readConfigFile(tsConfigPath, tsModule.sys.readFile);
    return tsModule.parseJsonConfigFileContent(readResult.config, tsModule.sys, (0, path_1.dirname)(tsConfigPath));
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
function getRootTsConfigFileName() {
    for (const tsConfigName of ['tsconfig.base.json', 'tsconfig.json']) {
        const tsConfigPath = (0, path_1.join)(devkit_1.workspaceRoot, tsConfigName);
        if ((0, fs_1.existsSync)(tsConfigPath)) {
            return tsConfigName;
        }
    }
    return null;
}
function findNodes(node, kind, max = Infinity) {
    if (!node || max == 0) {
        return [];
    }
    const arr = [];
    const hasMatch = Array.isArray(kind)
        ? kind.includes(node.kind)
        : node.kind === kind;
    if (hasMatch) {
        arr.push(node);
        max--;
    }
    if (max > 0) {
        for (const child of node.getChildren()) {
            findNodes(child, kind, max).forEach((node) => {
                if (max > 0) {
                    arr.push(node);
                }
                max--;
            });
            if (max <= 0) {
                break;
            }
        }
    }
    return arr;
}

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAllDependencies = getAllDependencies;
exports.getProductionDependencies = getProductionDependencies;
exports.getPackageJson = getPackageJson;
const devkit_1 = require("@nx/devkit");
const fs_1 = require("fs");
function getAllDependencies(packageJson) {
    return {
        ...packageJson.dependencies,
        ...packageJson.devDependencies,
        ...packageJson.peerDependencies,
        ...packageJson.optionalDependencies,
    };
}
function getProductionDependencies(packageJson) {
    return {
        ...packageJson.dependencies,
        ...packageJson.peerDependencies,
        ...packageJson.optionalDependencies,
    };
}
function getPackageJson(path) {
    if ((0, fs_1.existsSync)(path)) {
        return (0, devkit_1.readJsonFile)(path);
    }
    return {};
}

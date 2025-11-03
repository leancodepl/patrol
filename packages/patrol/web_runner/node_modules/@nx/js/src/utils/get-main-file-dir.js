"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getRelativeDirectoryToProjectRoot = getRelativeDirectoryToProjectRoot;
const path_1 = require("path");
const path_2 = require("nx/src/utils/path");
function getRelativeDirectoryToProjectRoot(file, projectRoot) {
    const dir = (0, path_1.dirname)(file);
    const relativeDir = (0, path_2.normalizePath)((0, path_1.relative)(projectRoot, dir));
    return relativeDir === '' ? `./` : `./${relativeDir}/`;
}

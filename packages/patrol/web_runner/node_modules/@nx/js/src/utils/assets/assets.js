"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.assetGlobsToFiles = assetGlobsToFiles;
const tinyglobby_1 = require("tinyglobby");
const path_1 = require("path");
function assetGlobsToFiles(assets, rootDir, outDir) {
    const files = [];
    const globbedFiles = (pattern, input = '', ignore = [], dot = false) => {
        return (0, tinyglobby_1.globSync)(pattern, {
            cwd: input,
            onlyFiles: true,
            dot,
            expandDirectories: false,
            ignore,
        });
    };
    assets.forEach((asset) => {
        if (typeof asset === 'string') {
            globbedFiles(asset, rootDir).forEach((globbedFile) => {
                files.push({
                    input: (0, path_1.join)(rootDir, globbedFile),
                    output: (0, path_1.join)(outDir, (0, path_1.basename)(globbedFile)),
                });
            });
        }
        else {
            globbedFiles(asset.glob, (0, path_1.join)(rootDir, asset.input), asset.ignore, asset.dot ?? false).forEach((globbedFile) => {
                files.push({
                    input: (0, path_1.join)(rootDir, asset.input, globbedFile),
                    output: (0, path_1.join)(outDir, asset.output, globbedFile),
                });
            });
        }
    });
    return files;
}

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.normalizeOptions = normalizeOptions;
const path_1 = require("path");
const assets_1 = require("../../../utils/assets/assets");
function normalizeOptions(options, contextRoot, sourceRoot, projectRoot) {
    const outputPath = (0, path_1.join)(contextRoot, options.outputPath);
    const rootDir = options.rootDir
        ? (0, path_1.join)(contextRoot, options.rootDir)
        : (0, path_1.join)(contextRoot, projectRoot);
    if (options.watch == null) {
        options.watch = false;
    }
    options.assets ??= [];
    const files = (0, assets_1.assetGlobsToFiles)(options.assets, contextRoot, outputPath);
    return {
        ...options,
        root: contextRoot,
        sourceRoot,
        projectRoot,
        files,
        outputPath,
        tsConfig: (0, path_1.join)(contextRoot, options.tsConfig),
        rootDir,
        mainOutputPath: (0, path_1.resolve)(outputPath, options.main.replace(`${projectRoot}/`, '').replace('.ts', '.js')),
        generatePackageJson: options.generatePackageJson ?? true,
    };
}

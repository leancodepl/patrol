"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.setupPrettierGenerator = setupPrettierGenerator;
const devkit_1 = require("@nx/devkit");
const prettier_1 = require("../../utils/prettier");
const versions_1 = require("../../utils/versions");
async function setupPrettierGenerator(tree, options) {
    const prettierTask = (0, prettier_1.generatePrettierSetup)(tree, {
        skipPackageJson: options.skipPackageJson,
    });
    if (!options.skipPackageJson) {
        (0, devkit_1.ensurePackage)('prettier', versions_1.prettierVersion);
    }
    if (!options.skipFormat) {
        // even if skipPackageJson === true, we can safely run formatFiles, prettier might
        // have been installed earlier and if not, the formatFiles function still handles it
        await (0, devkit_1.formatFiles)(tree);
    }
    return prettierTask;
}
exports.default = setupPrettierGenerator;

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updatePackageJson = updatePackageJson;
const devkit_1 = require("@nx/devkit");
const path = require("path");
/**
 * Updates the name in the package.json if it exists.
 *
 * @param schema The options provided to the schematic
 */
function updatePackageJson(tree, schema) {
    if (!schema.importPath) {
        return;
    }
    const packageJsonPath = path.join(schema.relativeToRootDestination, 'package.json');
    if (!tree.exists(packageJsonPath)) {
        // nothing to do
        return;
    }
    const packageJson = (0, devkit_1.readJson)(tree, packageJsonPath);
    packageJson.name = schema.importPath;
    tree.write(packageJsonPath, JSON.stringify(packageJson));
}

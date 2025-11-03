"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkAndCleanWithSemver = checkAndCleanWithSemver;
const devkit_exports_1 = require("nx/src/devkit-exports");
const semver_1 = require("semver");
const catalog_1 = require("./catalog");
function checkAndCleanWithSemver(treeOrPkgName, pkgNameOrVersion, version) {
    const tree = typeof treeOrPkgName === 'string' ? undefined : treeOrPkgName;
    const root = tree?.root ?? devkit_exports_1.workspaceRoot;
    const pkgName = typeof treeOrPkgName === 'string' ? treeOrPkgName : pkgNameOrVersion;
    let newVersion = typeof treeOrPkgName === 'string' ? pkgNameOrVersion : version;
    const manager = (0, catalog_1.getCatalogManager)(root);
    if (manager?.isCatalogReference(newVersion)) {
        try {
            if (tree) {
                manager.validateCatalogReference(tree, pkgName, newVersion);
            }
            else {
                manager.validateCatalogReference(root, pkgName, newVersion);
            }
        }
        catch (error) {
            throw new Error(`The catalog reference for ${pkgName} is invalid - (${newVersion})\n${error.message}`);
        }
        const resolvedVersion = tree
            ? manager.resolveCatalogReference(tree, pkgName, newVersion)
            : manager.resolveCatalogReference(root, pkgName, newVersion);
        if (!resolvedVersion) {
            throw new Error(`Could not resolve catalog reference for package ${pkgName}@${newVersion}.`);
        }
        newVersion = resolvedVersion;
    }
    if ((0, semver_1.valid)(newVersion)) {
        return newVersion;
    }
    if (newVersion.startsWith('~') || newVersion.startsWith('^')) {
        newVersion = newVersion.substring(1);
    }
    if (!(0, semver_1.valid)(newVersion)) {
        throw new Error(`The package.json lists a version of ${pkgName} that Nx is unable to validate - (${newVersion})`);
    }
    return newVersion;
}

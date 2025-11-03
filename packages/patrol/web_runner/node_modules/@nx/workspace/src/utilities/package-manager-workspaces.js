"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isProjectIncludedInPackageManagerWorkspaces = isProjectIncludedInPackageManagerWorkspaces;
exports.getPackageManagerWorkspacesPatterns = getPackageManagerWorkspacesPatterns;
exports.isUsingPackageManagerWorkspaces = isUsingPackageManagerWorkspaces;
exports.isWorkspacesEnabled = isWorkspacesEnabled;
const devkit_1 = require("@nx/devkit");
const posix_1 = require("node:path/posix");
const package_json_1 = require("nx/src/plugins/package-json");
const picomatch = require("picomatch");
function isProjectIncludedInPackageManagerWorkspaces(tree, projectRoot) {
    if (!isUsingPackageManagerWorkspaces(tree)) {
        return false;
    }
    const patterns = getPackageManagerWorkspacesPatterns(tree);
    return patterns.some((p) => picomatch(p)((0, posix_1.join)(projectRoot, 'package.json')));
}
function getPackageManagerWorkspacesPatterns(tree) {
    return (0, package_json_1.getGlobPatternsFromPackageManagerWorkspaces)(tree.root, (path) => (0, devkit_1.readJson)(tree, path, { expectComments: true }), (path) => {
        const content = tree.read(path, 'utf-8');
        const { load } = require('@zkochan/js-yaml');
        return load(content, { filename: path });
    }, (path) => tree.exists(path));
}
function isUsingPackageManagerWorkspaces(tree) {
    return isWorkspacesEnabled(tree);
}
function isWorkspacesEnabled(tree) {
    const packageManager = (0, devkit_1.detectPackageManager)(tree.root);
    if (packageManager === 'pnpm') {
        if (!tree.exists('pnpm-workspace.yaml')) {
            return false;
        }
        try {
            const content = tree.read('pnpm-workspace.yaml', 'utf-8');
            const { load } = require('@zkochan/js-yaml');
            const { packages } = load(content) ?? {};
            return packages !== undefined;
        }
        catch {
            return false;
        }
    }
    // yarn and npm both use the same 'workspaces' property in package.json
    if (tree.exists('package.json')) {
        const packageJson = (0, devkit_1.readJson)(tree, 'package.json');
        return !!packageJson?.workspaces;
    }
    return false;
}

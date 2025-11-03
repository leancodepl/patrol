"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getIgnoreObject = getIgnoreObject;
exports.getIgnoreObjectForTree = getIgnoreObjectForTree;
const ignore = require("ignore");
const fileutils_1 = require("./fileutils");
const workspace_root_1 = require("./workspace-root");
function getIgnoreObject(root = workspace_root_1.workspaceRoot) {
    const ig = ignore();
    ig.add((0, fileutils_1.readFileIfExisting)(`${root}/.gitignore`));
    ig.add((0, fileutils_1.readFileIfExisting)(`${root}/.nxignore`));
    return ig;
}
function getIgnoreObjectForTree(tree) {
    let ig;
    if (tree.exists('.gitignore')) {
        ig = ignore();
        ig.add('.git');
        ig.add(tree.read('.gitignore', 'utf-8'));
    }
    if (tree.exists('.nxignore')) {
        ig ??= ignore();
        ig.add(tree.read('.nxignore', 'utf-8'));
    }
    return ig;
}

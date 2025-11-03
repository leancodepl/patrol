"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getProjectSourceRoot = getProjectSourceRoot;
const devkit_1 = require("@nx/devkit");
const node_fs_1 = require("node:fs");
const node_path_1 = require("node:path");
function getProjectSourceRoot(project, tree) {
    if (tree) {
        return (project.sourceRoot ??
            (tree.exists((0, devkit_1.joinPathFragments)(project.root, 'src'))
                ? (0, devkit_1.joinPathFragments)(project.root, 'src')
                : project.root));
    }
    return (project.sourceRoot ??
        ((0, node_fs_1.existsSync)((0, node_path_1.join)(devkit_1.workspaceRoot, project.root, 'src'))
            ? (0, devkit_1.joinPathFragments)(project.root, 'src')
            : project.root));
}

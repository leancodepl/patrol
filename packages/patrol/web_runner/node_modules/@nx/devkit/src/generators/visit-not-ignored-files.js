"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.visitNotIgnoredFiles = visitNotIgnoredFiles;
const devkit_internals_1 = require("nx/src/devkit-internals");
const path_1 = require("path");
/**
 * Utility to act on all files in a tree that are not ignored by git.
 */
function visitNotIgnoredFiles(tree, dirPath = tree.root, visitor) {
    const ig = (0, devkit_internals_1.getIgnoreObjectForTree)(tree);
    dirPath = normalizePathRelativeToRoot(dirPath, tree.root);
    if (dirPath !== '' && ig?.ignores(dirPath)) {
        return;
    }
    for (const child of tree.children(dirPath)) {
        const fullPath = (0, path_1.join)(dirPath, child);
        if (ig?.ignores(fullPath)) {
            continue;
        }
        if (tree.isFile(fullPath)) {
            visitor(fullPath);
        }
        else {
            visitNotIgnoredFiles(tree, fullPath, visitor);
        }
    }
}
function normalizePathRelativeToRoot(path, root) {
    return (0, path_1.relative)(root, (0, path_1.join)(root, path)).split(path_1.sep).join('/');
}

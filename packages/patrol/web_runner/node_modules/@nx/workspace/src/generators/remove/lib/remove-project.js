"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.removeProject = removeProject;
const devkit_1 = require("@nx/devkit");
/**
 * Removes (deletes) a project's files from the folder tree
 */
function removeProject(tree, project) {
    (0, devkit_1.visitNotIgnoredFiles)(tree, project.root, (file) => {
        tree.delete(file);
    });
    tree.delete(project.root);
}

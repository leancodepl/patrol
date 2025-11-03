"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkProjectIsSafeToRemove = checkProjectIsSafeToRemove;
const devkit_1 = require("@nx/devkit");
const path_1 = require("path");
function checkProjectIsSafeToRemove(tree, schema, project) {
    if (project.root === '.') {
        throw new Error(`"${schema.projectName}" is the root project. Running this would delete every file in your workspace.`);
    }
    if (schema.forceRemove) {
        devkit_1.logger.warn(`You have passed --forceRemove`);
        return;
    }
    const containedProjects = [];
    for (const [_, p] of (0, devkit_1.getProjects)(tree)) {
        if (project.name !== p.name &&
            !(0, devkit_1.normalizePath)((0, path_1.relative)(project.root, p.root)).startsWith('..')) {
            containedProjects.push(p.name);
        }
    }
    if (containedProjects.length > 0) {
        throw new Error(`"${schema.projectName}" is a project that has nested projects within it. Removing this project would remove the following projects as well:\n - ${containedProjects.join('\n - ')}\nPass --forceRemove to remove all of the above projects`);
    }
}

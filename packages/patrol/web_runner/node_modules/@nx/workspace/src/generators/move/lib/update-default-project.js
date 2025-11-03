"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateDefaultProject = updateDefaultProject;
const devkit_1 = require("@nx/devkit");
/**
 * Updates the project in the workspace file
 *
 * - update all references to the old root path
 * - change the project name
 * - change target references
 */
function updateDefaultProject(tree, schema) {
    const nxJson = (0, devkit_1.readNxJson)(tree);
    // update default project (if necessary)
    if (nxJson.defaultProject && nxJson.defaultProject === schema.projectName) {
        nxJson.defaultProject = schema.newProjectName;
        (0, devkit_1.updateNxJson)(tree, nxJson);
    }
}

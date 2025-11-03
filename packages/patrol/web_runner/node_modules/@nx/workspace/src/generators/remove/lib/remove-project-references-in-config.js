"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.removeProjectReferencesInConfig = removeProjectReferencesInConfig;
const devkit_1 = require("@nx/devkit");
function removeProjectReferencesInConfig(tree, schema) {
    // Unset default project if deleting the default project
    const nxJson = (0, devkit_1.readNxJson)(tree);
    if (nxJson.defaultProject && nxJson.defaultProject === schema.projectName) {
        delete nxJson.defaultProject;
        (0, devkit_1.updateNxJson)(tree, nxJson);
    }
    // Remove implicit dependencies onto removed project
    (0, devkit_1.getProjects)(tree).forEach((project, projectName) => {
        if (project.implicitDependencies &&
            project.implicitDependencies.some((projectName) => projectName === schema.projectName)) {
            project.implicitDependencies = project.implicitDependencies.filter((projectName) => projectName !== schema.projectName);
            (0, devkit_1.updateProjectConfiguration)(tree, projectName, project);
        }
    });
}

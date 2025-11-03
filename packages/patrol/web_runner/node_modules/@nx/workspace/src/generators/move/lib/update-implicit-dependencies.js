"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateImplicitDependencies = updateImplicitDependencies;
const devkit_1 = require("@nx/devkit");
/**
 * @param schema The options provided to the schematic
 */
function updateImplicitDependencies(tree, schema) {
    for (const [projectName, project] of (0, devkit_1.getProjects)(tree)) {
        if (project.implicitDependencies) {
            const index = project.implicitDependencies.indexOf(schema.projectName);
            if (index !== -1) {
                project.implicitDependencies[index] = schema.newProjectName;
                (0, devkit_1.updateProjectConfiguration)(tree, projectName, project);
            }
        }
    }
}

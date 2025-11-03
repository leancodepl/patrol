"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkDependencies = checkDependencies;
const devkit_1 = require("@nx/devkit");
/**
 * Check whether the project to be removed is depended on by another project
 *
 * Throws an error if the project is in use, unless the `--forceRemove` option is used.
 */
async function checkDependencies(_, schema) {
    if (schema.forceRemove) {
        return;
    }
    const graph = await (0, devkit_1.createProjectGraphAsync)();
    const reverseGraph = (0, devkit_1.reverse)(graph);
    const deps = reverseGraph.dependencies[schema.projectName] || [];
    if (deps.length > 0) {
        throw new Error(`${schema.projectName} is still a dependency of the following projects:\n${deps
            .map((x) => x.target)
            .join('\n')}`);
    }
}

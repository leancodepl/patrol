"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkDependencies = checkDependencies;
const buildable_libs_utils_1 = require("./buildable-libs-utils");
function checkDependencies(context, tsConfigPath) {
    const { target, dependencies } = (0, buildable_libs_utils_1.calculateProjectBuildableDependencies)(context.taskGraph, context.projectGraph, context.root, context.projectName, context.targetName, context.configurationName);
    const projectRoot = target.data.root;
    if (dependencies.length > 0) {
        return {
            tmpTsConfig: (0, buildable_libs_utils_1.createTmpTsConfig)(tsConfigPath, context.root, projectRoot, dependencies),
            projectRoot,
            target,
            dependencies,
        };
    }
    return {
        tmpTsConfig: null,
        projectRoot,
        target,
        dependencies,
    };
}

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.normalizeTasksOptions = normalizeTasksOptions;
const devkit_1 = require("@nx/devkit");
const normalize_options_1 = require("../normalize-options");
function normalizeTasksOptions(inputs, context) {
    return Object.entries(inputs).reduce((tasksOptions, [taskName, options]) => {
        const { project } = (0, devkit_1.parseTargetString)(taskName, context);
        const { sourceRoot, root } = context.projectsConfigurations.projects[project];
        tasksOptions[taskName] = (0, normalize_options_1.normalizeOptions)(options, context.root, sourceRoot, root);
        return tasksOptions;
    }, {});
}

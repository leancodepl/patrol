"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getTaskOptions = getTaskOptions;
const normalize_options_1 = require("./normalize-options");
const tasksOptionsCache = new Map();
function getTaskOptions(taskName, context) {
    if (tasksOptionsCache.has(taskName)) {
        return tasksOptionsCache.get(taskName);
    }
    try {
        const { taskOptions, sourceRoot, root } = parseTaskInfo(taskName, context);
        const normalizedTaskOptions = (0, normalize_options_1.normalizeOptions)(taskOptions, context.root, sourceRoot, root);
        tasksOptionsCache.set(taskName, normalizedTaskOptions);
        return normalizedTaskOptions;
    }
    catch {
        tasksOptionsCache.set(taskName, null);
        return null;
    }
}
function parseTaskInfo(taskName, context) {
    const target = context.taskGraph.tasks[taskName].target;
    const projectNode = context.projectGraph.nodes[target.project];
    const targetConfig = projectNode.data.targets?.[target.target];
    const { sourceRoot, root } = projectNode.data;
    const taskOptions = {
        ...targetConfig.options,
        ...(target.configuration
            ? targetConfig.configurations?.[target.configuration]
            : {}),
    };
    return { taskOptions, root, sourceRoot, projectNode, target };
}

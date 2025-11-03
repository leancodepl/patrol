"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createTaskInfoPerTsConfigMap = createTaskInfoPerTsConfigMap;
const devkit_1 = require("@nx/devkit");
const path_1 = require("path");
const copy_assets_handler_1 = require("../../../../utils/assets/copy-assets-handler");
const buildable_libs_utils_1 = require("../../../../utils/buildable-libs-utils");
const get_task_options_1 = require("../get-task-options");
const taskTsConfigCache = new Set();
function createTaskInfoPerTsConfigMap(tasksOptions, context, tasks, taskInMemoryTsConfigMap) {
    const tsConfigTaskInfoMap = {};
    processTasksAndPopulateTsConfigTaskInfoMap(tsConfigTaskInfoMap, tasksOptions, context, tasks, taskInMemoryTsConfigMap);
    return tsConfigTaskInfoMap;
}
function processTasksAndPopulateTsConfigTaskInfoMap(tsConfigTaskInfoMap, tasksOptions, context, tasks, taskInMemoryTsConfigMap) {
    for (const taskName of tasks) {
        if (taskTsConfigCache.has(taskName)) {
            continue;
        }
        const tsConfig = taskInMemoryTsConfigMap[taskName];
        if (!tsConfig) {
            continue;
        }
        let taskOptions = tasksOptions[taskName] ?? (0, get_task_options_1.getTaskOptions)(taskName, context);
        if (taskOptions) {
            const taskInfo = createTaskInfo(taskName, taskOptions, context, tsConfig);
            const tsConfigPath = (0, path_1.join)(context.root, (0, path_1.relative)(context.root, taskOptions.tsConfig)).replace(/\\/g, '/');
            tsConfigTaskInfoMap[tsConfigPath] = taskInfo;
            taskTsConfigCache.add(taskName);
        }
        processTasksAndPopulateTsConfigTaskInfoMap(tsConfigTaskInfoMap, tasksOptions, context, context.taskGraph.dependencies[taskName], taskInMemoryTsConfigMap);
    }
}
function createTaskInfo(taskName, taskOptions, context, tsConfig) {
    const target = (0, devkit_1.parseTargetString)(taskName, context);
    const taskContext = {
        ...context,
        // batch executors don't get these in the context, we provide them
        // here per task
        projectName: target.project,
        targetName: target.target,
        configurationName: target.configuration,
    };
    const assetsHandler = new copy_assets_handler_1.CopyAssetsHandler({
        projectDir: taskOptions.projectRoot,
        rootDir: context.root,
        outputDir: taskOptions.outputPath,
        assets: taskOptions.assets,
        includeIgnoredFiles: taskOptions.includeIgnoredAssetFiles,
    });
    const { target: projectGraphNode, dependencies: buildableProjectNodeDependencies, } = (0, buildable_libs_utils_1.calculateProjectBuildableDependencies)(context.taskGraph, context.projectGraph, context.root, context.taskGraph.tasks[taskName].target.project, context.taskGraph.tasks[taskName].target.target, context.taskGraph.tasks[taskName].target.configuration);
    return {
        task: taskName,
        options: taskOptions,
        context: taskContext,
        assetsHandler,
        buildableProjectNodeDependencies,
        projectGraphNode,
        tsConfig,
        terminalOutput: '',
    };
}

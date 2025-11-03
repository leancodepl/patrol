"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getProcessedTaskTsConfigs = getProcessedTaskTsConfigs;
const devkit_1 = require("@nx/devkit");
const path_1 = require("path");
const get_task_options_1 = require("./get-task-options");
function getProcessedTaskTsConfigs(tasks, tasksOptions, context) {
    const taskInMemoryTsConfigMap = {};
    for (const task of tasks) {
        generateTaskProjectTsConfig(task, tasksOptions, context, taskInMemoryTsConfigMap);
    }
    return taskInMemoryTsConfigMap;
}
const projectTsConfigCache = new Map();
function generateTaskProjectTsConfig(task, tasksOptions, context, taskInMemoryTsConfigMap) {
    const { project } = (0, devkit_1.parseTargetString)(task, context);
    if (projectTsConfigCache.has(project)) {
        const { tsConfig, tsConfigPath } = projectTsConfigCache.get(project);
        taskInMemoryTsConfigMap[task] = tsConfig;
        return tsConfigPath;
    }
    const tasksInProject = [
        task,
        ...getDependencyTasksInSameProject(task, context),
    ];
    const taskWithTscExecutor = tasksInProject.find((t) => hasTscExecutor(t, context));
    if (!taskWithTscExecutor) {
        throw new Error((0, devkit_1.stripIndents) `The "@nx/js:tsc" batch executor requires all dependencies to use the "@nx/js:tsc" executor.
        None of the following tasks in the "${project}" project use the "@nx/js:tsc" executor:
        ${tasksInProject.map((t) => `- ${t}`).join('\n')}`);
    }
    const projectReferences = [];
    for (const task of tasksInProject) {
        for (const depTask of getDependencyTasksInOtherProjects(task, project, context)) {
            const tsConfigPath = generateTaskProjectTsConfig(depTask, tasksOptions, context, taskInMemoryTsConfigMap);
            projectReferences.push(tsConfigPath);
        }
    }
    const taskOptions = tasksOptions[taskWithTscExecutor] ??
        (0, get_task_options_1.getTaskOptions)(taskWithTscExecutor, context);
    const tsConfigPath = taskOptions.tsConfig;
    taskInMemoryTsConfigMap[taskWithTscExecutor] = getInMemoryTsConfig(tsConfigPath, taskOptions, projectReferences);
    projectTsConfigCache.set(project, {
        tsConfigPath: tsConfigPath,
        tsConfig: taskInMemoryTsConfigMap[taskWithTscExecutor],
    });
    return tsConfigPath;
}
function getDependencyTasksInOtherProjects(task, project, context) {
    const implicitDependencies = new Set(context.projectGraph.nodes[project].data.implicitDependencies ?? []);
    return context.taskGraph.dependencies[task].filter((t) => {
        const { project: dependencyProject } = (0, devkit_1.parseTargetString)(t, context);
        // Tasks for implicit dependencies are skipped since incremental builds only apply to explicit dependencies
        return (t !== task &&
            dependencyProject !== project &&
            !implicitDependencies.has(dependencyProject));
    });
}
function getDependencyTasksInSameProject(task, context) {
    const { project: taskProject } = (0, devkit_1.parseTargetString)(task, context);
    return Object.keys(context.taskGraph.tasks).filter((t) => t !== task && (0, devkit_1.parseTargetString)(t, context).project === taskProject);
}
function getInMemoryTsConfig(tsConfig, taskOptions, projectReferences) {
    const originalTsConfig = (0, devkit_1.readJsonFile)(tsConfig, {
        allowTrailingComma: true,
        disallowComments: false,
    });
    const allProjectReferences = Array.from(new Set((originalTsConfig.references ?? [])
        .map((r) => r.path)
        .concat(projectReferences)));
    return {
        content: JSON.stringify({
            ...originalTsConfig,
            compilerOptions: {
                ...originalTsConfig.compilerOptions,
                rootDir: taskOptions.rootDir,
                outDir: taskOptions.outputPath,
                composite: true,
                declaration: true,
                declarationMap: true,
                tsBuildInfoFile: (0, path_1.join)(taskOptions.outputPath, 'tsconfig.tsbuildinfo'),
            },
            references: allProjectReferences.map((pr) => ({ path: pr })),
        }),
        path: tsConfig.replace(/\\/g, '/'),
    };
}
function hasTscExecutor(task, context) {
    const { project, target } = (0, devkit_1.parseTargetString)(task, context);
    return (context.projectGraph.nodes[project].data.targets[target].executor ===
        '@nx/js:tsc');
}

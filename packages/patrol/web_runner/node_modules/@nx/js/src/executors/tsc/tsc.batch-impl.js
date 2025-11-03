"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.tscBatchExecutor = tscBatchExecutor;
const devkit_1 = require("@nx/devkit");
const fs_1 = require("fs");
const async_iterator_1 = require("nx/src/utils/async-iterator");
const update_package_json_1 = require("../../utils/package-json/update-package-json");
const tsc_impl_1 = require("./tsc.impl");
const lib_1 = require("./lib");
const batch_1 = require("./lib/batch");
const create_entry_points_1 = require("../../utils/package-json/create-entry-points");
async function* tscBatchExecutor(taskGraph, inputs, overrides, context) {
    const tasksOptions = (0, batch_1.normalizeTasksOptions)(inputs, context);
    let shouldWatch = false;
    Object.values(tasksOptions).forEach((taskOptions) => {
        if (taskOptions.clean) {
            (0, fs_1.rmSync)(taskOptions.outputPath, { force: true, recursive: true });
        }
        if (taskOptions.watch) {
            shouldWatch = true;
        }
    });
    const taskInMemoryTsConfigMap = (0, lib_1.getProcessedTaskTsConfigs)(Object.keys(taskGraph.tasks), tasksOptions, context);
    const tsConfigTaskInfoMap = (0, batch_1.createTaskInfoPerTsConfigMap)(tasksOptions, context, Object.keys(taskGraph.tasks), taskInMemoryTsConfigMap);
    const tsCompilationContext = createTypescriptCompilationContext(tsConfigTaskInfoMap, taskInMemoryTsConfigMap, context);
    const logger = {
        error: (message, tsConfig) => {
            process.stderr.write(message);
            if (tsConfig) {
                tsConfigTaskInfoMap[tsConfig].terminalOutput += message;
            }
        },
        info: (message, tsConfig) => {
            process.stdout.write(message);
            if (tsConfig) {
                tsConfigTaskInfoMap[tsConfig].terminalOutput += message;
            }
        },
        warn: (message, tsConfig) => {
            process.stdout.write(message);
            if (tsConfig) {
                tsConfigTaskInfoMap[tsConfig].terminalOutput += message;
            }
        },
    };
    const processTaskPostCompilation = (tsConfig) => {
        if (tsConfigTaskInfoMap[tsConfig]) {
            const taskInfo = tsConfigTaskInfoMap[tsConfig];
            taskInfo.assetsHandler.processAllAssetsOnceSync();
            (0, update_package_json_1.updatePackageJson)({
                ...taskInfo.options,
                additionalEntryPoints: (0, create_entry_points_1.createEntryPoints)(taskInfo.options.additionalEntryPoints, context.root),
                format: [(0, tsc_impl_1.determineModuleFormatFromTsConfig)(tsConfig)],
            }, taskInfo.context, taskInfo.projectGraphNode, taskInfo.buildableProjectNodeDependencies);
            taskInfo.endTime = Date.now();
        }
    };
    const typescriptCompilation = (0, lib_1.compileTypescriptSolution)(tsCompilationContext, shouldWatch, logger, {
        beforeProjectCompilationCallback: (tsConfig) => {
            if (tsConfigTaskInfoMap[tsConfig]) {
                tsConfigTaskInfoMap[tsConfig].startTime = Date.now();
            }
        },
        afterProjectCompilationCallback: processTaskPostCompilation,
    });
    if (shouldWatch && !(0, devkit_1.isDaemonEnabled)()) {
        devkit_1.output.warn({
            title: 'Nx Daemon is not enabled. Assets and package.json files will not be updated on file changes.',
        });
    }
    if (shouldWatch && (0, devkit_1.isDaemonEnabled)()) {
        const taskInfos = Object.values(tsConfigTaskInfoMap);
        const watchAssetsChangesDisposer = await (0, batch_1.watchTaskProjectsFileChangesForAssets)(taskInfos);
        const watchProjectsChangesDisposer = await (0, batch_1.watchTaskProjectsPackageJsonFileChanges)(taskInfos, (changedTaskInfos) => {
            for (const t of changedTaskInfos) {
                (0, update_package_json_1.updatePackageJson)({
                    ...t.options,
                    additionalEntryPoints: (0, create_entry_points_1.createEntryPoints)(t.options.additionalEntryPoints, context.root),
                    format: [(0, tsc_impl_1.determineModuleFormatFromTsConfig)(t.options.tsConfig)],
                }, t.context, t.projectGraphNode, t.buildableProjectNodeDependencies);
            }
        });
        const handleTermination = async (exitCode) => {
            watchAssetsChangesDisposer();
            watchProjectsChangesDisposer();
            process.exit(exitCode);
        };
        process.on('SIGINT', () => handleTermination(128 + 2));
        process.on('SIGTERM', () => handleTermination(128 + 15));
        return yield* mapAsyncIterable(typescriptCompilation, async (iterator) => {
            // drain the iterator, we don't use the results
            await (0, async_iterator_1.getLastValueFromAsyncIterableIterator)(iterator);
            return { value: undefined, done: true };
        });
    }
    const toBatchExecutorTaskResult = (tsConfig, success) => ({
        task: tsConfigTaskInfoMap[tsConfig].task,
        result: {
            success: success,
            terminalOutput: tsConfigTaskInfoMap[tsConfig].terminalOutput,
            startTime: tsConfigTaskInfoMap[tsConfig].startTime,
            endTime: tsConfigTaskInfoMap[tsConfig].endTime,
        },
    });
    let isCompilationDone = false;
    const taskTsConfigsToReport = new Set(Object.keys(taskGraph.tasks).map((t) => taskInMemoryTsConfigMap[t].path));
    let tasksToReportIterator;
    const processSkippedTasks = () => {
        const { value: tsConfig, done } = tasksToReportIterator.next();
        if (done) {
            return { value: undefined, done: true };
        }
        tsConfigTaskInfoMap[tsConfig].startTime = Date.now();
        processTaskPostCompilation(tsConfig);
        return { value: toBatchExecutorTaskResult(tsConfig, true), done: false };
    };
    return yield* mapAsyncIterable(typescriptCompilation, async (iterator) => {
        if (isCompilationDone) {
            return processSkippedTasks();
        }
        const { value, done } = await iterator.next();
        if (done) {
            if (taskTsConfigsToReport.size > 0) {
                /**
                 * TS compilation is done but we still have tasks to report. This can
                 * happen if, for example, a project is identified as affected, but
                 * no file in the TS project is actually changed or if running a
                 * task with `--skip-nx-cache` and the outputs are already there. There
                 * can still be changes to assets or other files we need to process.
                 *
                 * Switch to handle the iterator for the tasks we still need to report.
                 */
                isCompilationDone = true;
                tasksToReportIterator = taskTsConfigsToReport.values();
                return processSkippedTasks();
            }
            return { value: undefined, done: true };
        }
        taskTsConfigsToReport.delete(value.tsConfig);
        return {
            value: toBatchExecutorTaskResult(value.tsConfig, value.success),
            done: false,
        };
    });
}
exports.default = tscBatchExecutor;
async function* mapAsyncIterable(iterable, nextFn) {
    return yield* {
        [Symbol.asyncIterator]() {
            const iterator = iterable[Symbol.asyncIterator].call(iterable);
            return {
                async next() {
                    return await nextFn(iterator);
                },
            };
        },
    };
}
function createTypescriptCompilationContext(tsConfigTaskInfoMap, taskInMemoryTsConfigMap, context) {
    const tsCompilationContext = Object.entries(tsConfigTaskInfoMap).reduce((acc, [tsConfig, taskInfo]) => {
        acc[tsConfig] = {
            project: taskInfo.context.projectName,
            tsConfig: taskInfo.tsConfig,
            transformers: taskInfo.options.transformers,
        };
        return acc;
    }, {});
    Object.entries(taskInMemoryTsConfigMap).forEach(([task, tsConfig]) => {
        if (!tsCompilationContext[tsConfig.path]) {
            tsCompilationContext[tsConfig.path] = {
                project: (0, devkit_1.parseTargetString)(task, context).project,
                transformers: [],
                tsConfig: tsConfig,
            };
        }
    });
    return tsCompilationContext;
}

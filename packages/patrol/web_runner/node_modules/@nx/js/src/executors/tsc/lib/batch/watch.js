"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.watchTaskProjectsPackageJsonFileChanges = watchTaskProjectsPackageJsonFileChanges;
exports.watchTaskProjectsFileChangesForAssets = watchTaskProjectsFileChangesForAssets;
const devkit_1 = require("@nx/devkit");
const client_1 = require("nx/src/daemon/client/client");
const path_1 = require("path");
async function watchTaskProjectsPackageJsonFileChanges(taskInfos, callback) {
    const projects = [];
    const packageJsonTaskInfoMap = new Map();
    taskInfos.forEach((t) => {
        projects.push(t.context.projectName);
        packageJsonTaskInfoMap.set((0, path_1.join)(t.options.projectRoot, 'package.json'), t);
    });
    const unregisterFileWatcher = await client_1.daemonClient.registerFileWatcher({ watchProjects: projects }, (err, data) => {
        if (err === 'closed') {
            devkit_1.logger.error(`Watch error: Daemon closed the connection`);
            process.exit(1);
        }
        else if (err) {
            devkit_1.logger.error(`Watch error: ${err?.message ?? 'Unknown'}`);
        }
        else {
            const changedTasks = [];
            data.changedFiles.forEach((file) => {
                if (packageJsonTaskInfoMap.has(file.path)) {
                    changedTasks.push(packageJsonTaskInfoMap.get(file.path));
                }
            });
            if (changedTasks.length) {
                callback(changedTasks);
            }
        }
    });
    return () => unregisterFileWatcher();
}
async function watchTaskProjectsFileChangesForAssets(taskInfos) {
    const unregisterFileWatcher = await client_1.daemonClient.registerFileWatcher({
        watchProjects: taskInfos.map((t) => t.context.projectName),
        includeDependentProjects: true,
        includeGlobalWorkspaceFiles: true,
    }, (err, data) => {
        if (err === 'closed') {
            devkit_1.logger.error(`Watch error: Daemon closed the connection`);
            process.exit(1);
        }
        else if (err) {
            devkit_1.logger.error(`Watch error: ${err?.message ?? 'Unknown'}`);
        }
        else {
            taskInfos.forEach((t) => t.assetsHandler.processWatchEvents(data.changedFiles));
        }
    });
    return () => unregisterFileWatcher();
}

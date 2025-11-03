"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.watchForSingleFileChanges = watchForSingleFileChanges;
const devkit_1 = require("@nx/devkit");
const client_1 = require("nx/src/daemon/client/client");
const path_1 = require("path");
async function watchForSingleFileChanges(projectName, projectRoot, relativeFilePath, callback) {
    const unregisterFileWatcher = await client_1.daemonClient.registerFileWatcher({ watchProjects: [projectName] }, (err, data) => {
        if (err === 'closed') {
            devkit_1.logger.error(`Watch error: Daemon closed the connection`);
            process.exit(1);
        }
        else if (err) {
            devkit_1.logger.error(`Watch error: ${err?.message ?? 'Unknown'}`);
        }
        else if (data.changedFiles.some((file) => file.path == (0, path_1.join)(projectRoot, relativeFilePath))) {
            callback();
        }
    });
    return () => unregisterFileWatcher();
}

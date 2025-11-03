"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateLockFile = updateLockFile;
const devkit_1 = require("@nx/devkit");
const child_process_1 = require("child_process");
const client_1 = require("nx/src/daemon/client/client");
// eslint-disable-next-line @typescript-eslint/no-restricted-imports
const lock_file_1 = require("nx/src/plugins/js/lock-file/lock-file");
const semver_1 = require("semver");
async function updateLockFile(cwd, { dryRun, verbose, options, }) {
    if (options?.skipLockFileUpdate) {
        if (verbose) {
            console.log('\nSkipped lock file update because skipLockFileUpdate was set.');
        }
        return [];
    }
    const packageManager = (0, devkit_1.detectPackageManager)(cwd);
    if (packageManager === 'yarn' &&
        !(0, semver_1.gte)((0, devkit_1.getPackageManagerVersion)(packageManager), '2.0.0')) {
        // yarn classic does not store workspace data in the lock file, so we don't need to update it
        if (verbose) {
            console.log('\nSkipped lock file update because it is not necessary for Yarn Classic.');
        }
        return [];
    }
    const workspacesEnabled = (0, devkit_1.isWorkspacesEnabled)(packageManager, cwd);
    if (!workspacesEnabled) {
        if (verbose) {
            console.log(`\nSkipped lock file update because ${packageManager} workspaces are not enabled.`);
        }
        return [];
    }
    const isDaemonEnabled = client_1.daemonClient.enabled();
    if (!dryRun && isDaemonEnabled) {
        // if not in dry-run temporarily stop the daemon, as it will error if the lock file is updated
        await client_1.daemonClient.stop();
    }
    const packageManagerCommands = (0, devkit_1.getPackageManagerCommand)(packageManager);
    let installArgs = options?.installArgs || '';
    devkit_1.output.logSingleLine(`Updating ${packageManager} lock file`);
    let env = {};
    if (options?.installIgnoreScripts) {
        if (packageManager === 'yarn') {
            env = { YARN_ENABLE_SCRIPTS: 'false' };
        }
        else {
            // npm and pnpm use the same --ignore-scripts option
            installArgs = `${installArgs} --ignore-scripts`.trim();
        }
    }
    const lockFile = (0, lock_file_1.getLockFileName)(packageManager);
    const command = `${packageManagerCommands.updateLockFile} ${installArgs}`.trim();
    if (verbose) {
        if (dryRun) {
            console.log(`Would update ${lockFile} with the following command, but --dry-run was set:`);
        }
        else {
            console.log(`Updating ${lockFile} with the following command:`);
        }
        console.log(command);
    }
    if (dryRun) {
        return [];
    }
    execLockFileUpdate(command, cwd, env);
    if (isDaemonEnabled) {
        try {
            await client_1.daemonClient.startInBackground();
        }
        catch (e) {
            // If the daemon fails to start, we don't want to prevent the user from continuing, so we just log the error and move on
            if (verbose) {
                devkit_1.output.warn({
                    title: 'Unable to restart the Nx Daemon. It will be disabled until you run "nx reset"',
                    bodyLines: [e.message],
                });
            }
        }
    }
    return [lockFile];
}
function execLockFileUpdate(command, cwd, env) {
    try {
        const LARGE_BUFFER = 1024 * 1000000;
        (0, child_process_1.execSync)(command, {
            cwd,
            maxBuffer: LARGE_BUFFER,
            env: {
                ...process.env,
                ...env,
            },
            windowsHide: false,
        });
    }
    catch (e) {
        devkit_1.output.error({
            title: `Error updating lock file with command '${command}'`,
            bodyLines: [
                `Verify that '${command}' succeeds when run from the workspace root.`,
                `To configure a string of arguments to be passed to this command, set the 'release.version.versionActionsOptions.installArgs' property in nx.json.`,
                `To ignore install lifecycle scripts, set 'release.version.versionActionsOptions.installIgnoreScripts' to true in nx.json.`,
                `To disable this step entirely, set 'release.version.versionActionsOptions.skipLockFileUpdate' to true in nx.json.`,
            ],
        });
        throw e;
    }
}

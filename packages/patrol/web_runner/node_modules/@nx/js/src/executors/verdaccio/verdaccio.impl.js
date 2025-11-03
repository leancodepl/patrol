"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.verdaccioExecutor = verdaccioExecutor;
const devkit_1 = require("@nx/devkit");
const internal_1 = require("@nx/devkit/internal");
const child_process_1 = require("child_process");
const detectPort = require("detect-port");
const node_fs_1 = require("node:fs");
const path_1 = require("path");
const semver_1 = require("semver");
let childProcess;
let env = {
    SKIP_YARN_COREPACK_CHECK: 'true',
    ...process.env,
};
/**
 * - set npm and yarn to use local registry
 * - start verdaccio
 * - stop local registry when done
 */
async function verdaccioExecutor(options, context) {
    try {
        require.resolve('verdaccio');
    }
    catch (e) {
        throw new Error('Verdaccio is not installed. Please run `npm install verdaccio` or `yarn add verdaccio`');
    }
    if (options.storage) {
        options.storage = (0, path_1.resolve)(context.root, options.storage);
        if (options.clear && (0, node_fs_1.existsSync)(options.storage)) {
            (0, node_fs_1.rmSync)(options.storage, { recursive: true, force: true });
            console.log(`Cleared local registry storage folder ${options.storage}`);
        }
    }
    const port = await detectPort(options.port);
    if (port !== options.port) {
        devkit_1.logger.info(`Port ${options.port} was occupied. Using port ${port}.`);
        options.port = port;
    }
    const cleanupFunctions = options.location === 'none' ? [] : [setupNpm(options), setupYarn(options)];
    const processExitListener = (signal) => {
        for (const fn of cleanupFunctions) {
            fn();
        }
        if (childProcess) {
            childProcess.kill(signal);
        }
    };
    process.on('exit', processExitListener);
    process.on('SIGTERM', processExitListener);
    process.on('SIGINT', processExitListener);
    process.on('SIGHUP', processExitListener);
    try {
        await startVerdaccio(options, context.root);
    }
    catch (e) {
        devkit_1.logger.error('Failed to start verdaccio: ' + e?.toString());
        return {
            success: false,
            port: options.port,
        };
    }
    return {
        success: true,
        port: options.port,
    };
}
/**
 * Fork the verdaccio process: https://verdaccio.org/docs/verdaccio-programmatically/#using-fork-from-child_process-module
 */
function startVerdaccio(options, workspaceRoot) {
    return new Promise((resolve, reject) => {
        childProcess = (0, child_process_1.fork)(require.resolve('verdaccio/bin/verdaccio'), createVerdaccioOptions(options, workspaceRoot), {
            env: {
                ...process.env,
                VERDACCIO_HANDLE_KILL_SIGNALS: 'true',
                ...(options.storage
                    ? { VERDACCIO_STORAGE_PATH: options.storage }
                    : {}),
            },
            stdio: 'inherit',
        });
        childProcess.on('error', (err) => {
            reject(err);
        });
        childProcess.on('disconnect', (err) => {
            reject(err);
        });
        childProcess.on('exit', (code, signal) => {
            if (code === null)
                code = (0, internal_1.signalToCode)(signal);
            if (code === 0) {
                resolve(code);
            }
            else {
                reject(code);
            }
        });
    });
}
function createVerdaccioOptions(options, workspaceRoot) {
    const verdaccioArgs = [];
    if (options.config) {
        verdaccioArgs.push('--config', (0, path_1.join)(workspaceRoot, options.config));
    }
    else {
        options.port ??= 4873; // set default port if config is not provided
    }
    if (options.port) {
        const listenAddress = options.listenAddress
            ? `${options.listenAddress}:${options.port.toString()}`
            : options.port.toString();
        verdaccioArgs.push('--listen', listenAddress);
    }
    return verdaccioArgs;
}
function setupNpm(options) {
    try {
        (0, child_process_1.execSync)('npm --version', { env, windowsHide: false });
    }
    catch (e) {
        return () => { };
    }
    let npmRegistryPaths = [];
    const scopes = ['', ...(options.scopes || [])];
    try {
        scopes.forEach((scope) => {
            const registryName = scope ? `${scope}:registry` : 'registry';
            try {
                npmRegistryPaths.push((0, child_process_1.execSync)(`npm config get ${registryName} --location ${options.location}`, { env, windowsHide: false })
                    ?.toString()
                    ?.trim()
                    ?.replace('\u001b[2K\u001b[1G', '') // strip out ansi codes
                );
                (0, child_process_1.execSync)(`npm config set ${registryName} http://${options.listenAddress}:${options.port}/ --location ${options.location}`, { env, windowsHide: false });
                (0, child_process_1.execSync)(`npm config set //${options.listenAddress}:${options.port}/:_authToken="secretVerdaccioToken" --location ${options.location}`, { env, windowsHide: false });
                devkit_1.logger.info(`Set npm ${registryName} to http://${options.listenAddress}:${options.port}/`);
            }
            catch (e) {
                throw new Error(`Failed to set npm ${registryName} to http://${options.listenAddress}:${options.port}/: ${e.message}`);
            }
        });
        return () => {
            try {
                const currentNpmRegistryPath = (0, child_process_1.execSync)(`npm config get registry --location ${options.location}`, { env, windowsHide: false })
                    ?.toString()
                    ?.trim()
                    ?.replace('\u001b[2K\u001b[1G', ''); // strip out ansi codes
                scopes.forEach((scope, index) => {
                    const registryName = scope ? `${scope}:registry` : 'registry';
                    if (npmRegistryPaths[index] &&
                        currentNpmRegistryPath.includes(options.listenAddress)) {
                        (0, child_process_1.execSync)(`npm config set ${registryName} ${npmRegistryPaths[index]} --location ${options.location}`, { env, windowsHide: false });
                        devkit_1.logger.info(`Reset npm ${registryName} to ${npmRegistryPaths[index]}`);
                    }
                    else {
                        (0, child_process_1.execSync)(`npm config delete ${registryName} --location ${options.location}`, {
                            env,
                            windowsHide: false,
                        });
                        devkit_1.logger.info('Cleared custom npm registry');
                    }
                });
                (0, child_process_1.execSync)(`npm config delete //${options.listenAddress}:${options.port}/:_authToken  --location ${options.location}`, { env, windowsHide: false });
            }
            catch (e) {
                throw new Error(`Failed to reset npm registry: ${e.message}`);
            }
        };
    }
    catch (e) {
        throw new Error(`Failed to set npm registry to http://${options.listenAddress}:${options.port}/: ${e.message}`);
    }
}
function getYarnUnsafeHttpWhitelist(isYarnV1) {
    return !isYarnV1
        ? new Set(JSON.parse((0, child_process_1.execSync)(`yarn config get unsafeHttpWhitelist --json`, {
            env,
            windowsHide: false,
        }).toString()))
        : null;
}
function setYarnUnsafeHttpWhitelist(currentWhitelist, options) {
    if (currentWhitelist.size > 0) {
        (0, child_process_1.execSync)(`yarn config set unsafeHttpWhitelist --json '${JSON.stringify(Array.from(currentWhitelist))}'` + (options.location === 'user' ? ' --home' : ''), { env, windowsHide: false });
    }
    else {
        (0, child_process_1.execSync)(`yarn config unset unsafeHttpWhitelist` +
            (options.location === 'user' ? ' --home' : ''), { env, windowsHide: false });
    }
}
function setupYarn(options) {
    let isYarnV1;
    let yarnRegistryPaths = [];
    const scopes = ['', ...(options.scopes || [])];
    try {
        isYarnV1 =
            (0, semver_1.major)((0, child_process_1.execSync)('yarn --version', { env, windowsHide: false })
                .toString()
                .trim()) === 1;
    }
    catch {
        // This would fail if yarn is not installed which is okay
        return () => { };
    }
    try {
        const registryConfigName = isYarnV1 ? 'registry' : 'npmRegistryServer';
        scopes.forEach((scope) => {
            const scopeName = scope ? `${scope}:` : '';
            yarnRegistryPaths.push((0, child_process_1.execSync)(`yarn config get ${scopeName}${registryConfigName}`, {
                env,
                windowsHide: false,
            })
                ?.toString()
                ?.trim()
                ?.replace('\u001b[2K\u001b[1G', '') // strip out ansi codes
            );
            (0, child_process_1.execSync)(`yarn config set ${scopeName}${registryConfigName} http://${options.listenAddress}:${options.port}/` +
                (options.location === 'user' ? ' --home' : ''), { env, windowsHide: false });
            devkit_1.logger.info(`Set yarn ${scopeName}registry to http://${options.listenAddress}:${options.port}/`);
        });
        const currentWhitelist = getYarnUnsafeHttpWhitelist(isYarnV1);
        let whitelistedLocalhost = false;
        if (!isYarnV1 && !currentWhitelist.has(options.listenAddress)) {
            whitelistedLocalhost = true;
            currentWhitelist.add(options.listenAddress);
            setYarnUnsafeHttpWhitelist(currentWhitelist, options);
            devkit_1.logger.info(`Whitelisted http://${options.listenAddress}:${options.port}/ as an unsafe http server`);
        }
        return () => {
            try {
                const currentYarnRegistryPath = (0, child_process_1.execSync)(`yarn config get ${registryConfigName}`, { env, windowsHide: false })
                    ?.toString()
                    ?.trim()
                    ?.replace('\u001b[2K\u001b[1G', ''); // strip out ansi codes
                scopes.forEach((scope, index) => {
                    const registryName = scope
                        ? `${scope}:${registryConfigName}`
                        : registryConfigName;
                    if (yarnRegistryPaths[index] &&
                        currentYarnRegistryPath.includes(options.listenAddress)) {
                        (0, child_process_1.execSync)(`yarn config set ${registryName} ${yarnRegistryPaths[index]}` +
                            (options.location === 'user' ? ' --home' : ''), {
                            env,
                            windowsHide: false,
                        });
                        devkit_1.logger.info(`Reset yarn ${registryName} to ${yarnRegistryPaths[index]}`);
                    }
                    else {
                        (0, child_process_1.execSync)(`yarn config ${isYarnV1 ? 'delete' : 'unset'} ${registryName}` +
                            (options.location === 'user' ? ' --home' : ''), { env, windowsHide: false });
                        devkit_1.logger.info(`Cleared custom yarn ${registryConfigName}`);
                    }
                });
                if (whitelistedLocalhost) {
                    const currentWhitelist = getYarnUnsafeHttpWhitelist(isYarnV1);
                    if (currentWhitelist.has(options.listenAddress)) {
                        currentWhitelist.delete(options.listenAddress);
                        setYarnUnsafeHttpWhitelist(currentWhitelist, options);
                        devkit_1.logger.info(`Removed http://${options.listenAddress}:${options.port}/ as an unsafe http server`);
                    }
                }
            }
            catch (e) {
                throw new Error(`Failed to reset yarn registry: ${e.message}`);
            }
        };
    }
    catch (e) {
        throw new Error(`Failed to set yarn registry to http://${options.listenAddress}:${options.port}/: ${e.message}`);
    }
}
exports.default = verdaccioExecutor;

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseRegistryOptions = parseRegistryOptions;
exports.getNpmRegistry = getNpmRegistry;
exports.getNpmTag = getNpmTag;
const child_process_1 = require("child_process");
const fs_1 = require("fs");
const path_1 = require("path");
async function parseRegistryOptions(cwd, pkg, options, logWarnFn = console.warn) {
    const npmRcPath = (0, path_1.join)(pkg.packageRoot, '.npmrc');
    if ((0, fs_1.existsSync)(npmRcPath)) {
        const relativeNpmRcPath = (0, path_1.relative)(cwd, npmRcPath);
        logWarnFn(`\nIgnoring .npmrc file detected in the package root: ${relativeNpmRcPath}. Nested .npmrc files are not supported by npm. Only the .npmrc file at the root of the workspace will be used. To customize the registry or tag for specific packages, see https://nx.dev/recipes/nx-release/configure-custom-registries\n`);
    }
    const scope = pkg.packageJson.name.startsWith('@')
        ? pkg.packageJson.name.split('/')[0]
        : '';
    // If the package is scoped, then the registry argument that will
    // correctly override the registry in the .npmrc file must be scoped.
    const registryConfigKey = scope ? `${scope}:registry` : 'registry';
    const publishConfigRegistry = pkg.packageJson.publishConfig?.[registryConfigKey];
    // Even though it won't override the actual registry that's actually used,
    // the user might think otherwise, so we should still warn if the user has
    // set a 'registry' in 'publishConfig' for a scoped package.
    if (publishConfigRegistry || pkg.packageJson.publishConfig?.registry) {
        const relativePackageJsonPath = (0, path_1.relative)(cwd, (0, path_1.join)(pkg.packageRoot, 'package.json'));
        if (options.registry) {
            logWarnFn(`\nRegistry detected in the 'publishConfig' of the package manifest: ${relativePackageJsonPath}. This will override your registry option set in the project configuration or passed via the --registry argument, which is why configuring the registry with 'publishConfig' is not recommended. For details, see https://nx.dev/recipes/nx-release/configure-custom-registries\n`);
        }
        else {
            logWarnFn(`\nRegistry detected in the 'publishConfig' of the package manifest: ${relativePackageJsonPath}. Configuring the registry in this way is not recommended because it prevents the registry from being overridden in project configuration or via the --registry argument. To customize the registry for specific packages, see https://nx.dev/recipes/nx-release/configure-custom-registries\n`);
        }
    }
    const registry = 
    // `npm publish` will always use the publishConfig registry if it exists, even over the --registry arg
    publishConfigRegistry ||
        options.registry ||
        (await getNpmRegistry(cwd, scope));
    const tag = options.tag || (await getNpmTag(cwd));
    return { registry, tag, registryConfigKey };
}
/**
 * Returns the npm registry that is used for publishing.
 *
 * @param scope the scope of the package for which to determine the registry
 * @param cwd the directory where the npm config should be read from
 */
async function getNpmRegistry(cwd, scope) {
    let registry;
    if (scope) {
        registry = await getNpmConfigValue(`${scope}:registry`, cwd);
    }
    if (!registry) {
        registry = await getNpmConfigValue('registry', cwd);
    }
    return registry;
}
/**
 * Returns the npm tag that is used for publishing.
 *
 * @param cwd the directory where the npm config should be read from
 */
async function getNpmTag(cwd) {
    // npm does not support '@scope:tag' in the npm config, so we only need to check for 'tag'.
    return getNpmConfigValue('tag', cwd);
}
async function getNpmConfigValue(key, cwd) {
    try {
        const result = await execAsync(`npm config get ${key}`, cwd);
        return result === 'undefined' ? undefined : result;
    }
    catch (e) {
        return Promise.resolve(undefined);
    }
}
async function execAsync(command, cwd) {
    // Must be non-blocking async to allow spinner to render
    return new Promise((resolve, reject) => {
        (0, child_process_1.exec)(command, { cwd, windowsHide: false }, (error, stdout, stderr) => {
            if (error) {
                return reject((stderr ? `${stderr}\n` : '') + error);
            }
            return resolve(stdout.trim());
        });
    });
}

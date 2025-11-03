"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.afterAllProjectsVersioned = void 0;
const devkit_1 = require("@nx/devkit");
const catalog_1 = require("@nx/devkit/src/utils/catalog");
const node_child_process_1 = require("node:child_process");
const node_path_1 = require("node:path");
const release_1 = require("nx/release");
const npm_config_1 = require("../utils/npm-config");
const update_lock_file_1 = require("./utils/update-lock-file");
const chalk = require("chalk");
const semver_1 = require("./utils/semver");
const afterAllProjectsVersioned = async (cwd, { rootVersionActionsOptions, ...opts }) => {
    return {
        changedFiles: await (0, update_lock_file_1.updateLockFile)(cwd, {
            ...opts,
            options: rootVersionActionsOptions,
        }),
        deletedFiles: [],
    };
};
exports.afterAllProjectsVersioned = afterAllProjectsVersioned;
// Cache at the module level to avoid re-detecting the package manager for each instance
let pm;
class JsVersionActions extends release_1.VersionActions {
    constructor() {
        super(...arguments);
        this.validManifestFilenames = ['package.json'];
    }
    async readCurrentVersionFromSourceManifest(tree) {
        const sourcePackageJsonPath = (0, node_path_1.join)(this.projectGraphNode.data.root, 'package.json');
        try {
            const packageJson = (0, devkit_1.readJson)(tree, sourcePackageJsonPath);
            return {
                manifestPath: sourcePackageJsonPath,
                currentVersion: packageJson.version,
            };
        }
        catch {
            throw new Error(`Unable to determine the current version for project "${this.projectGraphNode.name}" from ${sourcePackageJsonPath}, please ensure that the "version" field is set within the package.json file`);
        }
    }
    async readCurrentVersionFromRegistry(tree, currentVersionResolverMetadata) {
        const sourcePackageJsonPath = (0, node_path_1.join)(this.projectGraphNode.data.root, 'package.json');
        const packageJson = (0, devkit_1.readJson)(tree, sourcePackageJsonPath);
        const packageName = packageJson.name;
        const metadata = currentVersionResolverMetadata;
        const registryArg = typeof metadata?.registry === 'string' ? metadata.registry : undefined;
        const tagArg = typeof metadata?.tag === 'string' ? metadata.tag : undefined;
        const warnFn = (message) => {
            console.log(chalk.keyword('orange')(message));
        };
        const { registry, tag, registryConfigKey } = await (0, npm_config_1.parseRegistryOptions)(devkit_1.workspaceRoot, {
            packageRoot: this.projectGraphNode.data.root,
            packageJson,
        }, {
            registry: registryArg,
            tag: tagArg,
        }, warnFn);
        let currentVersion = null;
        try {
            // Must be non-blocking async to allow spinner to render
            currentVersion = await new Promise((resolve, reject) => {
                (0, node_child_process_1.exec)(`npm view ${packageName} version --"${registryConfigKey}=${registry}" --tag=${tag}`, {
                    windowsHide: false,
                }, (error, stdout, stderr) => {
                    if (error) {
                        return reject(error);
                    }
                    // Only reject on stderr if it contains actual errors, not just npm warnings
                    // npm 11+ writes "npm warn" messages to stderr even on successful commands
                    if (stderr &&
                        !stderr
                            .trim()
                            .split('\n')
                            .every((line) => line.startsWith('npm warn'))) {
                        return reject(stderr);
                    }
                    return resolve(stdout.trim());
                });
            });
        }
        catch { }
        return {
            currentVersion,
            // Make troubleshooting easier by including the registry and tag data in the log text
            logText: `"${registryConfigKey}=${registry}" tag=${tag}`,
        };
    }
    async readCurrentVersionOfDependency(tree, projectGraph, dependencyProjectName) {
        const sourcePackageJsonPath = (0, node_path_1.join)(this.projectGraphNode.data.root, 'package.json');
        const json = (0, devkit_1.readJson)(tree, sourcePackageJsonPath);
        // Resolve the package name from the project graph metadata, as it may not match the project name
        const dependencyPackageName = projectGraph.nodes[dependencyProjectName].data.metadata?.js?.packageName;
        const dependencyTypes = [
            'dependencies',
            'devDependencies',
            'peerDependencies',
            'optionalDependencies',
        ];
        let currentVersion = null;
        let dependencyCollection = null;
        for (const depType of dependencyTypes) {
            if (json[depType] && json[depType][dependencyPackageName]) {
                currentVersion = json[depType][dependencyPackageName];
                dependencyCollection = depType;
                break;
            }
        }
        // Resolve catalog references if needed
        if (currentVersion) {
            const catalogManager = (0, catalog_1.getCatalogManager)(tree.root);
            if (catalogManager?.isCatalogReference(currentVersion)) {
                currentVersion = catalogManager.resolveCatalogReference(tree, dependencyPackageName, currentVersion);
            }
        }
        return {
            currentVersion,
            dependencyCollection,
        };
    }
    async updateProjectVersion(tree, newVersion) {
        const logMessages = [];
        for (const manifestToUpdate of this.manifestsToUpdate) {
            (0, devkit_1.updateJson)(tree, manifestToUpdate.manifestPath, (json) => {
                json.version = newVersion;
                return json;
            });
            logMessages.push(`✍️  New version ${newVersion} written to manifest: ${manifestToUpdate.manifestPath}`);
        }
        return logMessages;
    }
    async updateProjectDependencies(tree, projectGraph, dependenciesToUpdate) {
        let numDependenciesToUpdate = Object.keys(dependenciesToUpdate).length;
        if (numDependenciesToUpdate === 0) {
            return [];
        }
        const logMessages = [];
        const catalogUpdates = [];
        const catalogManager = (0, catalog_1.getCatalogManager)(tree.root);
        for (const manifestToUpdate of this.manifestsToUpdate) {
            (0, devkit_1.updateJson)(tree, manifestToUpdate.manifestPath, (json) => {
                const dependencyTypes = [
                    'dependencies',
                    'devDependencies',
                    'peerDependencies',
                    'optionalDependencies',
                ];
                const preserveMatchingDependencyRanges = this.finalConfigForProject.preserveMatchingDependencyRanges === true
                    ? dependencyTypes
                    : this.finalConfigForProject.preserveMatchingDependencyRanges ===
                        false
                        ? []
                        : this.finalConfigForProject.preserveMatchingDependencyRanges ||
                            dependencyTypes;
                for (const depType of dependencyTypes) {
                    if (json[depType]) {
                        for (const [dep, version] of Object.entries(dependenciesToUpdate)) {
                            // Resolve the package name from the project graph metadata, as it may not match the project name
                            const packageName = projectGraph.nodes[dep].data.metadata?.js?.packageName;
                            if (!packageName) {
                                throw new Error(`Unable to determine the package name for project "${dep}" from the project graph metadata, please ensure that the "@nx/js" plugin is installed and the project graph has been built. If the issue persists, please report this issue on https://github.com/nrwl/nx/issues`);
                            }
                            const currentVersion = json[depType][packageName];
                            if (currentVersion) {
                                if (catalogManager?.isCatalogReference(currentVersion)) {
                                    // collect the catalog updates so we can update the catalog definitions later
                                    const catalogRef = catalogManager.parseCatalogReference(currentVersion);
                                    catalogUpdates.push({
                                        packageName,
                                        version,
                                        catalogName: catalogRef.catalogName,
                                    });
                                    numDependenciesToUpdate--;
                                    continue;
                                }
                                // Check if other local dependency protocols should be preserved
                                else if (manifestToUpdate.preserveLocalDependencyProtocols &&
                                    this.isLocalDependencyProtocol(currentVersion)) {
                                    // Reduce the count appropriately to avoid confusing user-facing logs
                                    numDependenciesToUpdate--;
                                    continue;
                                }
                                else if (preserveMatchingDependencyRanges.includes(depType) &&
                                    !this.isLocalDependencyProtocol(currentVersion)) {
                                    // If the dependency is specified using a range, do some additional processing to determine whether to update the version
                                    if ((0, semver_1.isValidRange)(currentVersion) &&
                                        !(0, semver_1.isMatchingDependencyRange)(version, currentVersion)) {
                                        throw new Error(`"preserveMatchingDependencyRanges" is enabled for "${depType}" and the new version "${version}" is outside the current range for "${packageName}" in manifest "${manifestToUpdate.manifestPath}". Please update the range before releasing.`);
                                    }
                                    else if ((0, semver_1.isValidRange)(currentVersion)) {
                                        // it is a range, but it is valid
                                        continue;
                                    }
                                }
                                json[depType][packageName] = version;
                            }
                        }
                    }
                }
                return json;
            });
            // If we ignored local dependecy protocols, then we could have dynamically ended up with zero here and we should not log anything related to dependencies
            if (numDependenciesToUpdate === 0) {
                return [];
            }
            const depText = numDependenciesToUpdate === 1 ? 'dependency' : 'dependencies';
            logMessages.push(`✍️  Updated ${numDependenciesToUpdate} ${depText} in manifest: ${manifestToUpdate.manifestPath}`);
        }
        // Update catalog definitions in pnpm-workspace.yaml
        if (catalogUpdates.length > 0) {
            // catalogManager is guaranteed to be defined when there are catalog updates
            catalogManager.updateCatalogVersions(tree, catalogUpdates);
            const catalogText = catalogUpdates.length === 1 ? 'entry' : 'entries';
            logMessages.push(`✍️  Updated ${catalogUpdates.length} catalog ${catalogText} in pnpm-workspace.yaml`);
        }
        return logMessages;
    }
    // NOTE: The TODOs were carried over from the original implementation, they are not yet implemented
    isLocalDependencyProtocol(versionSpecifier) {
        const localPackageProtocols = [
            'file:', // all package managers
            'workspace:', // not npm
            // TODO: Support portal protocol at the project graph level before enabling here
            // 'portal:', // modern yarn only
        ];
        // Not using a supported local protocol
        if (!localPackageProtocols.some((protocol) => versionSpecifier.startsWith(protocol))) {
            return false;
        }
        // Supported by all package managers
        if (versionSpecifier.startsWith('file:')) {
            return true;
        }
        // Determine specific package manager in use
        if (!pm) {
            pm = (0, devkit_1.detectPackageManager)();
            // pmVersion = getPackageManagerVersion(pm);
        }
        if (pm === 'npm' && versionSpecifier.startsWith('workspace:')) {
            throw new Error(`The "workspace:" protocol is not yet supported by npm (https://github.com/npm/rfcs/issues/765). Please ensure you have a valid setup according to your package manager before attempting to release packages.`);
        }
        // TODO: Support portal protocol at the project graph level before enabling here
        // if (
        //   version.startsWith('portal:') &&
        //   (pm !== 'yarn' || lt(pmVersion, '2.0.0'))
        // ) {
        //   throw new Error(
        //     `The "portal:" protocol is only supported by yarn@2.0.0 and above. Please ensure you have a valid setup according to your package manager before attempting to release packages.`
        //   );
        // }
        return true;
    }
}
exports.default = JsVersionActions;

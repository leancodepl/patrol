"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.findNpmDependencies = findNpmDependencies;
const path_1 = require("path");
const configuration_1 = require("nx/src/config/configuration");
const devkit_1 = require("@nx/devkit");
const fileutils_1 = require("nx/src/utils/fileutils");
const project_graph_1 = require("nx/src/config/project-graph");
const ts_config_1 = require("./typescript/ts-config");
const task_hasher_1 = require("nx/src/hasher/task-hasher");
/**
 * Finds all npm dependencies and their expected versions for a given project.
 */
function findNpmDependencies(workspaceRoot, sourceProject, projectGraph, projectFileMap, buildTarget, options = {}) {
    let seen = null;
    if (options.includeTransitiveDependencies) {
        seen = new Set();
    }
    const results = {};
    function collectAll(currentProject, collectedDeps) {
        if (seen?.has(currentProject.name))
            return;
        seen?.add(currentProject.name);
        collectDependenciesFromFileMap(workspaceRoot, currentProject, projectGraph, projectFileMap, buildTarget, options.ignoredFiles, options.useLocalPathsForWorkspaceDependencies, collectedDeps);
        collectHelperDependencies(workspaceRoot, currentProject, projectGraph, buildTarget, options.runtimeHelpers, collectedDeps);
        if (options.includeTransitiveDependencies) {
            const projectDeps = projectGraph.dependencies[currentProject.name];
            for (const dep of projectDeps) {
                const projectDep = projectGraph.nodes[dep.target];
                if (projectDep)
                    collectAll(projectDep, collectedDeps);
            }
        }
    }
    collectAll(sourceProject, results);
    return results;
}
// Keep track of workspace libs we already read package.json for so we don't read from disk again.
const seenWorkspaceDeps = {};
function collectDependenciesFromFileMap(workspaceRoot, sourceProject, projectGraph, projectFileMap, buildTarget, ignoredFiles, useLocalPathsForWorkspaceDependencies, npmDeps) {
    const rawFiles = projectFileMap[sourceProject.name];
    if (!rawFiles)
        return;
    // If build target does not exist in project, use all files as input.
    // This is needed for transitive dependencies for apps -- where libs may not be buildable.
    const inputs = sourceProject.data.targets[buildTarget]
        ? (0, task_hasher_1.getTargetInputs)((0, configuration_1.readNxJson)(), sourceProject, buildTarget).selfInputs
        : ['{projectRoot}/**/*'];
    if (ignoredFiles) {
        for (const pattern of ignoredFiles) {
            inputs.push(`!${pattern}`);
        }
    }
    const files = (0, task_hasher_1.filterUsingGlobPatterns)(sourceProject.data.root, projectFileMap[sourceProject.name] || [], inputs);
    for (const fileData of files) {
        if (!fileData.deps ||
            fileData.file ===
                (0, devkit_1.joinPathFragments)(sourceProject.data.root, 'package.json')) {
            continue;
        }
        for (const dep of fileData.deps) {
            const target = (0, project_graph_1.fileDataDepTarget)(dep);
            // If the node is external, then read package info from `data`.
            const externalDep = projectGraph.externalNodes[target];
            if (externalDep?.type === 'npm') {
                npmDeps[externalDep.data.packageName] = externalDep.data.version;
                continue;
            }
            // If node is internal, then try reading package info from `package.json` (which must exist for this to work).
            const workspaceDep = projectGraph.nodes[target];
            if (!workspaceDep)
                continue;
            const cached = seenWorkspaceDeps[workspaceDep.name];
            if (cached) {
                npmDeps[cached.name] = cached.version;
            }
            else {
                const packageJson = readPackageJson(workspaceDep, workspaceRoot);
                if (
                // Check that this is a buildable project, otherwise it cannot be a dependency in package.json.
                workspaceDep.data.targets[buildTarget] &&
                    // Make sure package.json exists and has a valid name.
                    packageJson?.name) {
                    let version;
                    if (useLocalPathsForWorkspaceDependencies) {
                        // Find the relative `file:...` path and use that as the version value.
                        // This is useful for monorepos like Nx where the release will handle setting the correct version in dist.
                        const depRoot = (0, path_1.join)(workspaceRoot, workspaceDep.data.root);
                        const ownRoot = (0, path_1.join)(workspaceRoot, sourceProject.data.root);
                        const relativePath = (0, path_1.relative)(ownRoot, depRoot);
                        const filePath = (0, devkit_1.normalizePath)(relativePath); // normalize slashes for windows
                        version = `file:${filePath}`;
                    }
                    else {
                        // Otherwise, read the version from the dependencies `package.json` file.
                        // This is useful for monorepos that commit release versions.
                        // Users can also set version as "*" in source `package.json` files, which will be the value set here.
                        // This is useful if they use custom scripts to update them in dist.
                        version = packageJson.version ?? '*'; // fallback in case version is missing
                    }
                    npmDeps[packageJson.name] = version;
                    seenWorkspaceDeps[workspaceDep.name] = {
                        name: packageJson.name,
                        version,
                    };
                }
            }
        }
    }
}
function readPackageJson(project, workspaceRoot) {
    const packageJsonPath = (0, path_1.join)(workspaceRoot, project.data.root, 'package.json');
    if ((0, fileutils_1.fileExists)(packageJsonPath))
        return (0, devkit_1.readJsonFile)(packageJsonPath);
    return null;
}
function collectHelperDependencies(workspaceRoot, sourceProject, projectGraph, buildTarget, runtimeHelpers, npmDeps) {
    if (runtimeHelpers?.length > 0) {
        for (const helper of runtimeHelpers) {
            if (!npmDeps[helper] &&
                projectGraph.externalNodes[`npm:${helper}`]?.type === 'npm') {
                npmDeps[helper] =
                    projectGraph.externalNodes[`npm:${helper}`].data.version;
            }
        }
        return;
    }
    const target = sourceProject.data.targets[buildTarget];
    if (!target)
        return;
    if (target.executor === '@nx/js:tsc' && target.options?.tsConfig) {
        const tsConfig = (0, ts_config_1.readTsConfig)((0, path_1.join)(workspaceRoot, target.options.tsConfig));
        if (tsConfig?.options['importHelpers'] &&
            projectGraph.externalNodes['npm:tslib']?.type === 'npm') {
            npmDeps['tslib'] = projectGraph.externalNodes['npm:tslib'].data.version;
        }
    }
    if (target.executor === '@nx/js:swc') {
        const swcConfigPath = target.options.swcrc
            ? (0, path_1.join)(workspaceRoot, target.options.swcrc)
            : (0, path_1.join)(workspaceRoot, sourceProject.data.root, '.swcrc');
        const swcConfig = (0, fileutils_1.fileExists)(swcConfigPath)
            ? (0, devkit_1.readJsonFile)(swcConfigPath)
            : {};
        if (swcConfig?.jsc?.externalHelpers &&
            projectGraph.externalNodes['npm:@swc/helpers']?.type === 'npm') {
            npmDeps['@swc/helpers'] =
                projectGraph.externalNodes['npm:@swc/helpers'].data.version;
        }
    }
    // For inferred targets or manually added run-commands, check if user is using `tsc` in build target.
    if (target.executor === 'nx:run-commands' &&
        /\btsc\b/.test(target.options.command)) {
        const tsConfigFileName = (0, ts_config_1.getRootTsConfigFileName)();
        if (tsConfigFileName) {
            const tsConfig = (0, ts_config_1.readTsConfig)((0, path_1.join)(workspaceRoot, tsConfigFileName));
            if (tsConfig?.options['importHelpers'] &&
                projectGraph.externalNodes['npm:tslib']?.type === 'npm') {
                npmDeps['tslib'] = projectGraph.externalNodes['npm:tslib'].data.version;
            }
        }
    }
}

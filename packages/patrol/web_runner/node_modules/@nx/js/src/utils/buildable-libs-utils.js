"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.calculateProjectBuildableDependencies = calculateProjectBuildableDependencies;
exports.calculateProjectDependencies = calculateProjectDependencies;
exports.calculateDependenciesFromTaskGraph = calculateDependenciesFromTaskGraph;
exports.computeCompilerOptionsPaths = computeCompilerOptionsPaths;
exports.createTmpTsConfig = createTmpTsConfig;
exports.updatePaths = updatePaths;
exports.updateBuildableProjectPackageJsonDependencies = updateBuildableProjectPackageJsonDependencies;
const devkit_1 = require("@nx/devkit");
const fs_1 = require("fs");
const operators_1 = require("nx/src/project-graph/operators");
const fileutils_1 = require("nx/src/utils/fileutils");
const output_1 = require("nx/src/utils/output");
const path_1 = require("path");
const ts_config_1 = require("./typescript/ts-config");
const crypto_1 = require("crypto");
const project_graph_1 = require("nx/src/config/project-graph");
function isBuildable(target, node) {
    return (node.data.targets &&
        node.data.targets[target] &&
        node.data.targets[target].executor !== '');
}
function calculateProjectBuildableDependencies(taskGraph, projGraph, root, projectName, targetName, configurationName, shallow) {
    if (process.env.NX_BUILDABLE_LIBRARIES_TASK_GRAPH === 'true' && taskGraph) {
        return calculateDependenciesFromTaskGraph(taskGraph, projGraph, root, projectName, targetName, configurationName, shallow);
    }
    return calculateProjectDependencies(projGraph, root, projectName, targetName, configurationName, shallow);
}
function calculateProjectDependencies(projGraph, root, projectName, targetName, configurationName, shallow) {
    const target = projGraph.nodes[projectName];
    // gather the library dependencies
    const nonBuildableDependencies = [];
    const topLevelDependencies = [];
    const collectedDeps = collectDependencies(projectName, projGraph, [], shallow);
    const missing = collectedDeps.reduce((missing, { name: dep }) => {
        const depNode = projGraph.nodes[dep] || projGraph.externalNodes[dep];
        if (!depNode) {
            missing = missing || [];
            missing.push(dep);
        }
        return missing;
    }, null);
    if (missing) {
        throw new Error(`Unable to find ${missing.join(', ')} in project graph.`);
    }
    const dependencies = collectedDeps
        .map(({ name: dep, isTopLevel }) => {
        let project = null;
        const depNode = projGraph.nodes[dep] || projGraph.externalNodes[dep];
        if ((0, project_graph_1.isProjectGraphProjectNode)(depNode) && depNode.type === 'lib') {
            if (isBuildable(targetName, depNode)) {
                const libPackageJsonPath = (0, path_1.join)(root, depNode.data.root, 'package.json');
                project = {
                    name: (0, fileutils_1.fileExists)(libPackageJsonPath)
                        ? (0, devkit_1.readJsonFile)(libPackageJsonPath).name // i.e. @workspace/mylib
                        : dep,
                    outputs: (0, devkit_1.getOutputsForTargetAndConfiguration)({
                        project: projectName,
                        target: targetName,
                        configuration: configurationName,
                    }, {}, depNode),
                    node: depNode,
                };
            }
            else {
                nonBuildableDependencies.push(dep);
            }
        }
        else if ((0, project_graph_1.isProjectGraphExternalNode)(depNode)) {
            project = {
                name: depNode.data.packageName,
                outputs: [],
                node: depNode,
            };
        }
        if (project && isTopLevel) {
            topLevelDependencies.push(project);
        }
        return project;
    })
        .filter((x) => !!x);
    dependencies.sort((a, b) => (a.name > b.name ? 1 : b.name > a.name ? -1 : 0));
    return {
        target,
        dependencies,
        nonBuildableDependencies,
        topLevelDependencies,
    };
}
function collectDependencies(project, projGraph, acc, shallow, areTopLevelDeps = true) {
    (projGraph.dependencies[project] || []).forEach((dependency) => {
        const existingEntry = acc.find((dep) => dep.name === dependency.target);
        if (!existingEntry) {
            // Temporary skip this. Currently the set of external nodes is built from package.json, not lock file.
            // As a result, some nodes might be missing. This should not cause any issues, we can just skip them.
            if (dependency.target.startsWith('npm:') &&
                !projGraph.externalNodes[dependency.target])
                return;
            acc.push({ name: dependency.target, isTopLevel: areTopLevelDeps });
            const isInternalTarget = projGraph.nodes[dependency.target];
            if (!shallow && isInternalTarget) {
                collectDependencies(dependency.target, projGraph, acc, shallow, false);
            }
        }
        else if (areTopLevelDeps && !existingEntry.isTopLevel) {
            existingEntry.isTopLevel = true;
        }
    });
    return acc;
}
function readTsConfigWithRemappedPaths(originalTsconfigPath, generatedTsconfigPath, dependencies, workspaceRoot) {
    const generatedTsConfig = { compilerOptions: {} };
    const normalizedTsConfig = (0, path_1.resolve)(workspaceRoot, originalTsconfigPath);
    const normalizedGeneratedTsConfigDir = (0, path_1.resolve)(workspaceRoot, (0, path_1.dirname)(generatedTsconfigPath));
    generatedTsConfig.extends = (0, path_1.relative)(normalizedGeneratedTsConfigDir, normalizedTsConfig);
    generatedTsConfig.compilerOptions.paths = computeCompilerOptionsPaths(normalizedTsConfig, dependencies);
    if (process.env.NX_VERBOSE_LOGGING_PATH_MAPPINGS === 'true') {
        output_1.output.log({
            title: 'TypeScript path mappings have been rewritten.',
        });
        console.log(JSON.stringify(generatedTsConfig.compilerOptions.paths, null, 2));
    }
    return generatedTsConfig;
}
function calculateDependenciesFromTaskGraph(taskGraph, projectGraph, root, projectName, targetName, configurationName, shallow) {
    const target = projectGraph.nodes[projectName];
    const nonBuildableDependencies = [];
    const topLevelDependencies = [];
    const dependentTasks = collectDependentTasks(projectName, `${projectName}:${targetName}${configurationName ? `:${configurationName}` : ''}`, taskGraph, projectGraph, shallow);
    const npmDependencies = collectNpmDependencies(projectName, projectGraph, !shallow ? dependentTasks : undefined);
    const dependencies = [];
    for (const [taskName, { isTopLevel }] of dependentTasks) {
        let project = null;
        const depTask = taskGraph.tasks[taskName];
        const depProjectNode = projectGraph.nodes?.[depTask.target.project];
        if (depProjectNode?.type !== 'lib') {
            continue;
        }
        let outputs = (0, devkit_1.getOutputsForTargetAndConfiguration)(depTask.target, depTask.overrides, depProjectNode);
        if (outputs.length === 0) {
            nonBuildableDependencies.push(depTask.target.project);
            continue;
        }
        const libPackageJsonPath = (0, path_1.join)(root, depProjectNode.data.root, 'package.json');
        project = {
            name: (0, fileutils_1.fileExists)(libPackageJsonPath)
                ? (0, devkit_1.readJsonFile)(libPackageJsonPath).name // i.e. @workspace/mylib
                : depTask.target.project,
            outputs,
            node: depProjectNode,
        };
        if (isTopLevel) {
            topLevelDependencies.push(project);
        }
        dependencies.push(project);
    }
    for (const { project, isTopLevel } of npmDependencies) {
        if (isTopLevel) {
            topLevelDependencies.push(project);
        }
        dependencies.push(project);
    }
    dependencies.sort((a, b) => (a.name > b.name ? 1 : b.name > a.name ? -1 : 0));
    return {
        target,
        dependencies,
        nonBuildableDependencies,
        topLevelDependencies,
    };
}
function collectNpmDependencies(projectName, projectGraph, dependentTasks, collectedPackages = new Set(), isTopLevel = true) {
    const dependencies = projectGraph.dependencies[projectName]
        .map((dep) => {
        const projectNode = projectGraph.nodes?.[dep.target] ??
            projectGraph.externalNodes?.[dep.target];
        if (projectNode?.type !== 'npm' ||
            collectedPackages.has(projectNode.data.packageName)) {
            return null;
        }
        const project = {
            name: projectNode.data.packageName,
            outputs: [],
            node: projectNode,
        };
        collectedPackages.add(project.name);
        return { project, isTopLevel };
    })
        .filter((x) => !!x);
    if (dependentTasks?.size) {
        for (const [, { project: projectName }] of dependentTasks) {
            dependencies.push(...collectNpmDependencies(projectName, projectGraph, undefined, collectedPackages, false));
        }
    }
    return dependencies;
}
function collectDependentTasks(project, task, taskGraph, projectGraph, shallow, areTopLevelDeps = true, dependentTasks = new Map()) {
    for (const depTask of taskGraph.dependencies[task] ?? []) {
        if (dependentTasks.has(depTask)) {
            if (!dependentTasks.get(depTask).isTopLevel && areTopLevelDeps) {
                dependentTasks.get(depTask).isTopLevel = true;
            }
            continue;
        }
        const { project: depTaskProject } = (0, devkit_1.parseTargetString)(depTask, projectGraph);
        if (depTaskProject !== project) {
            dependentTasks.set(depTask, {
                project: depTaskProject,
                isTopLevel: areTopLevelDeps,
            });
        }
        if (!shallow) {
            collectDependentTasks(depTaskProject, depTask, taskGraph, projectGraph, shallow, depTaskProject === project && areTopLevelDeps, dependentTasks);
        }
    }
    return dependentTasks;
}
/**
 * Util function to create tsconfig compilerOptions object with support for workspace libs paths.
 *
 *
 *
 * @param tsConfig String of config path or object parsed via ts.parseJsonConfigFileContent.
 * @param dependencies Dependencies calculated by Nx.
 */
function computeCompilerOptionsPaths(tsConfig, dependencies) {
    const paths = (0, ts_config_1.readTsConfigPaths)(tsConfig) || {};
    updatePaths(dependencies, paths);
    return paths;
}
function createTmpTsConfig(tsconfigPath, workspaceRoot, projectRoot, dependencies, useWorkspaceAsBaseUrl = false) {
    const tmpTsConfigPath = (0, path_1.join)(workspaceRoot, 'tmp', projectRoot, process.env.NX_TASK_TARGET_TARGET ?? 'build', `tsconfig.generated.${(0, crypto_1.randomUUID)()}.json`);
    if (tsconfigPath === tmpTsConfigPath) {
        return tsconfigPath;
    }
    const parsedTSConfig = readTsConfigWithRemappedPaths(tsconfigPath, tmpTsConfigPath, dependencies, workspaceRoot);
    process.on('exit', () => cleanupTmpTsConfigFile(tmpTsConfigPath));
    if (useWorkspaceAsBaseUrl) {
        parsedTSConfig.compilerOptions ??= {};
        parsedTSConfig.compilerOptions.baseUrl = workspaceRoot;
    }
    (0, devkit_1.writeJsonFile)(tmpTsConfigPath, parsedTSConfig);
    return (0, path_1.join)(tmpTsConfigPath);
}
function cleanupTmpTsConfigFile(tmpTsConfigPath) {
    try {
        if (tmpTsConfigPath) {
            (0, fs_1.unlinkSync)(tmpTsConfigPath);
        }
    }
    catch (e) { }
}
function updatePaths(dependencies, paths) {
    const pathsKeys = Object.keys(paths);
    // For each registered dependency
    dependencies
        .filter((dep) => (0, project_graph_1.isProjectGraphProjectNode)(dep.node))
        .forEach((dep) => {
        // If there are outputs
        if (dep.outputs && dep.outputs.length > 0) {
            // Directly map the dependency name to the output paths (dist/packages/..., etc.)
            paths[dep.name] = dep.outputs.map((output) => output.replace(/(\*|\/[^\/]*\*).*$/, ''));
            // check for secondary entrypoints
            // For each registered path
            for (const path of pathsKeys) {
                const nestedName = `${dep.name}/`;
                // If the path points to the current dependency and is nested (/)
                if (path.startsWith(nestedName)) {
                    const nestedPart = path.slice(nestedName.length);
                    // Bind potential secondary endpoints for ng-packagr projects
                    let mappedPaths = dep.outputs.map((output) => `${output}/${nestedPart}`);
                    const { root } = dep.node.data;
                    // Update nested mappings to point to the dependency's output paths
                    mappedPaths = mappedPaths.concat(paths[path].flatMap((p) => dep.outputs.flatMap((output) => {
                        const basePath = p.replace(root, output);
                        return [
                            // extension-less path to support compiled output
                            basePath.replace(new RegExp(`${(0, path_1.extname)(basePath)}$`, 'gi'), ''),
                            // original path with the root re-mapped to the output path
                            basePath,
                        ];
                    })));
                    paths[path] = mappedPaths;
                }
            }
        }
    });
}
/**
 * Updates the peerDependencies section in the `dist/lib/xyz/package.json` with
 * the proper dependency and version
 */
function updateBuildableProjectPackageJsonDependencies(root, projectName, targetName, configurationName, node, dependencies, typeOfDependency = 'dependencies') {
    const outputs = (0, devkit_1.getOutputsForTargetAndConfiguration)({
        project: projectName,
        target: targetName,
        configuration: configurationName,
    }, {}, node);
    const packageJsonPath = `${outputs[0]}/package.json`;
    let packageJson;
    let workspacePackageJson;
    try {
        packageJson = (0, devkit_1.readJsonFile)(packageJsonPath);
        workspacePackageJson = (0, devkit_1.readJsonFile)(`${root}/package.json`);
    }
    catch (e) {
        // cannot find or invalid package.json
        return;
    }
    packageJson.dependencies = packageJson.dependencies || {};
    packageJson.peerDependencies = packageJson.peerDependencies || {};
    let updatePackageJson = false;
    dependencies.forEach((entry) => {
        const packageName = (0, operators_1.isNpmProject)(entry.node)
            ? entry.node.data.packageName
            : entry.name;
        if (!hasDependency(packageJson, 'dependencies', packageName) &&
            !hasDependency(packageJson, 'devDependencies', packageName) &&
            !hasDependency(packageJson, 'peerDependencies', packageName)) {
            try {
                let depVersion;
                if ((0, project_graph_1.isProjectGraphProjectNode)(entry.node) &&
                    entry.node.type === 'lib') {
                    const outputs = (0, devkit_1.getOutputsForTargetAndConfiguration)({
                        project: projectName,
                        target: targetName,
                        configuration: configurationName,
                    }, {}, entry.node);
                    const depPackageJsonPath = (0, path_1.join)(root, outputs[0], 'package.json');
                    depVersion = (0, devkit_1.readJsonFile)(depPackageJsonPath).version;
                    packageJson[typeOfDependency][packageName] = depVersion;
                }
                else if ((0, operators_1.isNpmProject)(entry.node)) {
                    // If an npm dep is part of the workspace devDependencies, do not include it the library
                    if (!!workspacePackageJson.devDependencies?.[entry.node.data.packageName]) {
                        return;
                    }
                    depVersion = entry.node.data.version;
                    packageJson[typeOfDependency][entry.node.data.packageName] =
                        depVersion;
                }
                updatePackageJson = true;
            }
            catch (e) {
                // skip if cannot find package.json
            }
        }
    });
    if (updatePackageJson) {
        (0, devkit_1.writeJsonFile)(packageJsonPath, packageJson);
    }
}
// verify whether the package.json already specifies the dep
function hasDependency(outputJson, depConfigName, packageName) {
    if (outputJson[depConfigName]) {
        return outputJson[depConfigName][packageName];
    }
    else {
        return false;
    }
}

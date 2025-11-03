"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isUsingTypeScriptPlugin = isUsingTypeScriptPlugin;
exports.shouldConfigureTsSolutionSetup = shouldConfigureTsSolutionSetup;
exports.isUsingTsSolutionSetup = isUsingTsSolutionSetup;
exports.assertNotUsingTsSolutionSetup = assertNotUsingTsSolutionSetup;
exports.findRuntimeTsConfigName = findRuntimeTsConfigName;
exports.updateTsconfigFiles = updateTsconfigFiles;
exports.addProjectToTsSolutionWorkspace = addProjectToTsSolutionWorkspace;
exports.getProjectType = getProjectType;
exports.getProjectSourceRoot = getProjectSourceRoot;
exports.getCustomConditionName = getCustomConditionName;
exports.getDefinedCustomConditionName = getDefinedCustomConditionName;
const devkit_1 = require("@nx/devkit");
const node_fs_1 = require("node:fs");
const posix_1 = require("node:path/posix");
const tree_1 = require("nx/src/generators/tree");
const package_manager_workspaces_1 = require("../package-manager-workspaces");
const configuration_1 = require("./configuration");
function isUsingTypeScriptPlugin(tree) {
    const nxJson = (0, devkit_1.readNxJson)(tree);
    return (nxJson?.plugins?.some((p) => typeof p === 'string'
        ? p === '@nx/js/typescript'
        : p.plugin === '@nx/js/typescript') ?? false);
}
function shouldConfigureTsSolutionSetup(tree, addPlugins, addTsPlugin) {
    if (addTsPlugin !== undefined) {
        return addTsPlugin;
    }
    if (addPlugins === undefined) {
        const nxJson = (0, devkit_1.readNxJson)(tree);
        addPlugins =
            process.env.NX_ADD_PLUGINS !== 'false' &&
                nxJson.useInferencePlugins !== false;
    }
    if (!addPlugins) {
        return false;
    }
    if (!(0, package_manager_workspaces_1.isUsingPackageManagerWorkspaces)(tree)) {
        return false;
    }
    // if there are no root tsconfig files, we should configure the TS solution setup
    return !tree.exists('tsconfig.base.json') && !tree.exists('tsconfig.json');
}
function isUsingTsSolutionSetup(tree) {
    tree ??= new tree_1.FsTree(devkit_1.workspaceRoot, false);
    return ((0, package_manager_workspaces_1.isUsingPackageManagerWorkspaces)(tree) &&
        isWorkspaceSetupWithTsSolution(tree));
}
/**
 * The TS solution setup requires:
 * - `tsconfig.base.json`: TS config with common compiler options needed by the
 *    majority of projects in the workspace. It's meant to be extended by other
 *    tsconfig files in the workspace to reuse them.
 * - `tsconfig.json`: TS solution config file that references all other projects
 *    in the repo. It shouldn't include any file and it's not meant to be
 *    extended or define any common compiler options.
 */
function isWorkspaceSetupWithTsSolution(tree) {
    if (!tree.exists('tsconfig.base.json') || !tree.exists('tsconfig.json')) {
        return false;
    }
    const tsconfigJson = (0, devkit_1.readJson)(tree, 'tsconfig.json');
    if (tsconfigJson.extends !== './tsconfig.base.json') {
        return false;
    }
    /**
     * TS solution setup requires:
     * - One of `files` or `include` defined
     * - If set, they must be empty arrays
     *
     * Note: while the TS solution setup uses TS project references, in the initial
     * state of the workspace, where there are no projects, `references` is not
     * required to be defined.
     */
    if ((!tsconfigJson.files && !tsconfigJson.include) ||
        tsconfigJson.files?.length > 0 ||
        tsconfigJson.include?.length > 0) {
        return false;
    }
    /**
     * TS solution setup requires:
     * - `compilerOptions.composite`: true
     * - `compilerOptions.declaration`: true or not set (default to true)
     */
    const baseTsconfigJson = (0, devkit_1.readJson)(tree, 'tsconfig.base.json');
    if (!baseTsconfigJson.compilerOptions ||
        !baseTsconfigJson.compilerOptions.composite ||
        baseTsconfigJson.compilerOptions.declaration === false) {
        return false;
    }
    return true;
}
function assertNotUsingTsSolutionSetup(tree, pluginName, generatorName) {
    if (process.env.NX_IGNORE_UNSUPPORTED_TS_SETUP === 'true' ||
        !isUsingTsSolutionSetup(tree)) {
        return;
    }
    const artifactString = generatorName === 'init'
        ? `"@nx/${pluginName}" plugin`
        : `"@nx/${pluginName}:${generatorName}" generator`;
    devkit_1.output.error({
        title: `The ${artifactString} doesn't yet support the existing TypeScript setup`,
        bodyLines: [
            `We're working hard to support the existing TypeScript setup with the ${artifactString}. We'll soon release a new version of Nx with support for it.`,
        ],
    });
    throw new Error(`The ${artifactString} doesn't yet support the existing TypeScript setup. See the error above.`);
}
function findRuntimeTsConfigName(projectRoot, tree) {
    tree ??= new tree_1.FsTree(devkit_1.workspaceRoot, false);
    if (tree.exists((0, devkit_1.joinPathFragments)(projectRoot, 'tsconfig.app.json')))
        return 'tsconfig.app.json';
    if (tree.exists((0, devkit_1.joinPathFragments)(projectRoot, 'tsconfig.lib.json')))
        return 'tsconfig.lib.json';
    return null;
}
function updateTsconfigFiles(tree, projectRoot, runtimeTsconfigFileName, compilerOptions, exclude = [], rootDir = 'src') {
    if (!isUsingTsSolutionSetup(tree)) {
        return;
    }
    const offset = (0, devkit_1.offsetFromRoot)(projectRoot);
    const runtimeTsconfigPath = `${projectRoot}/${runtimeTsconfigFileName}`;
    const specTsconfigPath = `${projectRoot}/tsconfig.spec.json`;
    if (tree.exists(runtimeTsconfigPath)) {
        (0, devkit_1.updateJson)(tree, runtimeTsconfigPath, (json) => {
            json.extends = (0, devkit_1.joinPathFragments)(offset, 'tsconfig.base.json');
            json.compilerOptions = {
                ...json.compilerOptions,
                outDir: 'dist',
                rootDir,
                ...compilerOptions,
            };
            if (rootDir && rootDir !== '.') {
                // when rootDir is different from '.', the tsbuildinfo file is output
                // at `<outDir>/<relative path to config from rootDir>/`, so we need
                // to set it explicitly to ensure it's output to the outDir
                // https://www.typescriptlang.org/tsconfig/#tsBuildInfoFile
                json.compilerOptions.tsBuildInfoFile = (0, posix_1.join)(json.compilerOptions.outDir, (0, posix_1.basename)(runtimeTsconfigFileName, '.json') + '.tsbuildinfo');
            }
            else if (json.compilerOptions.tsBuildInfoFile) {
                // when rootDir is '.' or not set, it would be output to the outDir, so
                // we don't need to set it explicitly
                delete json.compilerOptions.tsBuildInfoFile;
            }
            // don't duplicate compiler options from base tsconfig
            json.compilerOptions = (0, configuration_1.getNeededCompilerOptionOverrides)(tree, json.compilerOptions, 'tsconfig.base.json');
            const excludeSet = json.exclude
                ? new Set(['out-tsc', 'dist', ...json.exclude, ...exclude])
                : new Set(exclude);
            json.exclude = Array.from(excludeSet);
            return json;
        });
    }
    if (tree.exists(specTsconfigPath)) {
        (0, devkit_1.updateJson)(tree, specTsconfigPath, (json) => {
            json.extends = (0, devkit_1.joinPathFragments)(offset, 'tsconfig.base.json');
            json.compilerOptions = {
                ...json.compilerOptions,
                ...compilerOptions,
            };
            // don't duplicate compiler options from base tsconfig
            json.compilerOptions = (0, configuration_1.getNeededCompilerOptionOverrides)(tree, json.compilerOptions, 'tsconfig.base.json');
            const runtimePath = `./${runtimeTsconfigFileName}`;
            json.references ??= [];
            if (!json.references.some((x) => x.path === runtimePath)) {
                json.references.push({ path: runtimePath });
            }
            return json;
        });
    }
    if (tree.exists('tsconfig.json')) {
        (0, devkit_1.updateJson)(tree, 'tsconfig.json', (json) => {
            const projectPath = './' + projectRoot;
            json.references ??= [];
            if (!json.references.some((x) => x.path === projectPath)) {
                json.references.push({ path: projectPath });
            }
            return json;
        });
    }
}
async function addProjectToTsSolutionWorkspace(tree, projectDir) {
    const state = (0, package_manager_workspaces_1.getProjectPackageManagerWorkspaceState)(tree, projectDir);
    if (state === 'included') {
        return;
    }
    // If dir is "libs/foo", we try to use "libs/*" but we only do it if it's
    // safe to do so. So, we first check if adding that pattern doesn't result
    // in extra projects being matched. If extra projects are matched, or the
    // dir is just "foo" then we add it as is.
    const baseDir = (0, posix_1.dirname)(projectDir);
    let pattern = projectDir;
    if (baseDir !== '.') {
        const patterns = (0, package_manager_workspaces_1.getPackageManagerWorkspacesPatterns)(tree);
        const projectsBefore = patterns.length > 0 ? await (0, devkit_1.globAsync)(tree, patterns) : [];
        patterns.push(`${baseDir}/*/package.json`);
        const projectsAfter = await (0, devkit_1.globAsync)(tree, patterns);
        if (projectsBefore.length + 1 === projectsAfter.length) {
            // Adding the pattern to the parent directory only results in one extra
            // project being matched, which is the project we're adding. It's safe
            // to add the pattern to the parent directory.
            pattern = `${baseDir}/*`;
        }
    }
    if (tree.exists('pnpm-workspace.yaml')) {
        const { load, dump } = require('@zkochan/js-yaml');
        const workspaceFile = tree.read('pnpm-workspace.yaml', 'utf-8');
        const yamlData = load(workspaceFile) ?? {};
        yamlData.packages ??= [];
        if (!yamlData.packages.includes(pattern)) {
            yamlData.packages.push(pattern);
            tree.write('pnpm-workspace.yaml', dump(yamlData, { indent: 2, quotingType: '"', forceQuotes: true }));
        }
    }
    else {
        // Update package.json
        const packageJson = (0, devkit_1.readJson)(tree, 'package.json');
        if (!packageJson.workspaces) {
            packageJson.workspaces = [];
        }
        if (!packageJson.workspaces.includes(pattern)) {
            packageJson.workspaces.push(pattern);
            tree.write('package.json', JSON.stringify(packageJson, null, 2));
        }
    }
}
function getProjectType(tree, projectRoot, projectType) {
    if (projectType)
        return projectType;
    if (tree.exists((0, devkit_1.joinPathFragments)(projectRoot, 'tsconfig.lib.json')))
        return 'library';
    if (tree.exists((0, devkit_1.joinPathFragments)(projectRoot, 'tsconfig.app.json')))
        return 'application';
    // If it doesn't have any common library entry points, assume it is an application
    const packageJsonPath = (0, devkit_1.joinPathFragments)(projectRoot, 'package.json');
    const packageJson = tree.exists(packageJsonPath)
        ? (0, devkit_1.readJson)(tree, (0, devkit_1.joinPathFragments)(projectRoot, 'package.json'))
        : null;
    if (!packageJson?.exports &&
        !packageJson?.main &&
        !packageJson?.module &&
        !packageJson?.bin) {
        return 'application';
    }
    return 'library';
}
function getProjectSourceRoot(project, tree) {
    if (tree) {
        return (project.sourceRoot ??
            (tree.exists((0, devkit_1.joinPathFragments)(project.root, 'src'))
                ? (0, devkit_1.joinPathFragments)(project.root, 'src')
                : project.root));
    }
    return (project.sourceRoot ??
        ((0, node_fs_1.existsSync)((0, posix_1.join)(devkit_1.workspaceRoot, project.root, 'src'))
            ? (0, devkit_1.joinPathFragments)(project.root, 'src')
            : project.root));
}
const defaultCustomConditionName = '@nx/source';
const backwardCompatibilityCustomConditionName = 'development';
const customConditionNamePrefix = '@nx-source/';
/**
 * Get the already defined or expected custom condition name. In case it's not
 * yet defined, it returns the workspace package name or '@nx/source' in case
 * it's not defined.
 */
function getCustomConditionName(tree, options = {}) {
    let name;
    try {
        ({ name } = (0, devkit_1.readJson)(tree, 'package.json'));
    }
    catch { }
    if (!name) {
        // Most workspaces should have a name, but let's default to something if not.
        name = defaultCustomConditionName;
    }
    let definedCustomConditions = [];
    if (tree.exists('tsconfig.base.json')) {
        const tsconfigJson = (0, devkit_1.readJson)(tree, 'tsconfig.base.json');
        definedCustomConditions =
            tsconfigJson.compilerOptions?.customConditions ?? [];
    }
    if (!definedCustomConditions.length) {
        return name;
    }
    // Try to find a condition that matches the following (in order):
    // - a custom condition that starts with '@nx-source/'
    // - the 'development' backward compatibility name (if not skipped)
    const customCondition = definedCustomConditions.find((condition) => condition.startsWith(customConditionNamePrefix)) ??
        (!options.skipDevelopmentFallback
            ? definedCustomConditions.find((condition) => condition === backwardCompatibilityCustomConditionName)
            : undefined);
    // If a custom condition matches, use it, otherwise use the name.
    return customCondition ?? name;
}
/**
 * Get the already defined custom condition name or null if none is defined.
 */
function getDefinedCustomConditionName(tree) {
    if (!tree.exists('tsconfig.base.json')) {
        return null;
    }
    const tsconfigJson = (0, devkit_1.readJson)(tree, 'tsconfig.base.json');
    const definedCustomConditions = tsconfigJson.compilerOptions?.customConditions;
    if (!definedCustomConditions?.length) {
        return null;
    }
    let name;
    try {
        ({ name } = (0, devkit_1.readJson)(tree, 'package.json'));
    }
    catch { }
    if (!name) {
        // Most workspaces should have a name, but let's default to something if not.
        name = defaultCustomConditionName;
    }
    // Try to find a condition that matches the following (in order):
    // - the workspace package name or '@nx/source'
    // - a custom condition that starts with '@nx-source/'
    // - the 'development' backward compatibility name
    const conditionName = definedCustomConditions.find((condition) => condition === name) ??
        definedCustomConditions.find((condition) => condition.startsWith(customConditionNamePrefix)) ??
        definedCustomConditions.find((condition) => condition === backwardCompatibilityCustomConditionName);
    return conditionName ?? null;
}

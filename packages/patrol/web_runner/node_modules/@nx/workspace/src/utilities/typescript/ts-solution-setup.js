"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isUsingTsSolutionSetup = isUsingTsSolutionSetup;
exports.addProjectToTsSolutionWorkspace = addProjectToTsSolutionWorkspace;
const devkit_1 = require("@nx/devkit");
const posix_1 = require("node:path/posix");
const tree_1 = require("nx/src/generators/tree");
const package_manager_workspaces_1 = require("../package-manager-workspaces");
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
function isUsingTsSolutionSetup(tree) {
    tree ??= new tree_1.FsTree(devkit_1.workspaceRoot, false);
    return ((0, package_manager_workspaces_1.isUsingPackageManagerWorkspaces)(tree) &&
        isWorkspaceSetupWithTsSolution(tree));
}
async function addProjectToTsSolutionWorkspace(tree, projectDir) {
    const isIncluded = (0, package_manager_workspaces_1.isProjectIncludedInPackageManagerWorkspaces)(tree, projectDir);
    if (isIncluded) {
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
        const projectsBefore = await (0, devkit_1.globAsync)(tree, patterns);
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

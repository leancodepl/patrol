"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getProjectPackageManagerWorkspaceState = getProjectPackageManagerWorkspaceState;
exports.getPackageManagerWorkspacesPatterns = getPackageManagerWorkspacesPatterns;
exports.isUsingPackageManagerWorkspaces = isUsingPackageManagerWorkspaces;
exports.isWorkspacesEnabled = isWorkspacesEnabled;
exports.getProjectPackageManagerWorkspaceStateWarningTask = getProjectPackageManagerWorkspaceStateWarningTask;
const devkit_1 = require("@nx/devkit");
const picomatch = require("picomatch");
const posix_1 = require("node:path/posix");
const package_json_1 = require("nx/src/plugins/package-json");
const semver_1 = require("semver");
function getProjectPackageManagerWorkspaceState(tree, projectRoot) {
    if (!isUsingPackageManagerWorkspaces(tree)) {
        return 'no-workspaces';
    }
    const patterns = getPackageManagerWorkspacesPatterns(tree);
    const isIncluded = patterns.some((p) => picomatch(p)((0, posix_1.join)(projectRoot, 'package.json')));
    return isIncluded ? 'included' : 'excluded';
}
function getPackageManagerWorkspacesPatterns(tree) {
    return (0, package_json_1.getGlobPatternsFromPackageManagerWorkspaces)(tree.root, (path) => (0, devkit_1.readJson)(tree, path, { expectComments: true }), (path) => {
        const content = tree.read(path, 'utf-8');
        const { load } = require('@zkochan/js-yaml');
        return load(content, { filename: path });
    }, (path) => tree.exists(path));
}
function isUsingPackageManagerWorkspaces(tree) {
    return isWorkspacesEnabled(tree);
}
function isWorkspacesEnabled(tree) {
    const packageManager = (0, devkit_1.detectPackageManager)(tree.root);
    if (packageManager === 'pnpm') {
        if (!tree.exists('pnpm-workspace.yaml')) {
            return false;
        }
        try {
            const content = tree.read('pnpm-workspace.yaml', 'utf-8');
            const { load } = require('@zkochan/js-yaml');
            const { packages } = load(content) ?? {};
            return packages !== undefined;
        }
        catch {
            return false;
        }
    }
    // yarn and npm both use the same 'workspaces' property in package.json
    if (tree.exists('package.json')) {
        const packageJson = (0, devkit_1.readJson)(tree, 'package.json');
        return !!packageJson?.workspaces;
    }
    return false;
}
function getProjectPackageManagerWorkspaceStateWarningTask(projectPackageManagerWorkspaceState, workspaceRoot) {
    return () => {
        if (projectPackageManagerWorkspaceState !== 'excluded') {
            return;
        }
        const packageManager = (0, devkit_1.detectPackageManager)(workspaceRoot);
        let adviseMessage = 'updating the "workspaces" option in the workspace root "package.json" file with the project root or pattern that includes it';
        let packageManagerWorkspaceSetupDocs;
        if (packageManager === 'pnpm') {
            adviseMessage =
                'updating the "pnpm-workspace.yaml" file with the project root or pattern that includes it';
            packageManagerWorkspaceSetupDocs =
                'https://pnpm.io/workspaces and https://pnpm.io/pnpm-workspace_yaml';
        }
        else if (packageManager === 'yarn') {
            const yarnVersion = (0, devkit_1.getPackageManagerVersion)(packageManager, workspaceRoot);
            if ((0, semver_1.lt)(yarnVersion, '2.0.0')) {
                packageManagerWorkspaceSetupDocs =
                    'https://classic.yarnpkg.com/lang/en/docs/workspaces/';
            }
            else {
                packageManagerWorkspaceSetupDocs =
                    'https://yarnpkg.com/features/workspaces';
            }
        }
        else if (packageManager === 'npm') {
            packageManagerWorkspaceSetupDocs =
                'https://docs.npmjs.com/cli/v10/using-npm/workspaces';
        }
        else if (packageManager === 'bun') {
            packageManagerWorkspaceSetupDocs =
                'https://bun.sh/docs/install/workspaces';
        }
        devkit_1.output.warn({
            title: `The project is not included in the package manager workspaces configuration`,
            bodyLines: [
                `Please add the project to the package manager workspaces configuration by ${adviseMessage}.`,
                `Read more about the ${packageManager} workspaces feature and how to set it up at ${packageManagerWorkspaceSetupDocs}.`,
            ],
        });
    };
}

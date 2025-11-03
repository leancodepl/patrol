"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ciWorkflowGenerator = ciWorkflowGenerator;
const devkit_1 = require("@nx/devkit");
const default_base_1 = require("../../utilities/default-base");
const path_1 = require("path");
const nx_cloud_utils_1 = require("nx/src/utils/nx-cloud-utils");
const ts_solution_setup_1 = require("../../utilities/typescript/ts-solution-setup");
function getNxCloudRecordCommand(ci, packageManagerPrefix) {
    const baseCommand = `${packageManagerPrefix} nx-cloud record -- echo Hello World`;
    const prefix = getCiPrefix(ci);
    const exampleComment = `${prefix}${baseCommand}`;
    return {
        comments: [
            `Prepend any command with "nx-cloud record --" to record its logs to Nx Cloud`,
            exampleComment,
        ],
    };
}
function getNxTasksCommand(ci, packageManagerPrefix, mainBranch, hasTypecheck, hasE2E, useRunMany = false) {
    const tasks = `lint test build${hasTypecheck ? ' typecheck' : ''}${hasE2E ? ' e2e' : ''}`;
    const commandType = useRunMany ? 'run-many' : 'affected';
    const nxCommandComments = hasE2E
        ? [`When you enable task distribution, run the e2e-ci task instead of e2e`]
        : [];
    const args = getCiArgs(ci, mainBranch, useRunMany);
    const nxCommand = `${packageManagerPrefix} nx ${commandType} ${args}-t ${tasks}`;
    return {
        comments: nxCommandComments,
        command: nxCommand,
    };
}
function getNxCloudFixCiCommand(packageManagerPrefix) {
    return {
        comments: [
            `Nx Cloud recommends fixes for failures to help you get CI green faster. Learn more: https://nx.dev/ci/features/self-healing-ci`,
        ],
        command: `${packageManagerPrefix} nx fix-ci`,
        alwaysRun: true,
    };
}
function getCiCommands(ci, packageManagerPrefix, mainBranch, hasTypecheck, hasE2E, useRunMany = false) {
    return [
        getNxCloudRecordCommand(ci, packageManagerPrefix),
        getNxTasksCommand(ci, packageManagerPrefix, mainBranch, hasTypecheck, hasE2E, useRunMany),
        getNxCloudFixCiCommand(packageManagerPrefix),
    ];
}
function getCiPrefix(ci) {
    if (ci === 'github' || ci === 'circleci') {
        return '- run: ';
    }
    else if (ci === 'azure') {
        return '- script: ';
    }
    else if (ci === 'gitlab') {
        return '- ';
    }
    // Bitbucket expects just the command without prefix for pull requests
    return '';
}
function getCiArgs(ci, mainBranch, useRunMany = false) {
    // When using run-many, we don't need base/head SHA args
    if (useRunMany) {
        return '';
    }
    if (ci === 'azure') {
        return '--base=$(BASE_SHA) --head=$(HEAD_SHA) ';
    }
    else if (ci === 'bitbucket-pipelines') {
        return `--base=origin/${mainBranch} `;
    }
    return '';
}
function getBitbucketBranchCommands(packageManagerPrefix, hasTypecheck, hasE2E, useRunMany = false) {
    const tasks = `lint test build${hasTypecheck ? ' typecheck' : ''}${hasE2E ? ' e2e-ci' : ''}`;
    const nxCloudComments = [
        `Prepend any command with "nx-cloud record --" to record its logs to Nx Cloud`,
        `- ${packageManagerPrefix} nx-cloud record -- echo Hello World`,
    ];
    // Build nx command comments and command
    const commandType = useRunMany ? 'run-many' : 'affected';
    // Build command with conditional base arg
    const baseArg = useRunMany ? '' : ' --base=HEAD~1';
    const command = `${packageManagerPrefix} nx ${commandType} -t ${tasks}${baseArg}`;
    return [
        {
            comments: nxCloudComments,
        },
        {
            command,
        },
    ];
}
async function ciWorkflowGenerator(tree, schema) {
    const ci = schema.ci;
    const options = normalizeOptions(schema, tree);
    const nxJson = (0, devkit_1.readJson)(tree, 'nx.json');
    if (ci === 'bitbucket-pipelines' && defaultBranchNeedsOriginPrefix(nxJson)) {
        appendOriginPrefix(nxJson);
    }
    (0, devkit_1.generateFiles)(tree, (0, path_1.join)(__dirname, 'files', ci), '', options);
    addWorkflowFileToSharedGlobals(nxJson, schema.ci, options.workflowFileName);
    (0, devkit_1.writeJson)(tree, 'nx.json', nxJson);
    await (0, devkit_1.formatFiles)(tree);
}
function normalizeOptions(options, tree) {
    const { name: workflowName, fileName: workflowFileName } = (0, devkit_1.names)(options.name);
    const packageManager = (0, devkit_1.detectPackageManager)();
    const { exec: packageManagerPrefix, ciInstall: packageManagerInstall, dlx: packageManagerPreInstallPrefix, } = (0, devkit_1.getPackageManagerCommand)(packageManager);
    let nxCloudHost = 'nx.app';
    try {
        const nxCloudUrl = (0, nx_cloud_utils_1.getNxCloudUrl)((0, devkit_1.readJson)(tree, 'nx.json'));
        nxCloudHost = new URL(nxCloudUrl).host;
    }
    catch { }
    const packageJson = (0, devkit_1.readJson)(tree, 'package.json');
    const allDependencies = {
        ...packageJson.dependencies,
        ...packageJson.devDependencies,
    };
    const hasCypress = allDependencies['@nx/cypress'];
    const hasPlaywright = allDependencies['@nx/playwright'];
    const hasE2E = hasCypress || hasPlaywright;
    const hasTypecheck = (0, ts_solution_setup_1.isUsingTsSolutionSetup)(tree);
    const connectedToCloud = (0, nx_cloud_utils_1.isNxCloudUsed)((0, devkit_1.readJson)(tree, 'nx.json'));
    const mainBranch = (0, default_base_1.deduceDefaultBase)();
    const commands = getCiCommands(options.ci, packageManagerPrefix, mainBranch, hasTypecheck, hasE2E, options.useRunMany ?? false);
    const branchCommands = options.ci === 'bitbucket-pipelines'
        ? getBitbucketBranchCommands(packageManagerPrefix, hasTypecheck, hasE2E, options.useRunMany ?? false)
        : undefined;
    return {
        workflowName,
        workflowFileName,
        packageManager,
        packageManagerInstall,
        packageManagerPrefix,
        packageManagerPreInstallPrefix,
        mainBranch,
        packageManagerVersion: packageJson?.packageManager?.split('@')[1],
        hasCypress,
        hasE2E,
        hasPlaywright,
        hasTypecheck,
        nxCloudHost,
        tmpl: '',
        connectedToCloud,
        useRunMany: options.useRunMany ?? false,
        commands,
        branchCommands,
    };
}
function defaultBranchNeedsOriginPrefix(nxJson) {
    const base = nxJson.defaultBase ?? nxJson.affected?.defaultBase;
    return !base?.startsWith('origin/');
}
function appendOriginPrefix(nxJson) {
    if (nxJson?.affected?.defaultBase) {
        nxJson.affected.defaultBase = `origin/${nxJson.affected.defaultBase}`;
    }
    if (nxJson.defaultBase || !nxJson.affected) {
        nxJson.defaultBase = `origin/${nxJson.defaultBase ?? (0, default_base_1.deduceDefaultBase)()}`;
    }
}
const ciWorkflowInputs = {
    azure: 'azure-pipelines.yml',
    'bitbucket-pipelines': 'bitbucket-pipelines.yml',
    circleci: '.circleci/config.yml',
    github: '.github/workflows/',
    gitlab: '.gitlab-ci.yml',
};
function addWorkflowFileToSharedGlobals(nxJson, ci, workflowFileName) {
    let input = `{workspaceRoot}/${ciWorkflowInputs[ci]}`;
    if (ci === 'github')
        input += `${workflowFileName}.yml`;
    nxJson.namedInputs ??= {};
    nxJson.namedInputs.sharedGlobals ??= [];
    nxJson.namedInputs.sharedGlobals.push(input);
    // Ensure 'default' named input exists and includes 'sharedGlobals'
    if (!nxJson.namedInputs.default) {
        nxJson.namedInputs.default = ['sharedGlobals'];
    }
    else if (Array.isArray(nxJson.namedInputs.default) &&
        !nxJson.namedInputs.default.includes('sharedGlobals')) {
        nxJson.namedInputs.default.push('sharedGlobals');
    }
}

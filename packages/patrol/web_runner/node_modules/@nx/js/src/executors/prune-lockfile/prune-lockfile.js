"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = pruneLockfileExecutor;
const devkit_1 = require("@nx/devkit");
const fs_1 = require("fs");
const path_1 = require("path");
const utils_1 = require("nx/src/tasks-runner/utils");
// eslint-disable-next-line @typescript-eslint/no-restricted-imports
const lock_file_1 = require("nx/src/plugins/js/lock-file/lock-file");
async function pruneLockfileExecutor(schema, context) {
    devkit_1.logger.log('Pruning lockfile...');
    const outputDirectory = getOutputDir(schema, context);
    const packageJson = getPackageJson(schema, context);
    const packageManager = (0, devkit_1.detectPackageManager)(devkit_1.workspaceRoot);
    if (packageManager === 'bun') {
        devkit_1.logger.warn('Bun lockfile generation is not supported. Only package.json will be generated. Run "bun install" in the output directory if needed.');
        (0, fs_1.writeFileSync)((0, path_1.join)(outputDirectory, 'package.json'), JSON.stringify(packageJson, null, 2));
    }
    else {
        const { lockfileName, lockFile } = createPrunedLockfile(packageJson, context.projectGraph);
        const lockfileOutputPath = (0, path_1.join)(outputDirectory, lockfileName);
        (0, fs_1.writeFileSync)(lockfileOutputPath, lockFile);
        (0, fs_1.writeFileSync)((0, path_1.join)(outputDirectory, 'package.json'), JSON.stringify(packageJson, null, 2));
        devkit_1.logger.log(`Lockfile pruned: ${lockfileOutputPath}`);
    }
    return {
        success: true,
    };
}
function createPrunedLockfile(packageJson, graph) {
    const packageManager = (0, devkit_1.detectPackageManager)(devkit_1.workspaceRoot);
    const lockfileName = (0, lock_file_1.getLockFileName)(packageManager);
    const lockFile = (0, lock_file_1.createLockFile)(packageJson, graph, packageManager);
    for (const [pkgName, pkgVersion] of Object.entries(packageJson.dependencies ?? {})) {
        if (pkgVersion.startsWith('workspace:') ||
            pkgVersion.startsWith('file:') ||
            pkgVersion.startsWith('link:')) {
            packageJson.dependencies[pkgName] = `file:./workspace_modules/${pkgName}`;
        }
    }
    return {
        lockfileName,
        lockFile,
    };
}
function getPackageJson(schema, context) {
    const target = (0, devkit_1.parseTargetString)(schema.buildTarget, context);
    const project = context.projectGraph.nodes[target.project].data;
    const packageJsonPath = (0, path_1.join)(devkit_1.workspaceRoot, project.root, 'package.json');
    if (!(0, fs_1.existsSync)(packageJsonPath)) {
        throw new Error(`${packageJsonPath} does not exist.`);
    }
    const packageJson = (0, devkit_1.readJsonFile)(packageJsonPath);
    return packageJson;
}
function getOutputDir(schema, context) {
    let outputDir = schema.outputPath;
    if (outputDir) {
        outputDir = normalizeOutputPath(outputDir);
        if ((0, fs_1.existsSync)(outputDir)) {
            return outputDir;
        }
    }
    const target = (0, devkit_1.parseTargetString)(schema.buildTarget, context);
    const project = context.projectGraph.nodes[target.project].data;
    const buildTarget = project.targets[target.target];
    let maybeOutputPath = buildTarget.outputs?.[0] ??
        buildTarget.options.outputPath ??
        buildTarget.options.outputDir;
    if (!maybeOutputPath) {
        throw new Error(`Could not infer an output directory from the '${schema.buildTarget}' target. Please provide 'outputPath'.`);
    }
    maybeOutputPath = (0, utils_1.interpolate)(maybeOutputPath, {
        workspaceRoot: devkit_1.workspaceRoot,
        projectRoot: project.root,
        projectName: project.name,
        options: {
            ...(buildTarget.options ?? {}),
        },
    });
    outputDir = normalizeOutputPath(maybeOutputPath);
    if (!(0, fs_1.existsSync)(outputDir)) {
        throw new Error(`The output directory '${outputDir}' inferred from the '${schema.buildTarget}' target does not exist.\nPlease ensure a build has run first, and that the path is correct. Otherwise, please provide 'outputPath'.`);
    }
    return outputDir;
}
function normalizeOutputPath(outputPath) {
    if (!outputPath.startsWith(devkit_1.workspaceRoot)) {
        outputPath = (0, path_1.join)(devkit_1.workspaceRoot, outputPath);
    }
    if (!(0, fs_1.lstatSync)(outputPath).isDirectory()) {
        outputPath = (0, path_1.dirname)(outputPath);
    }
    return outputPath;
}

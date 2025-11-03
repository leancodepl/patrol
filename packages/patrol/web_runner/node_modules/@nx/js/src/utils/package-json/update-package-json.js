"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updatePackageJson = updatePackageJson;
exports.getExports = getExports;
exports.getUpdatedPackageJsonContent = getUpdatedPackageJsonContent;
exports.getOutputDir = getOutputDir;
// eslint-disable-next-line @typescript-eslint/no-restricted-imports
const lock_file_1 = require("nx/src/plugins/js/lock-file/lock-file");
// eslint-disable-next-line @typescript-eslint/no-restricted-imports
const create_package_json_1 = require("nx/src/plugins/js/package-json/create-package-json");
const devkit_1 = require("@nx/devkit");
const node_fs_1 = require("node:fs");
const path_1 = require("path");
const fileutils_1 = require("nx/src/utils/fileutils");
const nx_deps_cache_1 = require("nx/src/project-graph/nx-deps-cache");
const get_main_file_dir_1 = require("../get-main-file-dir");
function updatePackageJson(options, context, target, dependencies, fileMap = null) {
    let packageJson;
    if (fileMap == null) {
        fileMap = (0, nx_deps_cache_1.readFileMapCache)()?.fileMap?.projectFileMap || {};
    }
    if (options.updateBuildableProjectDepsInPackageJson) {
        packageJson = (0, create_package_json_1.createPackageJson)(context.projectName, context.projectGraph, {
            target: context.targetName,
            root: context.root,
            // By default we remove devDependencies since this is a production build.
            isProduction: true,
        }, fileMap);
        if (options.excludeLibsInPackageJson) {
            dependencies = dependencies.filter((dep) => dep.node.type !== 'lib');
        }
        addMissingDependencies(packageJson, context, dependencies, options.buildableProjectDepsInPackageJsonType);
    }
    else {
        const pathToPackageJson = (0, path_1.join)(context.root, options.projectRoot, 'package.json');
        packageJson = (0, fileutils_1.fileExists)(pathToPackageJson)
            ? (0, devkit_1.readJsonFile)(pathToPackageJson)
            : { name: context.projectName, version: '0.0.1' };
    }
    if (packageJson.type === 'module') {
        if (options.format?.includes('cjs')) {
            devkit_1.logger.warn(`Package type is set to "module" but "cjs" format is included. Going to use "esm" format instead. You can change the package type to "commonjs" or remove type in the package.json file.`);
        }
        options.format = ['esm'];
    }
    else if (packageJson.type === 'commonjs') {
        if (options.format?.includes('esm')) {
            devkit_1.logger.warn(`Package type is set to "commonjs" but "esm" format is included. Going to use "cjs" format instead. You can change the package type to "module" or remove type in the package.json file.`);
        }
        options.format = ['cjs'];
    }
    // update package specific settings
    packageJson = getUpdatedPackageJsonContent(packageJson, options);
    // save files
    (0, devkit_1.writeJsonFile)(`${options.outputPath}/package.json`, packageJson);
    if (options.generateLockfile) {
        const packageManager = (0, devkit_1.detectPackageManager)(context.root);
        if (packageManager === 'bun') {
            devkit_1.logger.warn(`Bun lockfile generation is unsupported. Remove "generateLockfile" option or set it to false.`);
        }
        else {
            const lockFile = (0, lock_file_1.createLockFile)(packageJson, context.projectGraph, packageManager);
            (0, node_fs_1.writeFileSync)(`${options.outputPath}/${(0, lock_file_1.getLockFileName)(packageManager)}`, lockFile, {
                encoding: 'utf-8',
            });
        }
    }
}
function isNpmNode(node, graph) {
    return !!(graph.externalNodes[node.name]?.type === 'npm');
}
function isWorkspaceProject(node, graph) {
    return !!graph.nodes[node.name];
}
function addMissingDependencies(packageJson, { projectName, targetName, configurationName, root, projectGraph, }, dependencies, propType = 'dependencies') {
    const workspacePackageJson = (0, devkit_1.readJsonFile)((0, devkit_1.joinPathFragments)(devkit_1.workspaceRoot, 'package.json'));
    dependencies.forEach((entry) => {
        if (isNpmNode(entry.node, projectGraph)) {
            const { packageName, version } = entry.node.data;
            if (packageJson.dependencies?.[packageName] ||
                packageJson.devDependencies?.[packageName] ||
                packageJson.peerDependencies?.[packageName]) {
                return;
            }
            if (workspacePackageJson.devDependencies?.[packageName]) {
                return;
            }
            packageJson[propType] ??= {};
            packageJson[propType][packageName] = version;
        }
        else if (isWorkspaceProject(entry.node, projectGraph)) {
            const packageName = entry.name;
            if (!!workspacePackageJson.devDependencies?.[packageName]) {
                return;
            }
            if (!packageJson.dependencies?.[packageName] &&
                !packageJson.devDependencies?.[packageName] &&
                !packageJson.peerDependencies?.[packageName]) {
                const outputs = (0, devkit_1.getOutputsForTargetAndConfiguration)({
                    project: projectName,
                    target: targetName,
                    configuration: configurationName,
                }, {}, entry.node);
                const depPackageJsonPath = (0, path_1.join)(root, outputs[0], 'package.json');
                if ((0, node_fs_1.existsSync)(depPackageJsonPath)) {
                    const version = (0, devkit_1.readJsonFile)(depPackageJsonPath).version;
                    packageJson[propType] ??= {};
                    packageJson[propType][packageName] = version;
                }
            }
        }
    });
}
function getExports(options) {
    const outputDir = getOutputDir(options);
    const mainFile = options.outputFileName
        ? (0, path_1.basename)(options.outputFileName).replace(/\.[tj]s$/, '')
        : (0, path_1.basename)(options.main).replace(/\.[tj]s$/, '');
    const exports = {
        '.': outputDir + mainFile + options.fileExt,
    };
    if (options.additionalEntryPoints) {
        const jsRegex = /\.[jt]sx?$/;
        for (const file of options.additionalEntryPoints) {
            const { ext: fileExt, name: fileName } = (0, path_1.parse)(file);
            const relativeDir = (0, get_main_file_dir_1.getRelativeDirectoryToProjectRoot)(file, options.projectRoot);
            const sourceFilePath = relativeDir + fileName;
            const entryRelativeDir = relativeDir.replace(/^\.\/src\//, './');
            const entryFilepath = entryRelativeDir + fileName;
            const isJsFile = jsRegex.test(fileExt);
            if (isJsFile && fileName === 'index') {
                const barrelEntry = entryRelativeDir.replace(/\/$/, '');
                exports[barrelEntry] = sourceFilePath + options.fileExt;
            }
            exports[isJsFile ? entryFilepath : entryFilepath + fileExt] =
                sourceFilePath + (isJsFile ? options.fileExt : fileExt);
        }
    }
    return exports;
}
function getUpdatedPackageJsonContent(packageJson, options) {
    // Default is CJS unless esm is explicitly passed.
    const hasCjsFormat = !options.format || options.format?.includes('cjs');
    const hasEsmFormat = options.format?.includes('esm');
    if (options.generateExportsField) {
        packageJson.exports ??=
            typeof packageJson.exports === 'string' ? {} : { ...packageJson.exports };
        packageJson.exports['./package.json'] ??= './package.json';
        if (options.developmentConditionName && (hasCjsFormat || hasEsmFormat)) {
            packageJson.exports['.'] ??= {};
            const developmentExports = getDevelopmentExports(options);
            for (const [exportEntry, filePath] of Object.entries(developmentExports)) {
                if (!packageJson.exports[exportEntry]) {
                    packageJson.exports[exportEntry] ??= {};
                    packageJson.exports[exportEntry][options.developmentConditionName] ??=
                        filePath;
                }
                else if (typeof packageJson.exports[exportEntry] === 'object') {
                    packageJson.exports[exportEntry][options.developmentConditionName] ??=
                        filePath;
                }
            }
        }
    }
    if (!options.skipTypings) {
        const mainFile = (0, path_1.basename)(options.main).replace(/\.[tj]s$/, '');
        const outputDir = getOutputDir(options);
        const typingsFile = `${outputDir}${mainFile}.d.ts`;
        packageJson.types ??= typingsFile;
        if (options.generateExportsField) {
            if (!packageJson.exports['.']) {
                packageJson.exports['.'] = { types: typingsFile };
            }
            else if (typeof packageJson.exports['.'] === 'object' &&
                !packageJson.exports['.'].types) {
                packageJson.exports['.'].types = typingsFile;
            }
        }
    }
    if (hasEsmFormat) {
        const esmExports = getExports({
            ...options,
            fileExt: options.outputFileExtensionForEsm ?? '.js',
        });
        packageJson.module ??= esmExports['.'];
        if (!hasCjsFormat) {
            packageJson.type ??= 'module';
            packageJson.main ??= esmExports['.'];
        }
        if (options.generateExportsField) {
            for (const [exportEntry, filePath] of Object.entries(esmExports)) {
                if (!packageJson.exports[exportEntry]) {
                    packageJson.exports[exportEntry] ??= hasCjsFormat
                        ? { import: filePath }
                        : filePath;
                }
                else if (typeof packageJson.exports[exportEntry] === 'object') {
                    packageJson.exports[exportEntry].import ??= filePath;
                    if (!hasCjsFormat) {
                        packageJson.exports[exportEntry].default ??= filePath;
                    }
                }
            }
        }
    }
    // CJS output may have .cjs or .js file extensions.
    // Bundlers like rollup and esbuild supports .cjs for CJS and .js for ESM.
    // Bundlers/Compilers like webpack, tsc, swc do not have different file extensions (unless you use .mts or .cts in source).
    if (hasCjsFormat) {
        const cjsExports = getExports({
            ...options,
            fileExt: options.outputFileExtensionForCjs ?? '.js',
        });
        packageJson.main ??= cjsExports['.'];
        if (!hasEsmFormat) {
            packageJson.type ??= 'commonjs';
        }
        if (options.generateExportsField) {
            for (const [exportEntry, filePath] of Object.entries(cjsExports)) {
                if (!packageJson.exports[exportEntry]) {
                    packageJson.exports[exportEntry] ??= hasEsmFormat
                        ? { default: filePath }
                        : filePath;
                }
                else if (typeof packageJson.exports[exportEntry] === 'object') {
                    packageJson.exports[exportEntry].default ??= filePath;
                }
            }
        }
    }
    return packageJson;
}
function getDevelopmentExports(options) {
    const mainRelativeDir = (0, get_main_file_dir_1.getRelativeDirectoryToProjectRoot)(options.main, options.projectRoot);
    const exports = {
        '.': mainRelativeDir + (0, path_1.basename)(options.main),
    };
    if (options.additionalEntryPoints?.length) {
        const jsRegex = /\.[jt]sx?$/;
        for (const file of options.additionalEntryPoints) {
            const { ext: fileExt, name: fileName, base: baseName } = (0, path_1.parse)(file);
            if (!jsRegex.test(fileExt)) {
                continue;
            }
            const relativeDir = (0, get_main_file_dir_1.getRelativeDirectoryToProjectRoot)(file, options.projectRoot);
            const sourceFilePath = relativeDir + baseName;
            const entryRelativeDir = relativeDir.replace(/^\.\/src\//, './');
            const entryFilePath = entryRelativeDir + fileName;
            if (fileName === 'index') {
                const barrelEntry = entryRelativeDir.replace(/\/$/, '');
                exports[barrelEntry] = sourceFilePath;
            }
            exports[entryFilePath] = sourceFilePath;
        }
    }
    return exports;
}
function getOutputDir(options) {
    const packageJsonDir = options.packageJsonPath
        ? (0, path_1.dirname)(options.packageJsonPath)
        : options.outputPath;
    const relativeOutputPath = (0, path_1.relative)(packageJsonDir, options.outputPath);
    const relativeMainDir = options.outputFileName
        ? (0, path_1.dirname)(options.outputFileName)
        : (0, path_1.relative)(options.rootDir ?? options.projectRoot, (0, path_1.dirname)(options.main));
    const outputDir = (0, devkit_1.joinPathFragments)(relativeOutputPath, relativeMainDir);
    return outputDir === '.' ? `./` : `./${outputDir}/`;
}

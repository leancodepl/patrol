"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.initGenerator = initGenerator;
exports.initGeneratorInternal = initGeneratorInternal;
const devkit_1 = require("@nx/devkit");
const add_plugin_1 = require("@nx/devkit/src/utils/add-plugin");
const semver_1 = require("@nx/devkit/src/utils/semver");
const package_json_1 = require("nx/src/utils/package-json");
const path_1 = require("path");
const semver_2 = require("semver");
const plugin_1 = require("../../plugins/typescript/plugin");
const prettier_1 = require("../../utils/prettier");
const ts_config_1 = require("../../utils/typescript/ts-config");
const ts_solution_setup_1 = require("../../utils/typescript/ts-solution-setup");
const versions_1 = require("../../utils/versions");
async function getInstalledTypescriptVersion(tree) {
    const tsVersionInRootPackageJson = (0, devkit_1.getDependencyVersionFromPackageJson)(tree, 'typescript');
    if (!tsVersionInRootPackageJson) {
        return null;
    }
    if ((0, semver_2.valid)(tsVersionInRootPackageJson)) {
        // it's a pinned version, return it
        return tsVersionInRootPackageJson;
    }
    // it's a version range, check whether the installed version matches it
    try {
        const tsPackageJson = (0, package_json_1.readModulePackageJson)('typescript').packageJson;
        const installedTsVersion = tsPackageJson.devDependencies?.['typescript'] ??
            tsPackageJson.dependencies?.['typescript'];
        // the installed version matches the package.json version range
        if (installedTsVersion &&
            (0, semver_2.satisfies)(installedTsVersion, tsVersionInRootPackageJson)) {
            return installedTsVersion;
        }
    }
    finally {
        return (0, semver_1.checkAndCleanWithSemver)(tree, 'typescript', tsVersionInRootPackageJson);
    }
}
async function initGenerator(tree, schema) {
    schema.addTsPlugin ??= false;
    const isUsingNewTsSetup = schema.addTsPlugin || (0, ts_solution_setup_1.isUsingTsSolutionSetup)(tree);
    schema.formatter ??= isUsingNewTsSetup ? 'none' : 'prettier';
    return initGeneratorInternal(tree, {
        addTsConfigBase: true,
        ...schema,
    });
}
async function initGeneratorInternal(tree, schema) {
    const tasks = [];
    const nxJson = (0, devkit_1.readNxJson)(tree);
    schema.addPlugin ??=
        process.env.NX_ADD_PLUGINS !== 'false' &&
            nxJson.useInferencePlugins !== false;
    schema.addTsPlugin ??= schema.addPlugin;
    if (schema.addTsPlugin) {
        await (0, add_plugin_1.addPlugin)(tree, await (0, devkit_1.createProjectGraphAsync)(), '@nx/js/typescript', plugin_1.createNodesV2, {
            typecheck: [
                { targetName: 'typecheck' },
                { targetName: 'tsc:typecheck' },
                { targetName: 'tsc-typecheck' },
            ],
            build: [
                {
                    targetName: 'build',
                    configName: 'tsconfig.lib.json',
                    buildDepsName: 'build-deps',
                    watchDepsName: 'watch-deps',
                },
                {
                    targetName: 'tsc:build',
                    configName: 'tsconfig.lib.json',
                    buildDepsName: 'tsc:build-deps',
                    watchDepsName: 'tsc:watch-deps',
                },
                {
                    targetName: 'tsc-build',
                    configName: 'tsconfig.lib.json',
                    buildDepsName: 'tsc-build-deps',
                    watchDepsName: 'tsc-watch-deps',
                },
            ],
        }, schema.updatePackageScripts);
    }
    if (schema.addTsConfigBase && !(0, ts_config_1.getRootTsConfigFileName)(tree)) {
        if (schema.addTsPlugin) {
            const platform = schema.platform ?? 'node';
            const customCondition = (0, ts_solution_setup_1.getCustomConditionName)(tree);
            (0, devkit_1.generateFiles)(tree, (0, path_1.join)(__dirname, './files/ts-solution'), '.', {
                platform,
                customCondition,
                tmpl: '',
            });
        }
        else {
            (0, devkit_1.generateFiles)(tree, (0, path_1.join)(__dirname, './files/non-ts-solution'), '.', {
                fileName: schema.tsConfigName ?? 'tsconfig.base.json',
            });
        }
    }
    const devDependencies = {
        '@nx/js': versions_1.nxVersion,
        // When loading .ts config files (e.g. webpack.config.ts, jest.config.ts, etc.)
        // we prefer to use SWC, and fallback to ts-node for workspaces that don't use SWC.
        '@swc-node/register': versions_1.swcNodeVersion,
        '@swc/core': versions_1.swcCoreVersion,
        '@swc/helpers': versions_1.swcHelpersVersion,
    };
    if (!schema.js && !schema.keepExistingVersions) {
        const installedTsVersion = await getInstalledTypescriptVersion(tree);
        if (!installedTsVersion ||
            !(0, semver_2.satisfies)(installedTsVersion, versions_1.supportedTypescriptVersions, {
                includePrerelease: true,
            })) {
            devDependencies['typescript'] = versions_1.typescriptVersion;
        }
    }
    if (schema.formatter === 'prettier') {
        const prettierTask = (0, prettier_1.generatePrettierSetup)(tree, {
            skipPackageJson: schema.skipPackageJson,
        });
        tasks.push(prettierTask);
    }
    const rootTsConfigFileName = (0, ts_config_1.getRootTsConfigFileName)(tree);
    // If the root tsconfig file uses `importHelpers` then we must install tslib
    // in order to run tsc for build and typecheck.
    if (rootTsConfigFileName) {
        const rootTsConfig = (0, devkit_1.readJson)(tree, rootTsConfigFileName);
        if (rootTsConfig.compilerOptions?.importHelpers) {
            devDependencies['tslib'] = versions_1.tsLibVersion;
        }
    }
    const installTask = !schema.skipPackageJson
        ? (0, devkit_1.addDependenciesToPackageJson)(tree, {}, devDependencies, undefined, schema.keepExistingVersions)
        : () => { };
    tasks.push(installTask);
    if (!schema.skipPackageJson &&
        // For `create-nx-workspace` or `nx g @nx/js:init`, we want to make sure users didn't set formatter to none.
        // For programmatic usage, the formatter is normally undefined, and we want prettier to continue to be ensured, even if not ultimately installed.
        schema.formatter !== 'none') {
        (0, devkit_1.ensurePackage)('prettier', versions_1.prettierVersion);
    }
    if (!schema.skipFormat) {
        // even if skipPackageJson === true, we can safely run formatFiles, prettier might
        // have been installed earlier and if not, the formatFiles function still handles it
        await (0, devkit_1.formatFiles)(tree);
    }
    return (0, devkit_1.runTasksInSerial)(...tasks);
}
exports.default = initGenerator;

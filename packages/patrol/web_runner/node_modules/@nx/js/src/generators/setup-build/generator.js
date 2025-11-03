"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.setupBuildGenerator = setupBuildGenerator;
const devkit_1 = require("@nx/devkit");
const target_defaults_utils_1 = require("@nx/devkit/src/generators/target-defaults-utils");
const posix_1 = require("node:path/posix");
const devkit_internals_1 = require("nx/src/devkit-internals");
const get_import_path_1 = require("../../utils/get-import-path");
const update_package_json_1 = require("../../utils/package-json/update-package-json");
const add_swc_config_1 = require("../../utils/swc/add-swc-config");
const add_swc_dependencies_1 = require("../../utils/swc/add-swc-dependencies");
const ensure_typescript_1 = require("../../utils/typescript/ensure-typescript");
const plugin_1 = require("../../utils/typescript/plugin");
const ts_config_1 = require("../../utils/typescript/ts-config");
const ts_solution_setup_1 = require("../../utils/typescript/ts-solution-setup");
const versions_1 = require("../../utils/versions");
let ts;
async function setupBuildGenerator(tree, options) {
    const tasks = [];
    const project = (0, devkit_1.readProjectConfiguration)(tree, options.project);
    options.buildTarget ??= 'build';
    const prevBuildOptions = project.targets?.[options.buildTarget]?.options;
    project.targets ??= {};
    let mainFile;
    if (prevBuildOptions?.main) {
        mainFile = prevBuildOptions.main;
    }
    else if (options.main) {
        mainFile = options.main;
    }
    else {
        const root = (0, ts_solution_setup_1.getProjectSourceRoot)(project, tree);
        for (const f of [
            (0, devkit_1.joinPathFragments)(root, 'main.ts'),
            (0, devkit_1.joinPathFragments)(root, 'main.js'),
            (0, devkit_1.joinPathFragments)(root, 'index.ts'),
            (0, devkit_1.joinPathFragments)(root, 'index.js'),
        ]) {
            if (tree.exists(f)) {
                mainFile = f;
                break;
            }
        }
    }
    if (!mainFile || !tree.exists(mainFile)) {
        throw new Error(`Cannot locate a main file for ${options.project}. Please specify one using --main=<file-path>.`);
    }
    options.main = mainFile;
    let tsConfigFile;
    if (prevBuildOptions?.tsConfig) {
        tsConfigFile = prevBuildOptions.tsConfig;
    }
    else if (options.tsConfig) {
        tsConfigFile = options.tsConfig;
    }
    else {
        for (const f of [
            'tsconfig.lib.json',
            'tsconfig.app.json',
            'tsconfig.json',
        ]) {
            const candidate = (0, devkit_1.joinPathFragments)(project.root, f);
            if (tree.exists(candidate)) {
                tsConfigFile = candidate;
                break;
            }
        }
    }
    if (!tsConfigFile || !tree.exists(tsConfigFile)) {
        throw new Error(`Cannot locate a tsConfig file for ${options.project}. Please specify one using --tsConfig=<file-path>.`);
    }
    options.tsConfig = tsConfigFile;
    const isTsSolutionSetup = (0, ts_solution_setup_1.isUsingTsSolutionSetup)(tree);
    const nxJson = (0, devkit_1.readNxJson)(tree);
    const addPlugin = process.env.NX_ADD_PLUGINS !== 'false' &&
        nxJson.useInferencePlugins !== false;
    switch (options.bundler) {
        case 'vite': {
            const { viteConfigurationGenerator } = (0, devkit_1.ensurePackage)('@nx/vite', versions_1.nxVersion);
            const task = await viteConfigurationGenerator(tree, {
                buildTarget: options.buildTarget,
                project: options.project,
                newProject: false,
                uiFramework: 'none',
                includeVitest: false,
                includeLib: true,
                addPlugin,
                skipFormat: true,
            });
            tasks.push(task);
            break;
        }
        case 'esbuild': {
            const { configurationGenerator } = (0, devkit_1.ensurePackage)('@nx/esbuild', versions_1.nxVersion);
            const task = await configurationGenerator(tree, {
                main: mainFile,
                buildTarget: options.buildTarget,
                project: options.project,
                skipFormat: true,
                skipValidation: true,
                format: isTsSolutionSetup ? ['esm'] : ['cjs'],
            });
            tasks.push(task);
            break;
        }
        case 'rollup': {
            const { configurationGenerator } = (0, devkit_1.ensurePackage)('@nx/rollup', versions_1.nxVersion);
            const task = await configurationGenerator(tree, {
                buildTarget: options.buildTarget,
                main: mainFile,
                tsConfig: tsConfigFile,
                project: options.project,
                compiler: 'tsc',
                format: isTsSolutionSetup ? ['esm'] : ['cjs', 'esm'],
                addPlugin,
                skipFormat: true,
                skipValidation: true,
            });
            tasks.push(task);
            break;
        }
        case 'tsc': {
            if (isTsSolutionSetup) {
                const nxJson = (0, devkit_1.readNxJson)(tree);
                (0, plugin_1.ensureProjectIsIncludedInPluginRegistrations)(nxJson, project.root, options.buildTarget);
                (0, devkit_1.updateNxJson)(tree, nxJson);
                updatePackageJsonForTsc(tree, options, project);
            }
            else {
                (0, target_defaults_utils_1.addBuildTargetDefaults)(tree, '@nx/js:tsc');
                const outputPath = (0, devkit_1.joinPathFragments)('dist', project.root);
                project.targets[options.buildTarget] = {
                    executor: `@nx/js:tsc`,
                    outputs: ['{options.outputPath}'],
                    options: {
                        outputPath,
                        main: mainFile,
                        tsConfig: tsConfigFile,
                        assets: [],
                    },
                };
                (0, devkit_1.updateProjectConfiguration)(tree, options.project, project);
            }
            break;
        }
        case 'swc': {
            (0, target_defaults_utils_1.addBuildTargetDefaults)(tree, '@nx/js:swc');
            const outputPath = isTsSolutionSetup
                ? (0, devkit_1.joinPathFragments)(project.root, 'dist')
                : (0, devkit_1.joinPathFragments)('dist', project.root);
            project.targets[options.buildTarget] = {
                executor: `@nx/js:swc`,
                outputs: ['{options.outputPath}'],
                options: {
                    outputPath,
                    main: mainFile,
                    tsConfig: tsConfigFile,
                },
            };
            if (isTsSolutionSetup) {
                project.targets[options.buildTarget].options.stripLeadingPaths = true;
            }
            else {
                project.targets[options.buildTarget].options.assets = [];
            }
            (0, devkit_1.updateProjectConfiguration)(tree, options.project, project);
            tasks.push((0, add_swc_dependencies_1.addSwcDependencies)(tree));
            (0, add_swc_config_1.addSwcConfig)(tree, project.root, isTsSolutionSetup ? 'es6' : 'commonjs');
            if (isTsSolutionSetup) {
                updatePackageJsonForSwc(tree, options, project);
            }
        }
    }
    await (0, devkit_1.formatFiles)(tree);
    return (0, devkit_1.runTasksInSerial)(...tasks);
}
exports.default = setupBuildGenerator;
function updatePackageJsonForTsc(tree, options, project) {
    if (!ts) {
        ts = (0, ensure_typescript_1.ensureTypescript)();
    }
    const tsconfig = (0, ts_config_1.readTsConfig)(options.tsConfig, {
        ...ts.sys,
        readFile: (p) => tree.read(p, 'utf-8'),
        fileExists: (p) => tree.exists(p),
    });
    let main;
    let rootDir;
    let outputPath;
    if (project.targets?.[options.buildTarget]) {
        const mergedTarget = mergeTargetDefaults(tree, project, options.buildTarget);
        ({ main, rootDir, outputPath } = mergedTarget.options);
    }
    else {
        main = options.main;
        ({ rootDir = project.root, outDir: outputPath } = tsconfig.options);
        const tsOutFile = tsconfig.options.outFile;
        if (tsOutFile) {
            main = (0, posix_1.join)(project.root, (0, posix_1.basename)(tsOutFile));
            outputPath = (0, posix_1.dirname)(tsOutFile);
        }
        if (!outputPath) {
            outputPath = project.root;
        }
    }
    const module = Object.keys(ts.ModuleKind).find((m) => ts.ModuleKind[m] === tsconfig.options.module);
    const format = module.toLowerCase().startsWith('es')
        ? ['esm']
        : ['cjs'];
    updatePackageJson(tree, options.project, project.root, main, outputPath, rootDir, format);
}
function updatePackageJsonForSwc(tree, options, project) {
    const mergedTarget = mergeTargetDefaults(tree, project, options.buildTarget);
    const { main, outputPath, swcrc: swcrcPath = (0, posix_1.join)(project.root, '.swcrc'), } = mergedTarget.options;
    const swcrc = (0, devkit_1.readJson)(tree, swcrcPath);
    const format = swcrc.module?.type?.startsWith('es')
        ? ['esm']
        : ['cjs'];
    updatePackageJson(tree, options.project, project.root, main, outputPath, 
    // we set the `stripLeadingPaths` option, so the rootDir would match the dirname of the entry point
    (0, posix_1.dirname)(main), format);
}
function updatePackageJson(tree, projectName, projectRoot, main, outputPath, rootDir, format) {
    const packageJsonPath = (0, posix_1.join)(projectRoot, 'package.json');
    let packageJson;
    if (tree.exists(packageJsonPath)) {
        packageJson = (0, devkit_1.readJson)(tree, packageJsonPath);
    }
    else {
        packageJson = {
            name: (0, get_import_path_1.getImportPath)(tree, projectName),
            version: '0.0.1',
        };
    }
    packageJson = (0, update_package_json_1.getUpdatedPackageJsonContent)(packageJson, {
        main,
        outputPath,
        projectRoot,
        generateExportsField: true,
        packageJsonPath,
        rootDir,
        format,
        developmentConditionName: (0, ts_solution_setup_1.getDefinedCustomConditionName)(tree),
    });
    (0, devkit_1.writeJson)(tree, packageJsonPath, packageJson);
}
function mergeTargetDefaults(tree, project, buildTarget) {
    const nxJson = (0, devkit_1.readNxJson)(tree);
    const projectTarget = project.targets[buildTarget];
    return (0, devkit_internals_1.mergeTargetConfigurations)(projectTarget, (projectTarget.executor
        ? nxJson.targetDefaults?.[projectTarget.executor]
        : undefined) ?? nxJson.targetDefaults?.[buildTarget]);
}

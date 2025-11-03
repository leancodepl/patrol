"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.convertToSwcGenerator = convertToSwcGenerator;
const devkit_1 = require("@nx/devkit");
const path_1 = require("path");
const add_swc_config_1 = require("../../utils/swc/add-swc-config");
const add_swc_dependencies_1 = require("../../utils/swc/add-swc-dependencies");
const versions_1 = require("../../utils/versions");
async function convertToSwcGenerator(tree, schema) {
    const options = normalizeOptions(schema);
    const projectConfiguration = (0, devkit_1.readProjectConfiguration)(tree, options.project);
    const updated = updateProjectBuildTargets(tree, projectConfiguration, options.project, options.targets);
    return updated ? checkSwcDependencies(tree, projectConfiguration) : () => { };
}
function normalizeOptions(schema) {
    const options = { ...schema };
    if (!options.targets) {
        options.targets = ['build'];
    }
    return options;
}
function updateProjectBuildTargets(tree, projectConfiguration, projectName, projectTargets) {
    let updated = false;
    for (const target of projectTargets) {
        const targetConfiguration = projectConfiguration.targets?.[target];
        if (!targetConfiguration || targetConfiguration.executor !== '@nx/js:tsc')
            continue;
        targetConfiguration.executor = '@nx/js:swc';
        updated = true;
    }
    if (updated) {
        (0, devkit_1.updateProjectConfiguration)(tree, projectName, projectConfiguration);
    }
    return updated;
}
function checkSwcDependencies(tree, projectConfiguration) {
    const isSwcrcPresent = tree.exists((0, path_1.join)(projectConfiguration.root, '.swcrc'));
    const packageJson = (0, devkit_1.readJson)(tree, 'package.json');
    const projectPackageJsonPath = (0, path_1.join)(projectConfiguration.root, 'package.json');
    const projectPackageJson = (0, devkit_1.readJson)(tree, projectPackageJsonPath);
    const hasSwcDependency = packageJson.dependencies && packageJson.dependencies['@swc/core'];
    const hasSwcHelpers = projectPackageJson.dependencies &&
        projectPackageJson.dependencies['@swc/helpers'];
    if (isSwcrcPresent && hasSwcDependency && hasSwcHelpers)
        return;
    if (!isSwcrcPresent) {
        (0, add_swc_config_1.addSwcConfig)(tree, projectConfiguration.root);
    }
    if (!hasSwcDependency) {
        (0, add_swc_dependencies_1.addSwcDependencies)(tree);
    }
    if (!hasSwcHelpers) {
        (0, devkit_1.addDependenciesToPackageJson)(tree, { '@swc/helpers': versions_1.swcHelpersVersion }, {}, projectPackageJsonPath);
    }
    return () => {
        if (!hasSwcDependency) {
            (0, devkit_1.installPackagesTask)(tree);
        }
    };
}
exports.default = convertToSwcGenerator;

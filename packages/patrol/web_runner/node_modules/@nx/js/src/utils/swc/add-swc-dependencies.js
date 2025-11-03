"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSwcDependencies = getSwcDependencies;
exports.addSwcDependencies = addSwcDependencies;
exports.addSwcRegisterDependencies = addSwcRegisterDependencies;
const devkit_1 = require("@nx/devkit");
const versions_1 = require("../versions");
function getSwcDependencies() {
    const dependencies = {
        '@swc/helpers': versions_1.swcHelpersVersion,
    };
    const devDependencies = {
        '@swc/core': versions_1.swcCoreVersion,
        '@swc/cli': versions_1.swcCliVersion,
    };
    return { dependencies, devDependencies };
}
function addSwcDependencies(tree) {
    const { dependencies, devDependencies } = getSwcDependencies();
    return (0, devkit_1.addDependenciesToPackageJson)(tree, dependencies, devDependencies);
}
function addSwcRegisterDependencies(tree) {
    return (0, devkit_1.addDependenciesToPackageJson)(tree, {}, { '@swc-node/register': versions_1.swcNodeVersion, '@swc/core': versions_1.swcCoreVersion });
}

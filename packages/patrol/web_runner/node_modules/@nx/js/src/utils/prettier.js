"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.resolveUserExistingPrettierConfig = resolveUserExistingPrettierConfig;
exports.generatePrettierSetup = generatePrettierSetup;
exports.resolvePrettierConfigPath = resolvePrettierConfigPath;
const devkit_1 = require("@nx/devkit");
const versions_1 = require("./versions");
async function resolveUserExistingPrettierConfig() {
    let prettier;
    try {
        prettier = require('prettier');
    }
    catch {
        return null;
    }
    try {
        const filepath = await prettier.resolveConfigFile();
        if (!filepath) {
            return null;
        }
        const config = await prettier.resolveConfig(process.cwd(), {
            useCache: false,
            config: filepath,
        });
        if (!config) {
            return null;
        }
        return {
            sourceFilepath: filepath,
            config: config,
        };
    }
    catch {
        return null;
    }
}
function generatePrettierSetup(tree, options) {
    // https://prettier.io/docs/en/configuration.html
    const prettierrcNameOptions = [
        '.prettierrc',
        '.prettierrc.json',
        '.prettierrc.yml',
        '.prettierrc.yaml',
        '.prettierrc.json5',
        '.prettierrc.js',
        '.prettierrc.cjs',
        '.prettierrc.mjs',
        '.prettierrc.toml',
        'prettier.config.js',
        'prettier.config.cjs',
        'prettier.config.mjs',
    ];
    if (prettierrcNameOptions.every((name) => !tree.exists(name))) {
        (0, devkit_1.writeJson)(tree, '.prettierrc', { singleQuote: true });
    }
    if (!tree.exists('.prettierignore')) {
        tree.write('.prettierignore', (0, devkit_1.stripIndents) `# Add files here to ignore them from prettier formatting
        /dist
        /coverage
        /.nx/cache
        /.nx/workspace-data
      `);
    }
    if (tree.exists('.vscode/extensions.json')) {
        (0, devkit_1.updateJson)(tree, '.vscode/extensions.json', (json) => {
            json.recommendations ??= [];
            const extension = 'esbenp.prettier-vscode';
            if (!json.recommendations.includes(extension)) {
                json.recommendations.push(extension);
            }
            return json;
        });
    }
    return options.skipPackageJson
        ? () => { }
        : (0, devkit_1.addDependenciesToPackageJson)(tree, {}, { prettier: versions_1.prettierVersion });
}
async function resolvePrettierConfigPath(tree) {
    let prettier;
    try {
        prettier = require('prettier');
    }
    catch {
        return null;
    }
    if (prettier) {
        const filePath = await prettier.resolveConfigFile();
        if (filePath) {
            return filePath;
        }
    }
    if (!tree) {
        return null;
    }
    // if we haven't find a config file in the file system, we try to find it in the virtual tree
    // https://prettier.io/docs/en/configuration.html
    const prettierrcNameOptions = [
        '.prettierrc',
        '.prettierrc.json',
        '.prettierrc.yml',
        '.prettierrc.yaml',
        '.prettierrc.json5',
        '.prettierrc.js',
        '.prettierrc.cjs',
        '.prettierrc.mjs',
        '.prettierrc.toml',
        'prettier.config.js',
        'prettier.config.cjs',
        'prettier.config.mjs',
    ];
    const filePath = prettierrcNameOptions.find((file) => tree.exists(file));
    if (filePath) {
        return filePath;
    }
    // check the package.json file
    const packageJson = (0, devkit_1.readJson)(tree, 'package.json');
    if (packageJson.prettier) {
        return 'package.json';
    }
    // check the package.yaml file
    if (tree.exists('package.yaml')) {
        const { load } = await Promise.resolve().then(() => require('@zkochan/js-yaml'));
        const packageYaml = load(tree.read('package.yaml', 'utf-8'));
        if (packageYaml.prettier) {
            return 'package.yaml';
        }
    }
    return null;
}

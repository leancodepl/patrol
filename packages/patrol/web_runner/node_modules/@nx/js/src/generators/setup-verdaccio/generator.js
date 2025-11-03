"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.setupVerdaccio = setupVerdaccio;
const devkit_1 = require("@nx/devkit");
const path = require("path");
const ts_solution_setup_1 = require("../../utils/typescript/ts-solution-setup");
const versions_1 = require("../../utils/versions");
const child_process_1 = require("child_process");
async function setupVerdaccio(tree, options) {
    if (!tree.exists('.verdaccio/config.yml')) {
        (0, devkit_1.generateFiles)(tree, path.join(__dirname, 'files'), '.verdaccio', {
            npmUplinkRegistry: (0, child_process_1.execSync)('npm config get registry', {
                windowsHide: false,
            })
                ?.toString()
                ?.trim() ?? 'https://registry.npmjs.org',
        });
    }
    const verdaccioTarget = {
        executor: '@nx/js:verdaccio',
        options: {
            port: 4873,
            config: '.verdaccio/config.yml',
            storage: 'tmp/local-registry/storage',
        },
    };
    if (!tree.exists('project.json')) {
        const isUsingNewTsSetup = (0, ts_solution_setup_1.isUsingTsSolutionSetup)(tree);
        const { name } = (0, devkit_1.readJson)(tree, 'package.json');
        (0, devkit_1.updateJson)(tree, 'package.json', (json) => {
            json.nx ??= { includedScripts: [] };
            if (isUsingNewTsSetup) {
                json.nx.targets ??= {};
                json.nx.targets['local-registry'] ??= verdaccioTarget;
            }
            return json;
        });
        if (!isUsingNewTsSetup) {
            (0, devkit_1.addProjectConfiguration)(tree, name, {
                root: '.',
                targets: {
                    ['local-registry']: verdaccioTarget,
                },
            });
        }
    }
    else {
        // use updateJson instead of updateProjectConfiguration due to unknown project name
        (0, devkit_1.updateJson)(tree, 'project.json', (json) => {
            if (!json.targets) {
                json.targets = {};
            }
            json.targets['local-registry'] ??= verdaccioTarget;
            return json;
        });
    }
    if (!options.skipFormat) {
        await (0, devkit_1.formatFiles)(tree);
    }
    return (0, devkit_1.addDependenciesToPackageJson)(tree, {}, { verdaccio: versions_1.verdaccioVersion });
}
exports.default = setupVerdaccio;

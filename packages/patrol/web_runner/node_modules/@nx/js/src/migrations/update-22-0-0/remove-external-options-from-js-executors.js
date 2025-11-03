"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.executors = void 0;
exports.default = default_1;
const devkit_1 = require("@nx/devkit");
const executor_options_utils_1 = require("@nx/devkit/src/generators/executor-options-utils");
exports.executors = ['@nx/js:swc', '@nx/js:tsc'];
async function default_1(tree) {
    // update options from project configs
    exports.executors.forEach((executor) => {
        (0, executor_options_utils_1.forEachExecutorOptions)(tree, executor, (options, project, target, configuration) => {
            if (options.external === undefined &&
                options.externalBuildTargets === undefined) {
                return;
            }
            const projectConfiguration = (0, devkit_1.readProjectConfiguration)(tree, project);
            if (configuration) {
                const config = projectConfiguration.targets[target].configurations[configuration];
                delete config.external;
                delete config.externalBuildTargets;
            }
            else {
                const config = projectConfiguration.targets[target].options;
                delete config.external;
                delete config.externalBuildTargets;
                if (!Object.keys(config).length) {
                    delete projectConfiguration.targets[target].options;
                }
            }
            (0, devkit_1.updateProjectConfiguration)(tree, project, projectConfiguration);
        });
    });
    // update options from nx.json target defaults
    const nxJson = (0, devkit_1.readNxJson)(tree);
    if (!nxJson.targetDefaults) {
        return;
    }
    for (const [targetOrExecutor, targetConfig] of Object.entries(nxJson.targetDefaults)) {
        if (!exports.executors.includes(targetOrExecutor) &&
            !exports.executors.includes(targetConfig.executor)) {
            continue;
        }
        if (targetConfig.options) {
            delete targetConfig.options.external;
            delete targetConfig.options.externalBuildTargets;
            if (!Object.keys(targetConfig.options).length) {
                delete targetConfig.options;
            }
        }
        Object.entries(targetConfig.configurations ?? {}).forEach(([, config]) => {
            delete config.external;
            delete config.externalBuildTargets;
        });
        if (!Object.keys(targetConfig).length ||
            (Object.keys(targetConfig).length === 1 &&
                Object.keys(targetConfig)[0] === 'executor')) {
            delete nxJson.targetDefaults[targetOrExecutor];
        }
        if (!Object.keys(nxJson.targetDefaults).length) {
            delete nxJson.targetDefaults;
        }
    }
    (0, devkit_1.updateNxJson)(tree, nxJson);
    await (0, devkit_1.formatFiles)(tree);
}

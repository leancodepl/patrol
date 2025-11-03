"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.convertToInferredGenerator = convertToInferredGenerator;
const devkit_1 = require("@nx/devkit");
const executor_to_plugin_migrator_1 = require("@nx/devkit/src/generators/plugin-migrations/executor-to-plugin-migrator");
const enquirer_1 = require("enquirer");
const generator_utils_1 = require("nx/src/command-line/generate/generator-utils");
const installed_plugins_1 = require("nx/src/utils/plugins/installed-plugins");
async function convertToInferredGenerator(tree, options) {
    const generatorCollectionChoices = await getPossibleConvertToInferredGenerators();
    if (generatorCollectionChoices.size === 0) {
        devkit_1.output.error({
            title: 'No inference plugin found. For information on this migration, see https://nx.dev/recipes/running-tasks/convert-to-inferred',
        });
        return;
    }
    let generatorsToRun;
    if (options.plugins && options.plugins.filter((p) => !!p).length > 0) {
        generatorsToRun = Array.from(generatorCollectionChoices.values())
            .filter((generator) => options.plugins.includes(generator.resolvedCollectionName))
            .map((generator) => generator.resolvedCollectionName);
    }
    else if (process.argv.includes('--no-interactive')) {
        generatorsToRun = Array.from(generatorCollectionChoices.keys());
    }
    else {
        const allChoices = Array.from(generatorCollectionChoices.keys());
        generatorsToRun = (await (0, enquirer_1.prompt)({
            type: 'multiselect',
            name: 'generatorsToRun',
            message: 'Which inference plugin do you want to use?',
            choices: allChoices,
            initial: allChoices,
            validate: (result) => {
                if (result.length === 0) {
                    return 'Please select at least one plugin.';
                }
                return true;
            },
        })).generatorsToRun;
    }
    if (generatorsToRun.length === 0) {
        devkit_1.output.error({
            title: 'Please select at least one plugin.',
        });
        return;
    }
    const tasks = [];
    for (const generatorCollection of generatorsToRun) {
        try {
            const generator = generatorCollectionChoices.get(generatorCollection);
            if (generator) {
                const generatorFactory = generator.implementationFactory();
                const callback = await generatorFactory(tree, {
                    project: options.project,
                    skipFormat: options.skipFormat,
                });
                if (callback) {
                    const task = await callback();
                    if (typeof task === 'function')
                        tasks.push(task);
                }
                devkit_1.output.success({
                    title: `${generatorCollection}:convert-to-inferred - Success`,
                });
            }
        }
        catch (e) {
            if (e instanceof executor_to_plugin_migrator_1.NoTargetsToMigrateError) {
                devkit_1.output.note({
                    title: `${generatorCollection}:convert-to-inferred - Skipped (No targets to migrate)`,
                });
            }
            else {
                devkit_1.output.error({
                    title: `${generatorCollection}:convert-to-inferred - Failed`,
                });
                throw e;
            }
        }
    }
    if (!options.skipFormat) {
        await (0, devkit_1.formatFiles)(tree);
    }
    return (0, devkit_1.runTasksInSerial)(...tasks);
}
async function getPossibleConvertToInferredGenerators() {
    const installedCollections = Array.from(new Set((0, installed_plugins_1.findInstalledPlugins)().map((x) => x.name)));
    const projectGraph = await (0, devkit_1.createProjectGraphAsync)();
    const projectsConfigurations = (0, devkit_1.readProjectsConfigurationFromProjectGraph)(projectGraph);
    const choices = new Map();
    for (const collectionName of installedCollections) {
        try {
            const generator = (0, generator_utils_1.getGeneratorInformation)(collectionName, 'convert-to-inferred', devkit_1.workspaceRoot, projectsConfigurations.projects);
            if (generator.generatorConfiguration.hidden ||
                generator.generatorConfiguration['x-deprecated']) {
                continue;
            }
            choices.set(generator.resolvedCollectionName, generator);
        }
        catch {
            // this just means that no convert-to-inferred generator exists for a given collection, ignore
        }
    }
    return choices;
}
exports.default = convertToInferredGenerator;

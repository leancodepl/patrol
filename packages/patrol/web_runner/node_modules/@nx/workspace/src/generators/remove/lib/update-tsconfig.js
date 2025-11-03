"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateTsconfig = updateTsconfig;
const devkit_1 = require("@nx/devkit");
const ts_config_1 = require("../../../utilities/ts-config");
const find_project_for_path_1 = require("nx/src/project-graph/utils/find-project-for-path");
const ts_solution_setup_1 = require("../../../utilities/typescript/ts-solution-setup");
const path_1 = require("path");
/**
 * Updates the tsconfig paths to remove the project.
 *
 * @param schema The options provided to the schematic
 */
async function updateTsconfig(tree, schema) {
    const isUsingTsSolution = (0, ts_solution_setup_1.isUsingTsSolutionSetup)(tree);
    const tsConfigPath = isUsingTsSolution
        ? 'tsconfig.json'
        : (0, ts_config_1.getRootTsConfigPathInTree)(tree);
    if (tree.exists(tsConfigPath)) {
        const graph = await (0, devkit_1.createProjectGraphAsync)();
        const projectMapping = (0, find_project_for_path_1.createProjectRootMappings)(graph.nodes);
        (0, devkit_1.updateJson)(tree, tsConfigPath, (json) => {
            if (isUsingTsSolution) {
                const projectConfigs = (0, devkit_1.readProjectsConfigurationFromProjectGraph)(graph);
                const project = projectConfigs.projects[schema.projectName];
                if (!project) {
                    throw new Error(`Could not find project '${schema.project}'. Please choose a project that exists in the Nx Workspace.`);
                }
                json.references = json.references.filter((ref) => (0, path_1.relative)(ref.path, project.root) !== '');
            }
            else {
                for (const importPath in json.compilerOptions.paths) {
                    for (const path of json.compilerOptions.paths[importPath]) {
                        const project = (0, find_project_for_path_1.findProjectForPath)((0, devkit_1.normalizePath)(path), projectMapping);
                        if (project === schema.projectName) {
                            delete json.compilerOptions.paths[importPath];
                            break;
                        }
                    }
                }
            }
            return json;
        });
    }
}

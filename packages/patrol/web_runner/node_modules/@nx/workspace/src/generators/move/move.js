"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.moveGenerator = moveGenerator;
const devkit_1 = require("@nx/devkit");
const package_manager_workspaces_1 = require("../../utilities/package-manager-workspaces");
const ts_solution_setup_1 = require("../../utilities/typescript/ts-solution-setup");
const check_destination_1 = require("./lib/check-destination");
const create_project_configuration_in_new_destination_1 = require("./lib/create-project-configuration-in-new-destination");
const extract_base_configs_1 = require("./lib/extract-base-configs");
const move_project_files_1 = require("./lib/move-project-files");
const normalize_schema_1 = require("./lib/normalize-schema");
const run_angular_plugin_1 = require("./lib/run-angular-plugin");
const update_build_targets_1 = require("./lib/update-build-targets");
const update_cypress_config_1 = require("./lib/update-cypress-config");
const update_default_project_1 = require("./lib/update-default-project");
const update_eslint_config_1 = require("./lib/update-eslint-config");
const update_implicit_dependencies_1 = require("./lib/update-implicit-dependencies");
const update_imports_1 = require("./lib/update-imports");
const update_jest_config_1 = require("./lib/update-jest-config");
const update_package_json_1 = require("./lib/update-package-json");
const update_project_root_files_1 = require("./lib/update-project-root-files");
const update_readme_1 = require("./lib/update-readme");
const update_storybook_config_1 = require("./lib/update-storybook-config");
async function moveGenerator(tree, rawSchema) {
    let projectConfig = (0, devkit_1.readProjectConfiguration)(tree, rawSchema.projectName);
    const wasIncludedInWorkspaces = (0, package_manager_workspaces_1.isProjectIncludedInPackageManagerWorkspaces)(tree, projectConfig.root);
    const schema = await (0, normalize_schema_1.normalizeSchema)(tree, rawSchema, projectConfig);
    (0, check_destination_1.checkDestination)(tree, schema, rawSchema.destination);
    if (projectConfig.root === '.') {
        (0, extract_base_configs_1.maybeExtractTsConfigBase)(tree);
        await (0, extract_base_configs_1.maybeExtractJestConfigBase)(tree);
        // Reload config since it has been updated after extracting base configs
        projectConfig = (0, devkit_1.readProjectConfiguration)(tree, rawSchema.projectName);
    }
    (0, devkit_1.removeProjectConfiguration)(tree, schema.projectName);
    (0, move_project_files_1.moveProjectFiles)(tree, schema, projectConfig);
    (0, create_project_configuration_in_new_destination_1.createProjectConfigurationInNewDestination)(tree, schema, projectConfig);
    (0, update_imports_1.updateImports)(tree, schema, projectConfig);
    (0, update_project_root_files_1.updateProjectRootFiles)(tree, schema, projectConfig);
    (0, update_cypress_config_1.updateCypressConfig)(tree, schema, projectConfig);
    (0, update_jest_config_1.updateJestConfig)(tree, schema, projectConfig);
    (0, update_storybook_config_1.updateStorybookConfig)(tree, schema, projectConfig);
    (0, update_eslint_config_1.updateEslintConfig)(tree, schema, projectConfig);
    (0, update_readme_1.updateReadme)(tree, schema);
    (0, update_package_json_1.updatePackageJson)(tree, schema);
    (0, update_build_targets_1.updateBuildTargets)(tree, schema);
    (0, update_default_project_1.updateDefaultProject)(tree, schema);
    (0, update_implicit_dependencies_1.updateImplicitDependencies)(tree, schema);
    if (projectConfig.root === '.') {
        // we want to migrate eslint config once the root project files are moved
        (0, extract_base_configs_1.maybeMigrateEslintConfigIfRootProject)(tree, projectConfig);
    }
    await (0, run_angular_plugin_1.runAngularPlugin)(tree, schema);
    let task;
    if (wasIncludedInWorkspaces) {
        // check if the new destination is included in the package manager workspaces
        const isIncludedInWorkspaces = (0, package_manager_workspaces_1.isProjectIncludedInPackageManagerWorkspaces)(tree, schema.destination);
        if (!isIncludedInWorkspaces) {
            // the new destination is not included in the package manager workspaces
            // so we need to add it and run a package install to ensure the symlink
            // is created
            await (0, ts_solution_setup_1.addProjectToTsSolutionWorkspace)(tree, schema.destination);
            task = () => (0, devkit_1.installPackagesTask)(tree, true);
        }
    }
    if (!schema.skipFormat) {
        await (0, devkit_1.formatFiles)(tree);
    }
    if (task) {
        return task;
    }
}
exports.default = moveGenerator;

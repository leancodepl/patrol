"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.removeGenerator = removeGenerator;
const devkit_1 = require("@nx/devkit");
const check_project_is_safe_to_remove_1 = require("./lib/check-project-is-safe-to-remove");
const check_dependencies_1 = require("./lib/check-dependencies");
const check_targets_1 = require("./lib/check-targets");
const remove_project_1 = require("./lib/remove-project");
const update_tsconfig_1 = require("./lib/update-tsconfig");
const remove_project_references_in_config_1 = require("./lib/remove-project-references-in-config");
const update_jest_config_1 = require("./lib/update-jest-config");
async function removeGenerator(tree, schema) {
    const project = (0, devkit_1.readProjectConfiguration)(tree, schema.projectName);
    await (0, check_project_is_safe_to_remove_1.checkProjectIsSafeToRemove)(tree, schema, project);
    await (0, check_dependencies_1.checkDependencies)(tree, schema);
    await (0, check_targets_1.checkTargets)(tree, schema);
    (0, update_jest_config_1.updateJestConfig)(tree, schema, project);
    (0, remove_project_references_in_config_1.removeProjectReferencesInConfig)(tree, schema);
    (0, remove_project_1.removeProject)(tree, project);
    await (0, update_tsconfig_1.updateTsconfig)(tree, schema);
    if (!schema.skipFormat) {
        await (0, devkit_1.formatFiles)(tree);
    }
}
exports.default = removeGenerator;

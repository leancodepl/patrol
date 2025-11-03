"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const resolve_workspace_rules_1 = require("./src/resolve-workspace-rules");
const dependency_checks_1 = tslib_1.__importStar(require("./src/rules/dependency-checks"));
const enforce_module_boundaries_1 = tslib_1.__importStar(require("./src/rules/enforce-module-boundaries"));
const nx_plugin_checks_1 = tslib_1.__importStar(require("./src/rules/nx-plugin-checks"));
const plugin = {
    configs: {},
    rules: {
        [enforce_module_boundaries_1.RULE_NAME]: enforce_module_boundaries_1.default,
        [nx_plugin_checks_1.RULE_NAME]: nx_plugin_checks_1.default,
        [dependency_checks_1.RULE_NAME]: dependency_checks_1.default,
        // Resolve any custom rules that might exist in the current workspace
        ...resolve_workspace_rules_1.workspaceRules,
    },
};
// ESM
exports.default = plugin;
// CommonJS
module.exports = plugin;

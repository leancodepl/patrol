"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.rules = exports.configs = void 0;
const tslib_1 = require("tslib");
const typescript_1 = tslib_1.__importDefault(require("./configs/typescript"));
const javascript_1 = tslib_1.__importDefault(require("./configs/javascript"));
const react_tmp_1 = tslib_1.__importDefault(require("./configs/react-tmp"));
const react_base_1 = tslib_1.__importDefault(require("./configs/react-base"));
const react_jsx_1 = tslib_1.__importDefault(require("./configs/react-jsx"));
const react_typescript_1 = tslib_1.__importDefault(require("./configs/react-typescript"));
const angular_1 = tslib_1.__importDefault(require("./configs/angular"));
const angular_template_1 = tslib_1.__importDefault(require("./configs/angular-template"));
const base_1 = tslib_1.__importDefault(require("./flat-configs/base"));
const enforce_module_boundaries_1 = tslib_1.__importStar(require("./rules/enforce-module-boundaries"));
const nx_plugin_checks_1 = tslib_1.__importStar(require("./rules/nx-plugin-checks"));
const dependency_checks_1 = tslib_1.__importStar(require("./rules/dependency-checks"));
// Resolve any custom rules that might exist in the current workspace
const resolve_workspace_rules_1 = require("./resolve-workspace-rules");
const configs = {
    // eslintrc configs
    typescript: typescript_1.default,
    javascript: javascript_1.default,
    react: react_tmp_1.default,
    'react-base': react_base_1.default,
    'react-typescript': react_typescript_1.default,
    'react-jsx': react_jsx_1.default,
    angular: angular_1.default,
    'angular-template': angular_template_1.default,
    // flat configs
    // Note: Using getters here to avoid importing packages `angular-eslint` statically, which can lead to errors if not installed.
    'flat/base': base_1.default,
    get ['flat/typescript']() {
        return require('./flat-configs/typescript').default;
    },
    get ['flat/javascript']() {
        return require('./flat-configs/javascript').default;
    },
    get ['flat/react']() {
        return require('./flat-configs/react-tmp').default;
    },
    get ['flat/react-base']() {
        return require('./flat-configs/react-base').default;
    },
    get ['flat/react-typescript']() {
        return require('./flat-configs/react-typescript').default;
    },
    get ['flat/react-jsx']() {
        return require('./flat-configs/react-jsx').default;
    },
    get ['flat/angular']() {
        return require('./flat-configs/angular').default;
    },
    get ['flat/angular-template']() {
        return require('./flat-configs/angular-template').default;
    },
};
exports.configs = configs;
const rules = {
    [enforce_module_boundaries_1.RULE_NAME]: enforce_module_boundaries_1.default,
    [nx_plugin_checks_1.RULE_NAME]: nx_plugin_checks_1.default,
    [dependency_checks_1.RULE_NAME]: dependency_checks_1.default,
    ...resolve_workspace_rules_1.workspaceRules,
};
exports.rules = rules;
exports.default = { configs, rules };

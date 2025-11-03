"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const angular_eslint_1 = tslib_1.__importDefault(require("angular-eslint"));
const globals_1 = tslib_1.__importDefault(require("globals"));
const typescript_eslint_1 = tslib_1.__importDefault(require("typescript-eslint"));
/**
 * This configuration is intended to be applied to ALL .ts files in Angular
 * projects within an Nx workspace.
 *
 * It should therefore NOT contain any rules or plugins which are related to
 * Angular Templates, or more cross-cutting concerns which are not specific
 * to Angular.
 *
 * This configuration is intended to be combined with other configs from this
 * package.
 */
const config = typescript_eslint_1.default.config(...angular_eslint_1.default.configs.tsRecommended.map((c) => ({
    // Files need to be specified or else typescript-eslint rules will be
    // applied to non-TS files. For example, buildable/publishable libs
    // add rules to *.json files, and TS rules should not apply to them.
    // See: https://github.com/nrwl/nx/issues/28069
    files: ['**/*.ts'],
    ...c,
})), {
    languageOptions: {
        globals: {
            ...globals_1.default.browser,
            ...globals_1.default.es2015,
            ...globals_1.default.node,
        },
    },
    processor: angular_eslint_1.default.processInlineTemplates,
    plugins: { '@angular-eslint': angular_eslint_1.default.tsPlugin },
});
exports.default = config;

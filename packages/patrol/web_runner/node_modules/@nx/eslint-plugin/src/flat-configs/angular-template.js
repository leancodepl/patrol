"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const angular_eslint_1 = tslib_1.__importDefault(require("angular-eslint"));
const typescript_eslint_1 = tslib_1.__importDefault(require("typescript-eslint"));
/**
 * This configuration is intended to be applied to ALL .html files in Angular
 * projects within an Nx workspace, as well as extracted inline templates from
 * .component.ts files (or similar).
 *
 * It should therefore NOT contain any rules or plugins which are related to
 * Angular source code.
 *
 * NOTE: The processor to extract the inline templates is applied in users'
 * configs by the relevant schematic.
 *
 * This configuration is intended to be combined with other configs from this
 * package.
 */
const config = typescript_eslint_1.default.config({
    files: ['**/*.html'],
    extends: [
        ...angular_eslint_1.default.configs.templateRecommended,
        ...angular_eslint_1.default.configs.templateAccessibility,
    ],
    rules: {},
});
exports.default = config;

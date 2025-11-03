"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const typescript_eslint_1 = tslib_1.__importDefault(require("typescript-eslint"));
const react_base_1 = tslib_1.__importDefault(require("./react-base"));
const react_typescript_1 = tslib_1.__importDefault(require("./react-typescript"));
const react_jsx_1 = tslib_1.__importDefault(require("./react-jsx"));
/**
 * THIS IS A TEMPORARY CONFIG WHICH MATCHES THE CURRENT BEHAVIOR
 * of including all the rules for all file types within the ESLint
 * config for React projects.
 *
 * It will be refactored in a follow up PR to correctly apply rules
 * to the right file types via overrides.
 */
const config = typescript_eslint_1.default.config(...react_base_1.default, ...react_typescript_1.default, ...react_jsx_1.default);
exports.default = config;

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const angular_1 = tslib_1.__importDefault(require("./src/flat-configs/angular"));
const angular_template_1 = tslib_1.__importDefault(require("./src/flat-configs/angular-template"));
const plugin = {
    configs: {
        angular: angular_1.default,
        'angular-template': angular_template_1.default,
    },
    rules: {},
};
// ESM
exports.default = plugin;
// CommonJS
module.exports = plugin;

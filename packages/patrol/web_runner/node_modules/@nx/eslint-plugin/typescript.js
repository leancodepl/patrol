"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const javascript_1 = tslib_1.__importDefault(require("./src/flat-configs/javascript"));
const typescript_1 = tslib_1.__importDefault(require("./src/flat-configs/typescript"));
const plugin = {
    configs: {
        javascript: javascript_1.default,
        typescript: typescript_1.default,
    },
    rules: {},
};
// ESM
exports.default = plugin;
// CommonJS
module.exports = plugin;

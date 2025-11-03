"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const react_base_1 = tslib_1.__importDefault(require("./src/flat-configs/react-base"));
const react_jsx_1 = tslib_1.__importDefault(require("./src/flat-configs/react-jsx"));
const react_tmp_1 = tslib_1.__importDefault(require("./src/flat-configs/react-tmp"));
const react_typescript_1 = tslib_1.__importDefault(require("./src/flat-configs/react-typescript"));
const plugin = {
    configs: {
        react: react_tmp_1.default,
        'react-base': react_base_1.default,
        'react-typescript': react_typescript_1.default,
        'react-jsx': react_jsx_1.default,
    },
    rules: {},
};
// ESM
exports.default = plugin;
// CommonJS
module.exports = plugin;

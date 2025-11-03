"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getNeededCompilerOptionOverrides = getNeededCompilerOptionOverrides;
const path_1 = require("path");
const ensure_typescript_1 = require("./ensure-typescript");
const optionEnumTypeMap = {
    importsNotUsedAsValues: 'ImportsNotUsedAsValues',
    jsx: 'JsxEmit',
    module: 'ModuleKind',
    moduleDetection: 'ModuleDetectionKind',
    moduleResolution: 'ModuleResolutionKind',
    newLine: 'NewLineKind',
    target: 'ScriptTarget',
};
let ts;
/**
 * Cleans up the provided compiler options to only include the options that are
 * different or not set in the provided tsconfig file.
 */
function getNeededCompilerOptionOverrides(tree, compilerOptions, tsConfigPath) {
    if (!ts) {
        ts = (0, ensure_typescript_1.ensureTypescript)();
    }
    const tsSysFromTree = {
        ...ts.sys,
        readFile: (path) => tree.read(path, 'utf-8'),
    };
    const parsed = ts.parseJsonConfigFileContent(ts.readConfigFile(tsConfigPath, tsSysFromTree.readFile).config, tsSysFromTree, (0, path_1.dirname)(tsConfigPath));
    // ModuleKind: { CommonJS: 'commonjs', ... } => ModuleKind: { commonjs: 'CommonJS', ... }
    const reversedCompilerOptionsEnumValues = {
        JsxEmit: reverseEnum(ts.server.protocol.JsxEmit),
        ModuleKind: reverseEnum(ts.server.protocol.ModuleKind),
        ModuleResolutionKind: reverseEnum(ts.server.protocol.ModuleResolutionKind),
        NewLineKind: reverseEnum(ts.server.protocol.NewLineKind),
        ScriptTarget: reverseEnum(ts.server.protocol.ScriptTarget),
    };
    const matchesValue = (key) => {
        return (parsed.options[key] ===
            ts[optionEnumTypeMap[key]][compilerOptions[key]] ||
            parsed.options[key] ===
                ts[optionEnumTypeMap[key]][reversedCompilerOptionsEnumValues[optionEnumTypeMap[key]][compilerOptions[key]]]);
    };
    let result = {};
    for (const key of Object.keys(compilerOptions)) {
        if (optionEnumTypeMap[key]) {
            if (parsed.options[key] === undefined) {
                result[key] = compilerOptions[key];
            }
            else if (!matchesValue(key)) {
                result[key] = compilerOptions[key];
            }
        }
        else if (parsed.options[key] !== compilerOptions[key]) {
            result[key] = compilerOptions[key];
        }
    }
    return result;
}
function reverseEnum(enumObj) {
    return Object.keys(enumObj).reduce((acc, key) => {
        acc[enumObj[key]] = key;
        return acc;
    }, {});
}

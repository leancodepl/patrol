"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.detectModuleFormat = detectModuleFormat;
const devkit_1 = require("@nx/devkit");
const fs_1 = require("fs");
const path_1 = require("path");
const ts_config_1 = require("../../../utils/typescript/ts-config");
const ts = require("typescript");
function detectModuleFormat(options) {
    if (options.buildOptions?.format) {
        const formats = Array.isArray(options.buildOptions.format)
            ? options.buildOptions.format
            : [options.buildOptions.format];
        if (formats.includes('esm')) {
            return 'esm';
        }
        if (formats.includes('cjs')) {
            return 'cjs';
        }
    }
    if (options.main.endsWith('.mjs')) {
        return 'esm';
    }
    if (options.main.endsWith('.cjs')) {
        return 'cjs';
    }
    const packageJsonPath = (0, path_1.join)(options.workspaceRoot, options.projectRoot, 'package.json');
    if ((0, fs_1.existsSync)(packageJsonPath)) {
        try {
            const packageJson = (0, devkit_1.readJsonFile)(packageJsonPath);
            if (packageJson.type === 'module') {
                return 'esm';
            }
            if (packageJson.type === 'commonjs') {
                return 'cjs';
            }
        }
        catch {
            // Continue to next detection method
        }
    }
    if (options.tsConfig && (0, fs_1.existsSync)(options.tsConfig)) {
        try {
            const tsConfig = (0, ts_config_1.readTsConfig)(options.tsConfig);
            if (tsConfig.options.module === ts.ModuleKind.ES2015 ||
                tsConfig.options.module === ts.ModuleKind.ES2020 ||
                tsConfig.options.module === ts.ModuleKind.ES2022 ||
                tsConfig.options.module === ts.ModuleKind.ESNext ||
                tsConfig.options.module === ts.ModuleKind.NodeNext) {
                // For NodeNext, we need to check moduleResolution
                if (tsConfig.options.module === ts.ModuleKind.NodeNext) {
                    // NodeNext uses package.json type field, which we already checked
                    // Default to CJS if no type field
                    return 'cjs';
                }
                return 'esm';
            }
        }
        catch {
            // Continue to default
        }
    }
    return 'cjs';
}

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = default_1;
const devkit_1 = require("@nx/devkit");
const ts_solution_setup_1 = require("../../utils/typescript/ts-solution-setup");
async function default_1(tree) {
    if (!isDevelopmentCustomConditionDefined(tree)) {
        return;
    }
    const packageJsonFiles = await getPackageJsonFiles(tree);
    if (!(await doDevelopmentExportsPointToTsFiles(tree, packageJsonFiles))) {
        return;
    }
    // Get the new custom condition name
    const newCustomCondition = (0, ts_solution_setup_1.getCustomConditionName)(tree, {
        skipDevelopmentFallback: true,
    });
    updateTsconfigBaseCustomCondition(tree, newCustomCondition);
    await updatePackageJsonExports(tree, newCustomCondition, packageJsonFiles);
    await (0, devkit_1.formatFiles)(tree);
}
/**
 * Check if the development custom condition is defined in the repo:
 * - Both tsconfig.base.json and tsconfig.json exist
 * - customConditions is set in tsconfig.base.json
 * - There's a single custom condition and it's named 'development'
 */
function isDevelopmentCustomConditionDefined(tree) {
    if (!tree.exists('tsconfig.base.json') || !tree.exists('tsconfig.json')) {
        // if any of them don't exist, it means the repo is not using or has deviated
        // from the TS solution setup, let's leave things as is
        return false;
    }
    const tsconfigBase = (0, devkit_1.readJson)(tree, 'tsconfig.base.json');
    const customConditions = tsconfigBase.compilerOptions?.customConditions;
    if (!Array.isArray(customConditions) ||
        customConditions.length !== 1 ||
        customConditions[0] !== 'development') {
        // no custom conditions, or more than one, or not named 'development', this
        // means the repo is not using or has deviated from the TS solution setup
        return false;
    }
    return true;
}
/**
 * Validate that all 'development' conditional exports in workspace package.json files
 * point to TypeScript files (.ts, .tsx, .mts, .cts)
 */
async function doDevelopmentExportsPointToTsFiles(tree, packageJsonFiles) {
    for (const filePath of packageJsonFiles) {
        try {
            const packageJson = (0, devkit_1.readJson)(tree, filePath);
            if (!packageJson.exports || typeof packageJson.exports !== 'object') {
                continue;
            }
            if (!checkExportsRecursively(packageJson.exports)) {
                return false;
            }
        }
        catch {
            continue;
        }
    }
    return true;
}
/**
 * Check if the `development` conditional exports in the package.json file
 * point to TS files.
 */
function checkExportsRecursively(exports) {
    if (typeof exports !== 'object' ||
        exports === null ||
        Array.isArray(exports)) {
        // there's no conditional exports, so we're good
        return true;
    }
    for (const [key, value] of Object.entries(exports)) {
        if (key === 'development') {
            // check if the development export points to a TS file
            if (typeof value !== 'string' || !isTypeScriptFile(value)) {
                return false;
            }
        }
        else {
            // recursively check nested objects
            if (!checkExportsRecursively(value)) {
                return false;
            }
        }
    }
    return true;
}
function isTypeScriptFile(filePath) {
    return /\.m?ts$|\.tsx$|\.cts$/.test(filePath);
}
function updateTsconfigBaseCustomCondition(tree, newCustomCondition) {
    (0, devkit_1.updateJson)(tree, 'tsconfig.base.json', (json) => {
        json.compilerOptions.customConditions =
            json.compilerOptions.customConditions.map((condition) => condition === 'development' ? newCustomCondition : condition);
        return json;
    });
}
async function updatePackageJsonExports(tree, newCustomCondition, packageJsonFiles) {
    for (const filePath of packageJsonFiles) {
        try {
            const packageJson = (0, devkit_1.readJson)(tree, filePath);
            if (!packageJson.exports || typeof packageJson.exports !== 'object') {
                continue;
            }
            const updatedExports = updateExportsRecursively(packageJson.exports, newCustomCondition);
            if (JSON.stringify(updatedExports) !== JSON.stringify(packageJson.exports)) {
                (0, devkit_1.updateJson)(tree, filePath, (json) => {
                    json.exports = updatedExports;
                    return json;
                });
                devkit_1.logger.info(`Updated exports in ${filePath}`);
            }
        }
        catch (error) {
            continue;
        }
    }
}
function updateExportsRecursively(exports, newCustomCondition) {
    if (typeof exports !== 'object' ||
        exports === null ||
        Array.isArray(exports)) {
        // no conditional exports, nothing to do
        return exports;
    }
    const updated = {};
    for (const [key, value] of Object.entries(exports)) {
        if (key === 'development') {
            // Replace 'development' key with new custom condition
            updated[newCustomCondition] = value;
        }
        else {
            // Recursively process nested objects
            updated[key] = updateExportsRecursively(value, newCustomCondition);
        }
    }
    return updated;
}
async function getPackageJsonFiles(tree) {
    const packageJsonFiles = await (0, devkit_1.globAsync)(tree, ['**/package.json']);
    return packageJsonFiles.filter((file) => file !== 'package.json');
}

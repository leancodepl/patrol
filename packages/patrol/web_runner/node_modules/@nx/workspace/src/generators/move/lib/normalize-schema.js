"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.normalizeSchema = normalizeSchema;
const devkit_1 = require("@nx/devkit");
const get_import_path_1 = require("../../../utilities/get-import-path");
const utils_1 = require("./utils");
const ts_solution_setup_1 = require("../../../utils/ts-solution-setup");
async function normalizeSchema(tree, schema, projectConfiguration) {
    const { destination, newProjectName, importPath } = await determineProjectNameAndRootOptions(tree, schema, projectConfiguration);
    const isNxConfiguredInPackageJson = !tree.exists((0, devkit_1.joinPathFragments)(projectConfiguration.root, 'project.json'));
    return {
        ...schema,
        destination: (0, utils_1.normalizePathSlashes)(schema.destination),
        importPath,
        newProjectName,
        relativeToRootDestination: destination,
        isNxConfiguredInPackageJson,
    };
}
async function determineProjectNameAndRootOptions(tree, options, projectConfiguration) {
    validateName(tree, options.newProjectName, projectConfiguration);
    let destination = (0, utils_1.normalizePathSlashes)(options.destination);
    if (options.newProjectName &&
        options.newProjectName.includes('/') &&
        !options.newProjectName.startsWith('@')) {
        throw new Error(`You can't specify a new project name with a directory path (${options.newProjectName}). ` +
            `Please provide a valid name without path segments and the full destination with the "--destination" option.`);
    }
    const newProjectName = options.newProjectName ?? options.projectName;
    if (projectConfiguration.projectType !== 'library') {
        return { destination, newProjectName };
    }
    let importPath = options.importPath;
    if (importPath) {
        return { destination, newProjectName, importPath };
    }
    if (options.newProjectName?.startsWith('@')) {
        // keep the existing import path if the name didn't change
        importPath =
            options.newProjectName && options.projectName !== options.newProjectName
                ? newProjectName
                : undefined;
    }
    else if (options.newProjectName) {
        const npmScope = (0, get_import_path_1.getNpmScope)(tree);
        importPath = npmScope
            ? `${npmScope === '@' ? '' : '@'}${npmScope}/${newProjectName}`
            : newProjectName;
    }
    return { destination, newProjectName, importPath };
}
function validateName(tree, name, projectConfiguration) {
    if (!name) {
        return;
    }
    /**
     * Matches two types of project names:
     *
     * 1. Valid npm package names (e.g., '@scope/name' or 'name').
     * 2. Names starting with a letter and can contain any character except whitespace and ':'.
     *
     * The second case is to support the legacy behavior (^[a-zA-Z].*$) with the difference
     * that it doesn't allow the ":" character. It was wrong to allow it because it would
     * conflict with the notation for tasks.
     */
    const libraryPattern = '(?:^@[a-zA-Z0-9-*~][a-zA-Z0-9-*._~]*\\/[a-zA-Z0-9-~][a-zA-Z0-9-._~]*|^[a-zA-Z][^:]*)$';
    const appPattern = '^[a-zA-Z][^:]*$';
    const projectType = (0, ts_solution_setup_1.getProjectType)(tree, projectConfiguration.root, projectConfiguration.projectType);
    if (projectType === 'application') {
        const validationRegex = new RegExp(appPattern);
        if (!validationRegex.test(name)) {
            throw new Error(`The new project name should match the pattern "${appPattern}". The provided value "${name}" does not match.`);
        }
    }
    else if ((0, ts_solution_setup_1.getProjectType)(tree, projectConfiguration.root, projectConfiguration.projectType) === 'library') {
        const validationRegex = new RegExp(libraryPattern);
        if (!validationRegex.test(name)) {
            throw new Error(`The new project name should match the pattern "${libraryPattern}". The provided value "${name}" does not match.`);
        }
    }
}

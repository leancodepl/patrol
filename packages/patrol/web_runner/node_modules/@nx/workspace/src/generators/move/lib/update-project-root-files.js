"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateProjectRootFiles = updateProjectRootFiles;
exports.updateFilesForRootProjects = updateFilesForRootProjects;
exports.updateFilesForNonRootProjects = updateFilesForNonRootProjects;
const devkit_1 = require("@nx/devkit");
const path = require("path");
const path_1 = require("path");
const allowedExt = ['.ts', '.js', '.json'];
/**
 * Updates the files in the root of the project
 *
 * Typically these are config files which point outside of the project folder
 *
 * @param schema The options provided to the schematic
 */
function updateProjectRootFiles(tree, schema, project) {
    if (project.root === '.') {
        // Need to handle root project differently since replacing '.' with 'dir',
        // for example, // will change '../../' to 'dirdir/dirdir/'.
        updateFilesForRootProjects(tree, schema, project);
    }
    else {
        updateFilesForNonRootProjects(tree, schema, project);
    }
}
function updateFilesForRootProjects(tree, schema, project) {
    // Skip updating "path" and "extends" for tsconfig files since they are mostly
    // relative to the project root. The only exception is tsconfig.json that
    // should extend from ../../tsconfig.base.json. We'll handle this separately.
    const regex = /(?<!"path".+)(?<!"extends".+)(?<=['"])\.\/(?=[a-zA-Z0-9])/g;
    const newRelativeRoot = 
    // Normalize separators
    path
        .relative(path.join(devkit_1.workspaceRoot, schema.relativeToRootDestination), devkit_1.workspaceRoot)
        .split(path.sep)
        // Include trailing slash because the regex matches the trailing slash in "./"
        .join('/') + '/';
    for (const file of tree.children(schema.relativeToRootDestination)) {
        const ext = (0, path_1.extname)(file);
        if (!allowedExt.includes(ext)) {
            continue;
        }
        if (file === '.eslintrc.json' ||
            file === 'eslint.config.js' ||
            file === 'eslint.config.cjs') {
            continue;
        }
        const oldContent = tree.read((0, path_1.join)(schema.relativeToRootDestination, file), 'utf-8');
        let newContent = oldContent.replace(regex, newRelativeRoot);
        if (file === 'tsconfig.json') {
            // Since we skipped updating "extends" earlier, need to point to the base config.
            newContent = newContent.replace(`./tsconfig.base.json`, newRelativeRoot + `tsconfig.base.json`);
        }
        tree.write((0, path_1.join)(schema.relativeToRootDestination, file), newContent);
    }
}
function updateFilesForNonRootProjects(tree, schema, project) {
    const newRelativeRoot = path
        .relative(path.join(devkit_1.workspaceRoot, schema.relativeToRootDestination), devkit_1.workspaceRoot)
        .split(path.sep)
        .join('/') + '/';
    const oldRelativeRoot = path
        .relative(path.join(devkit_1.workspaceRoot, project.root), devkit_1.workspaceRoot)
        .split(path.sep)
        .join('/');
    if (newRelativeRoot === oldRelativeRoot) {
        // nothing to do
        return;
    }
    const dots = /\./g;
    const regex = new RegExp(`(?<!\\.\\.\\/)${oldRelativeRoot.replace(dots, '\\.')}\/(?!\\.\\.\\/)`, 'g');
    for (const file of tree.children(schema.relativeToRootDestination)) {
        const ext = (0, path_1.extname)(file);
        if (!allowedExt.includes(ext)) {
            continue;
        }
        if (file === '.eslintrc.json' ||
            file === 'eslint.config.cjs' ||
            file === 'eslint.config.js') {
            continue;
        }
        const oldContent = tree.read((0, path_1.join)(schema.relativeToRootDestination, file), 'utf-8');
        let newContent = oldContent.replace(regex, newRelativeRoot);
        if (file == 'tsconfig.json') {
            newContent = newContent.replace('tsconfig.json', 'tsconfig.base.json');
        }
        tree.write((0, path_1.join)(schema.relativeToRootDestination, file), newContent);
    }
}

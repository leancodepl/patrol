"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.npmPackageGenerator = npmPackageGenerator;
const devkit_1 = require("@nx/devkit");
const project_name_and_root_utils_1 = require("@nx/devkit/src/generators/project-name-and-root-utils");
const path_1 = require("path");
async function normalizeOptions(tree, options) {
    await (0, project_name_and_root_utils_1.ensureRootProjectName)(options, 'library');
    const { projectName, projectRoot, importPath } = await (0, project_name_and_root_utils_1.determineProjectNameAndRootOptions)(tree, {
        name: options.name,
        projectType: 'library',
        directory: options.directory,
    });
    return {
        ...options,
        name: projectName,
        projectRoot,
        importPath,
    };
}
function addFiles(projectRoot, tree, options) {
    const packageJsonPath = (0, path_1.join)(projectRoot, 'package.json');
    (0, devkit_1.writeJson)(tree, packageJsonPath, {
        name: options.importPath,
        version: '0.0.0',
        exports: {
            '.': './index.js',
            './package.json': './package.json',
        },
        scripts: {
            test: 'node index.js',
        },
    });
    (0, devkit_1.generateFiles)(tree, (0, path_1.join)(__dirname, './files'), projectRoot, {});
}
async function npmPackageGenerator(tree, _options) {
    const options = await normalizeOptions(tree, _options);
    (0, devkit_1.addProjectConfiguration)(tree, options.name, {
        root: options.projectRoot,
    });
    const fileCount = tree.children(options.projectRoot).length;
    const projectJsonExists = tree.exists((0, path_1.join)(options.projectRoot, 'project.json'));
    const isEmpty = fileCount === 0 || (fileCount === 1 && projectJsonExists);
    if (isEmpty) {
        addFiles(options.projectRoot, tree, options);
    }
    await (0, devkit_1.formatFiles)(tree);
}

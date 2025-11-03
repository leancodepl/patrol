"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateImports = updateImports;
const devkit_1 = require("@nx/devkit");
const path_1 = require("path");
const get_import_path_1 = require("../../../utilities/get-import-path");
const ts_config_1 = require("../../../utilities/ts-config");
const typescript_1 = require("../../../utilities/typescript");
const utils_1 = require("./utils");
const ts_solution_setup_1 = require("../../../utilities/typescript/ts-solution-setup");
const project_config_1 = require("../../utils/project-config");
let tsModule;
/**
 * Updates all the imports in the workspace and modifies the tsconfig appropriately.
 *
 * @param schema The options provided to the schematic
 */
function updateImports(tree, schema, project) {
    if (project.projectType !== 'library') {
        return;
    }
    const { libsDir } = (0, devkit_1.getWorkspaceLayout)(tree);
    const projects = (0, devkit_1.getProjects)(tree);
    const isUsingTsSolution = (0, ts_solution_setup_1.isUsingTsSolutionSetup)(tree);
    // use the source root to find the from location
    // this attempts to account for libs that have been created with --importPath
    const tsConfigPath = isUsingTsSolution
        ? 'tsconfig.json'
        : (0, ts_config_1.getRootTsConfigPathInTree)(tree);
    // If we are using a ts solution setup, we need to use tsconfig.json instead of tsconfig.base.json
    let tsConfig;
    let mainEntryPointImportPath;
    let secondaryEntryPointImportPaths;
    let serverEntryPointImportPath;
    if (tree.exists(tsConfigPath)) {
        tsConfig = (0, devkit_1.readJson)(tree, tsConfigPath);
        const sourceRoot = (0, project_config_1.getProjectSourceRoot)(project, tree);
        mainEntryPointImportPath = Object.keys(tsConfig.compilerOptions?.paths ?? {}).find((path) => tsConfig.compilerOptions.paths[path].some((x) => x.startsWith(ensureTrailingSlash(sourceRoot))));
        secondaryEntryPointImportPaths = Object.keys(tsConfig.compilerOptions?.paths ?? {}).filter((path) => tsConfig.compilerOptions.paths[path].some((x) => x.startsWith(ensureTrailingSlash(project.root)) &&
            !x.startsWith(ensureTrailingSlash(sourceRoot))));
        // Next.js libs have a custom path for the server we need to update that as well
        // example "paths": { @acme/lib/server : ['libs/lib/src/server.ts'] }
        serverEntryPointImportPath = Object.keys(tsConfig.compilerOptions?.paths ?? {}).find((path) => tsConfig.compilerOptions.paths[path].some((x) => x.startsWith(ensureTrailingSlash(sourceRoot)) &&
            x.includes('server') &&
            path.endsWith('server')));
    }
    mainEntryPointImportPath ??= (0, utils_1.normalizePathSlashes)((0, get_import_path_1.getImportPath)(tree, project.root.slice(libsDir.length).replace(/^\/|\\/, '')));
    const projectRefs = [
        {
            from: mainEntryPointImportPath,
            to: schema.importPath,
        },
        ...(secondaryEntryPointImportPaths
            ? secondaryEntryPointImportPaths.map((p) => ({
                from: p,
                // if the import path doesn't start with the main entry point import path,
                // it's a custom import path we don't know how to update the name, we keep
                // it as-is, but we'll update the path it points to
                to: schema.importPath && p.startsWith(mainEntryPointImportPath)
                    ? p.replace(mainEntryPointImportPath, schema.importPath)
                    : null,
            }))
            : []),
    ];
    if (serverEntryPointImportPath &&
        schema.importPath &&
        serverEntryPointImportPath.startsWith(mainEntryPointImportPath)) {
        projectRefs.push({
            from: serverEntryPointImportPath,
            to: serverEntryPointImportPath.replace(mainEntryPointImportPath, schema.importPath),
        });
    }
    for (const projectRef of projectRefs) {
        if (schema.updateImportPath && projectRef.to) {
            const replaceProjectRef = new RegExp(projectRef.from, 'g');
            for (const [name, definition] of Array.from(projects.entries())) {
                if (name === schema.projectName) {
                    continue;
                }
                (0, devkit_1.visitNotIgnoredFiles)(tree, definition.root, (file) => {
                    const contents = tree.read(file, 'utf-8');
                    replaceProjectRef.lastIndex = 0;
                    if (!replaceProjectRef.test(contents)) {
                        return;
                    }
                    updateImportPaths(tree, file, projectRef.from, projectRef.to);
                });
            }
        }
        const projectRoot = {
            from: project.root,
            to: schema.relativeToRootDestination,
        };
        if (tsConfig) {
            if (!isUsingTsSolution) {
                updateTsConfigPaths(tsConfig, projectRef, tsConfigPath, projectRoot, schema);
            }
            else {
                updateTsConfigReferences(tsConfig, projectRoot, tsConfigPath, schema);
            }
            (0, devkit_1.writeJson)(tree, tsConfigPath, tsConfig);
        }
    }
}
function updateTsConfigReferences(tsConfig, projectRoot, tsConfigPath, schema) {
    // Since paths can be './path' or 'path' we check if both are the same relative path to the workspace root
    const projectRefIndex = tsConfig.references.findIndex((ref) => (0, path_1.relative)(ref.path, projectRoot.from) === '');
    if (projectRefIndex === -1) {
        throw new Error(`unable to find "${projectRoot.from}" in ${tsConfigPath} references`);
    }
    const updatedPath = (0, devkit_1.joinPathFragments)(projectRoot.to, (0, path_1.relative)(projectRoot.from, tsConfig.references[projectRefIndex].path));
    let normalizedPath = (0, path_1.normalize)(updatedPath);
    if (!normalizedPath.startsWith('.') &&
        !normalizedPath.startsWith('../') &&
        !(0, path_1.isAbsolute)(normalizedPath)) {
        normalizedPath = `./${normalizedPath}`;
    }
    if (schema.updateImportPath && projectRoot.to) {
        tsConfig.references[projectRefIndex].path = normalizedPath;
    }
    else {
        tsConfig.references.push({ path: normalizedPath });
    }
}
function updateTsConfigPaths(tsConfig, projectRef, tsConfigPath, projectRoot, schema) {
    const path = tsConfig.compilerOptions.paths[projectRef.from];
    if (!path) {
        throw new Error([
            `unable to find "${projectRef.from}" in`,
            `${tsConfigPath} compilerOptions.paths`,
        ].join(' '));
    }
    const updatedPath = path.map((x) => (0, devkit_1.joinPathFragments)(projectRoot.to, (0, path_1.relative)(projectRoot.from, x)));
    if (schema.updateImportPath && projectRef.to) {
        tsConfig.compilerOptions.paths[projectRef.to] = updatedPath;
        if (projectRef.from !== projectRef.to) {
            delete tsConfig.compilerOptions.paths[projectRef.from];
        }
    }
    else {
        tsConfig.compilerOptions.paths[projectRef.from] = updatedPath;
    }
}
function ensureTrailingSlash(path) {
    return path.endsWith('/') ? path : `${path}/`;
}
/**
 * Changes imports in a file from one import to another
 */
function updateImportPaths(tree, path, from, to) {
    if (!tsModule) {
        tsModule = (0, typescript_1.ensureTypescript)();
    }
    const contents = tree.read(path, 'utf-8');
    const sourceFile = tsModule.createSourceFile(path, contents, tsModule.ScriptTarget.Latest, true);
    // Apply changes on the various types of imports
    const newContents = (0, devkit_1.applyChangesToString)(contents, [
        ...updateImportDeclarations(sourceFile, from, to),
        ...updateDynamicImports(sourceFile, from, to),
    ]);
    tree.write(path, newContents);
}
/**
 * Update the module specifiers on static imports
 */
function updateImportDeclarations(sourceFile, from, to) {
    if (!tsModule) {
        tsModule = (0, typescript_1.ensureTypescript)();
    }
    const importDecls = (0, ts_config_1.findNodes)(sourceFile, [
        tsModule.SyntaxKind.ImportDeclaration,
        tsModule.SyntaxKind.ExportDeclaration,
    ]);
    const changes = [];
    for (const { moduleSpecifier } of importDecls) {
        if (moduleSpecifier && tsModule.isStringLiteral(moduleSpecifier)) {
            changes.push(...updateModuleSpecifier(moduleSpecifier, from, to));
        }
    }
    return changes;
}
/**
 * Update the module specifiers on dynamic imports and require statements
 */
function updateDynamicImports(sourceFile, from, to) {
    if (!tsModule) {
        tsModule = (0, typescript_1.ensureTypescript)();
    }
    const expressions = (0, ts_config_1.findNodes)(sourceFile, tsModule.SyntaxKind.CallExpression);
    const changes = [];
    for (const { expression, arguments: args } of expressions) {
        const moduleSpecifier = args[0];
        // handle dynamic import statements
        if (expression.kind === tsModule.SyntaxKind.ImportKeyword &&
            moduleSpecifier &&
            tsModule.isStringLiteral(moduleSpecifier)) {
            changes.push(...updateModuleSpecifier(moduleSpecifier, from, to));
        }
        // handle require statements
        if (tsModule.isIdentifier(expression) &&
            expression.text === 'require' &&
            moduleSpecifier &&
            tsModule.isStringLiteral(moduleSpecifier)) {
            changes.push(...updateModuleSpecifier(moduleSpecifier, from, to));
        }
    }
    return changes;
}
/**
 * Replace the old module specifier with a the new path
 */
function updateModuleSpecifier(moduleSpecifier, from, to) {
    if (moduleSpecifier.text === from ||
        moduleSpecifier.text.startsWith(`${from}/`)) {
        return [
            {
                type: devkit_1.ChangeType.Delete,
                start: moduleSpecifier.getStart() + 1,
                length: moduleSpecifier.text.length,
            },
            {
                type: devkit_1.ChangeType.Insert,
                index: moduleSpecifier.getStart() + 1,
                text: moduleSpecifier.text.replace(new RegExp(from, 'g'), to),
            },
        ];
    }
    else {
        return [];
    }
}

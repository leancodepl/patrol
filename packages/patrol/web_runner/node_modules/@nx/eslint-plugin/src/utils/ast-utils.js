"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getBarrelEntryPointByImportScope = getBarrelEntryPointByImportScope;
exports.getBarrelEntryPointProjectNode = getBarrelEntryPointProjectNode;
exports.getRelativeImportPath = getRelativeImportPath;
const devkit_1 = require("@nx/devkit");
const js_1 = require("@nx/js");
const ts_solution_setup_1 = require("@nx/js/src/utils/typescript/ts-solution-setup");
const type_utils_1 = require("@typescript-eslint/type-utils");
const fs_1 = require("fs");
const path_1 = require("path");
const ts = require("typescript");
function tryReadBaseJson() {
    try {
        return (0, devkit_1.readJsonFile)((0, path_1.join)(devkit_1.workspaceRoot, 'tsconfig.base.json'));
    }
    catch (e) {
        devkit_1.logger.warn(`Error reading "tsconfig.base.json": \n${JSON.stringify(e)}`);
        return null;
    }
}
/**
 *
 * @param importScope like `@myorg/somelib`
 * @returns
 */
function getBarrelEntryPointByImportScope(importScope) {
    const tryPaths = (paths, importScope) => {
        // TODO check and warn that the entries of paths[importScope] have no wildcards; that'd be user misconfiguration
        if (paths[importScope])
            return paths[importScope];
        // accommodate wildcards (it's not glob) https://www.typescriptlang.org/docs/handbook/module-resolution.html#path-mapping
        const result = new Set(); // set ensures there are no duplicates
        for (const [alias, targets] of Object.entries(paths)) {
            if (!alias.endsWith('*')) {
                continue;
            }
            const strippedAlias = alias.slice(0, -1); // remove asterisk
            if (!importScope.startsWith(strippedAlias)) {
                continue;
            }
            const dynamicPart = importScope.slice(strippedAlias.length);
            targets.forEach((target) => {
                result.add(target.replace('*', dynamicPart)); // add interpolated value
            });
            // we found the entry for importScope; an import scope not supposed and has no sense having > 1 Aliases; TODO warn on duplicated entries
            break;
        }
        return Array.from(result);
    };
    const tsConfigBase = tryReadBaseJson();
    if (!tsConfigBase?.compilerOptions?.paths)
        return [];
    return tryPaths(tsConfigBase.compilerOptions.paths, importScope);
}
function getBarrelEntryPointProjectNode(projectNode) {
    const tsConfigBase = tryReadBaseJson();
    if (tsConfigBase?.compilerOptions?.paths) {
        const potentialEntryPoints = Object.keys(tsConfigBase.compilerOptions.paths)
            .filter((entry) => {
            const sourceFolderPaths = tsConfigBase.compilerOptions.paths[entry];
            return sourceFolderPaths.some((sourceFolderPath) => {
                const sourceRoot = (0, ts_solution_setup_1.getProjectSourceRoot)(projectNode.data);
                return (sourceFolderPath === sourceRoot ||
                    sourceFolderPath.indexOf(`${sourceRoot}/`) === 0);
            });
        })
            .map((entry) => tsConfigBase.compilerOptions.paths[entry].map((x) => ({
            path: x,
            importScope: entry,
        })));
        return potentialEntryPoints.flat();
    }
    return null;
}
function hasMemberExport(exportedMember, filePath) {
    const fileContent = (0, fs_1.readFileSync)(filePath, 'utf8');
    // use the TypeScript AST to find the path to the file where exportedMember is defined
    const sourceFile = ts.createSourceFile(filePath, fileContent, ts.ScriptTarget.Latest, true);
    // search whether there is already an export with our node
    return ((0, js_1.findNodes)(sourceFile, ts.SyntaxKind.Identifier).filter((identifier) => identifier.text === exportedMember).length > 0);
}
function getRelativeImportPath(exportedMember, filePath) {
    const status = (0, fs_1.lstatSync)(filePath, {
        throwIfNoEntry: false,
    });
    if (!status /*not existed, but probably not full file with an extension*/) {
        // try to find an extension that exists
        const ext = ['.ts', '.tsx', '.js', '.jsx'].find((ext) => (0, fs_1.lstatSync)(filePath + ext, { throwIfNoEntry: false }));
        if (ext) {
            filePath += ext;
        }
    }
    else if (status.isDirectory()) {
        const file = (0, fs_1.readdirSync)(filePath).find((file) => /^index\.[jt]sx?$/.exec(file));
        if (file) {
            filePath = (0, path_1.join)(filePath, file);
        }
        else {
            return;
        }
    }
    const fileContent = (0, fs_1.readFileSync)(filePath, 'utf8');
    // use the TypeScript AST to find the path to the file where exportedMember is defined
    const sourceFile = ts.createSourceFile(filePath, fileContent, ts.ScriptTarget.Latest, true);
    // Search in the current file whether there's an export already!
    const memberNodes = (0, js_1.findNodes)(sourceFile, ts.SyntaxKind.Identifier).filter((identifier) => identifier.text === exportedMember);
    let hasExport = false;
    for (const memberNode of memberNodes || []) {
        if (memberNode) {
            // recursively navigate upwards to find the ExportKey modifier
            let parent = memberNode;
            do {
                parent = parent.parent;
                if (parent) {
                    // if we are inside a parameter list or decorator or param assignment
                    // then this is not what we're searching for, so break :)
                    if (parent.kind === ts.SyntaxKind.Parameter ||
                        parent.kind === ts.SyntaxKind.PropertyAccessExpression ||
                        parent.kind === ts.SyntaxKind.TypeReference ||
                        parent.kind === ts.SyntaxKind.HeritageClause ||
                        parent.kind === ts.SyntaxKind.Decorator) {
                        hasExport = false;
                        break;
                    }
                    // if our identifier is within an ExportDeclaration but is not just
                    // a re-export of some other module, we're good
                    if (parent.kind === ts.SyntaxKind.ExportDeclaration &&
                        !parent.moduleSpecifier) {
                        hasExport = true;
                        break;
                    }
                    if ((0, type_utils_1.getModifiers)(parent)?.find((modifier) => modifier.kind === ts.SyntaxKind.ExportKeyword)) {
                        /**
                         * if we get to a function export declaration we need to verify whether the
                         * exported function is actually the member we are searching for. Otherwise
                         * we might end up finding a function that just uses our searched identifier
                         * internally.
                         *
                         * Example: assume we try to find a constant member: `export const SOME_CONSTANT = 'bla'`
                         *
                         * Then we might end up in a file that uses it like
                         *
                         * import { SOME_CONSTANT } from '@myorg/samelib'
                         *
                         * export function someFunction() {
                         *  return `Hi, ${SOME_CONSTANT}`
                         * }
                         *
                         * We want to avoid accidentally picking the someFunction export since we're searching upwards
                         * starting from `SOME_CONSTANT` identifier usages.
                         */
                        if (parent.kind === ts.SyntaxKind.FunctionDeclaration) {
                            const parentName = parent.name?.text;
                            if (parentName === exportedMember) {
                                hasExport = true;
                                break;
                            }
                        }
                        else {
                            hasExport = true;
                            break;
                        }
                    }
                }
            } while (!!parent);
        }
        if (hasExport) {
            break;
        }
    }
    if (hasExport) {
        // we found the file, now grab the path
        return filePath;
    }
    // if we didn't find an export, let's try to follow
    // all export declarations and see whether any of those
    // exports the node we're searching for
    const exportDeclarations = (0, js_1.findNodes)(sourceFile, ts.SyntaxKind.ExportDeclaration);
    for (const exportDeclaration of exportDeclarations) {
        if (exportDeclaration.moduleSpecifier) {
            // verify whether the export declaration we're looking at is a named export
            // cause in that case we need to check whether our searched member is
            // part of the exports
            if (exportDeclaration.exportClause &&
                (0, js_1.findNodes)(exportDeclaration, ts.SyntaxKind.Identifier).filter((identifier) => identifier.text === exportedMember).length === 0) {
                continue;
            }
            const modulePath = exportDeclaration.moduleSpecifier.text;
            let moduleFilePath;
            if (modulePath.endsWith('.js') || modulePath.endsWith('.jsx')) {
                moduleFilePath = (0, path_1.join)((0, path_1.dirname)(filePath), modulePath);
                if (!(0, fs_1.existsSync)(moduleFilePath)) {
                    const tsifiedModulePath = modulePath.replace(/\.js(x?)$/, '.ts$1');
                    moduleFilePath = (0, path_1.join)((0, path_1.dirname)(filePath), `${tsifiedModulePath}`);
                }
            }
            else if (modulePath.endsWith('.ts') || modulePath.endsWith('.tsx')) {
                moduleFilePath = (0, path_1.join)((0, path_1.dirname)(filePath), modulePath);
            }
            else {
                moduleFilePath = (0, path_1.join)((0, path_1.dirname)(filePath), `${modulePath}.ts`);
                if (!(0, fs_1.existsSync)(moduleFilePath)) {
                    // might be a tsx file
                    moduleFilePath = (0, path_1.join)((0, path_1.dirname)(filePath), `${modulePath}.tsx`);
                }
            }
            if (!(0, fs_1.existsSync)(moduleFilePath)) {
                // might be an index.ts
                moduleFilePath = (0, path_1.join)((0, path_1.dirname)(filePath), `${modulePath}/index.ts`);
            }
            if (hasMemberExport(exportedMember, moduleFilePath)) {
                const foundFilePath = getRelativeImportPath(exportedMember, moduleFilePath);
                if (foundFilePath) {
                    return foundFilePath;
                }
            }
        }
    }
    return null;
}

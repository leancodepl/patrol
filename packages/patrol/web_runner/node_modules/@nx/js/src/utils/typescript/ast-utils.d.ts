import type { Tree } from '@nx/devkit';
import type * as ts from 'typescript';
import { Node, SyntaxKind } from 'typescript';
/**
 * Find a module based on its import
 *
 * @param importExpr Import used to resolve to a module
 * @param filePath
 * @param tsConfigPath
 */
export declare function resolveModuleByImport(importExpr: string, filePath: string, tsConfigPath: string): string;
export declare function insertChange(host: Tree, sourceFile: ts.SourceFile, filePath: string, insertPosition: number, contentToInsert: string): ts.SourceFile;
export declare function replaceChange(host: Tree, sourceFile: ts.SourceFile, filePath: string, insertPosition: number, contentToInsert: string, oldContent: string): ts.SourceFile;
export declare function removeChange(host: Tree, sourceFile: ts.SourceFile, filePath: string, removePosition: number, contentToRemove: string): ts.SourceFile;
export declare function insertImport(host: Tree, source: ts.SourceFile, fileToEdit: string, symbolName: string, fileName: string, isDefault?: boolean): ts.SourceFile;
export declare function addGlobal(host: Tree, source: ts.SourceFile, modulePath: string, statement: string): ts.SourceFile;
export declare function getImport(source: ts.SourceFile, predicate: (a: any) => boolean): {
    moduleSpec: string;
    bindings: string[];
}[];
export declare function replaceNodeValue(host: Tree, sourceFile: ts.SourceFile, modulePath: string, node: ts.Node, content: string): ts.SourceFile;
export declare function addParameterToConstructor(tree: Tree, source: ts.SourceFile, modulePath: string, opts: {
    className: string;
    param: string;
}): ts.SourceFile;
export declare function addMethod(tree: Tree, source: ts.SourceFile, modulePath: string, opts: {
    className: string;
    methodHeader: string;
    body?: string;
}): ts.SourceFile;
export declare function findClass(source: ts.SourceFile, className: string, silent?: boolean): ts.ClassDeclaration;
export declare function findNodes(node: Node, kind: SyntaxKind | SyntaxKind[], max?: number): Node[];
//# sourceMappingURL=ast-utils.d.ts.map
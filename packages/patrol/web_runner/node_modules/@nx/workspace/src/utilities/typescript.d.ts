import type * as ts from 'typescript';
export { compileTypeScript } from './typescript/compilation';
export type { TypeScriptCompilationOptions } from './typescript/compilation';
export { getSourceNodes } from './typescript/get-source-nodes';
/**
 * Find a module based on it's import
 *
 * @param importExpr Import used to resolve to a module
 * @param filePath
 * @param tsConfigPath
 */
export declare function resolveModuleByImport(importExpr: string, filePath: string, tsConfigPath: string): string;
export declare function ensureTypescript(): typeof ts;
//# sourceMappingURL=typescript.d.ts.map
import * as ts from 'typescript';
import type { TransformerEntry } from '../../../utils/typescript/types';
export interface TypescriptInMemoryTsConfig {
    content: string;
    path: string;
}
export interface TypescripCompilationLogger {
    error: (message: string, tsConfig?: string) => void;
    info: (message: string, tsConfig?: string) => void;
    warn: (message: string, tsConfig?: string) => void;
}
export interface TypescriptProjectContext {
    project: string;
    tsConfig: TypescriptInMemoryTsConfig;
    transformers: TransformerEntry[];
}
export interface TypescriptCompilationResult {
    tsConfig: string;
    success: boolean;
}
export type ReporterWithTsConfig<Fn extends (...args: any[]) => any> = (tsConfig: string | undefined, ...foo: Parameters<Fn>) => ReturnType<Fn>;
export declare function compileTypescriptSolution(context: Record<string, TypescriptProjectContext>, watch: boolean, logger: TypescripCompilationLogger, hooks?: {
    beforeProjectCompilationCallback?: (tsConfig: string) => void;
    afterProjectCompilationCallback?: (tsConfig: string, success: boolean) => void;
}, reporters?: {
    diagnosticReporter?: ReporterWithTsConfig<ts.DiagnosticReporter>;
    solutionBuilderStatusReporter?: ReporterWithTsConfig<ts.DiagnosticReporter>;
    watchStatusReporter?: ReporterWithTsConfig<ts.WatchStatusReporter>;
}): AsyncIterable<TypescriptCompilationResult>;
//# sourceMappingURL=typescript-compilation.d.ts.map
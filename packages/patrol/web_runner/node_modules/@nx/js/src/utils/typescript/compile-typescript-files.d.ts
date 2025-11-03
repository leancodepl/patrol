import { TypeScriptCompilationOptions } from '@nx/workspace/src/utilities/typescript/compilation';
import { NormalizedExecutorOptions } from '../schema';
export interface TypescriptCompilationResult {
    success: boolean;
    outfile: string;
}
export declare function compileTypeScriptFiles(normalizedOptions: NormalizedExecutorOptions, tscOptions: TypeScriptCompilationOptions, postCompilationCallback: () => void | Promise<void>): {
    iterator: AsyncIterable<TypescriptCompilationResult>;
    close: () => void | Promise<void>;
};
//# sourceMappingURL=compile-typescript-files.d.ts.map
import type { Tree } from '@nx/devkit';
import type { CompilerOptions } from 'typescript';
/**
 * Cleans up the provided compiler options to only include the options that are
 * different or not set in the provided tsconfig file.
 */
export declare function getNeededCompilerOptionOverrides(tree: Tree, compilerOptions: Record<keyof CompilerOptions, any>, tsConfigPath: string): Record<keyof CompilerOptions, any>;
//# sourceMappingURL=configuration.d.ts.map
import type { Tree } from '@nx/devkit';
export declare function normalizeLinterOption(tree: Tree, linter: undefined | 'none' | 'eslint'): Promise<'none' | 'eslint'>;
export declare function normalizeUnitTestRunnerOption<T extends 'none' | 'jest' | 'vitest'>(tree: Tree, unitTestRunner: undefined | T, testRunners?: Array<'jest' | 'vitest'>): Promise<T>;
//# sourceMappingURL=generator-prompts.d.ts.map
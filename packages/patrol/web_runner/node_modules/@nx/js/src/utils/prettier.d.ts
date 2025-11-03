import { type GeneratorCallback, type Tree } from '@nx/devkit';
import type { Options } from 'prettier';
export interface ExistingPrettierConfig {
    sourceFilepath: string;
    config: Options;
}
export declare function resolveUserExistingPrettierConfig(): Promise<ExistingPrettierConfig | null>;
export declare function generatePrettierSetup(tree: Tree, options: {
    skipPackageJson?: boolean;
}): GeneratorCallback;
export declare function resolvePrettierConfigPath(tree: Tree): Promise<string | null>;
//# sourceMappingURL=prettier.d.ts.map
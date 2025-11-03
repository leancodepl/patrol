import { type Tree } from '@nx/devkit';
export declare const defaultExclude: string[];
export declare function addSwcConfig(tree: Tree, projectDir: string, type?: 'commonjs' | 'es6', supportTsx?: boolean, swcName?: string, additionalExcludes?: string[]): void;
export declare function addSwcTestConfig(tree: Tree, projectDir: string, type?: 'commonjs' | 'es6', supportTsx?: boolean): void;
//# sourceMappingURL=add-swc-config.d.ts.map
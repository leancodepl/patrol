import { type ProjectConfiguration, type Tree } from '@nx/devkit';
export declare function isUsingTypeScriptPlugin(tree: Tree): boolean;
export declare function shouldConfigureTsSolutionSetup(tree: Tree, addPlugins: boolean, addTsPlugin?: boolean): boolean;
export declare function isUsingTsSolutionSetup(tree?: Tree): boolean;
export declare function assertNotUsingTsSolutionSetup(tree: Tree, pluginName: string, generatorName: string): void;
export declare function findRuntimeTsConfigName(projectRoot: string, tree?: Tree): string | null;
export declare function updateTsconfigFiles(tree: Tree, projectRoot: string, runtimeTsconfigFileName: string, compilerOptions: Record<string, string | boolean | string[]>, exclude?: string[], rootDir?: string): void;
export declare function addProjectToTsSolutionWorkspace(tree: Tree, projectDir: string): Promise<void>;
export declare function getProjectType(tree: Tree, projectRoot: string, projectType?: 'library' | 'application'): 'library' | 'application';
export declare function getProjectSourceRoot(project: ProjectConfiguration, tree?: Tree): string;
/**
 * Get the already defined or expected custom condition name. In case it's not
 * yet defined, it returns the workspace package name or '@nx/source' in case
 * it's not defined.
 */
export declare function getCustomConditionName(tree: Tree, options?: {
    skipDevelopmentFallback?: boolean;
}): string;
/**
 * Get the already defined custom condition name or null if none is defined.
 */
export declare function getDefinedCustomConditionName(tree: Tree): string | null;
//# sourceMappingURL=ts-solution-setup.d.ts.map
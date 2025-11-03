import type { ProjectGraph, ProjectGraphExternalNode, ProjectGraphProjectNode, TaskGraph } from '@nx/devkit';
import type * as ts from 'typescript';
export type DependentBuildableProjectNode = {
    name: string;
    outputs: string[];
    node: ProjectGraphProjectNode | ProjectGraphExternalNode;
};
export declare function calculateProjectBuildableDependencies(taskGraph: TaskGraph | undefined, projGraph: ProjectGraph, root: string, projectName: string, targetName: string, configurationName: string, shallow?: boolean): {
    target: ProjectGraphProjectNode;
    dependencies: DependentBuildableProjectNode[];
    nonBuildableDependencies: string[];
    topLevelDependencies: DependentBuildableProjectNode[];
};
export declare function calculateProjectDependencies(projGraph: ProjectGraph, root: string, projectName: string, targetName: string, configurationName: string, shallow?: boolean): {
    target: ProjectGraphProjectNode;
    dependencies: DependentBuildableProjectNode[];
    nonBuildableDependencies: string[];
    topLevelDependencies: DependentBuildableProjectNode[];
};
export declare function calculateDependenciesFromTaskGraph(taskGraph: TaskGraph, projectGraph: ProjectGraph, root: string, projectName: string, targetName: string, configurationName: string, shallow?: boolean): {
    target: ProjectGraphProjectNode;
    dependencies: DependentBuildableProjectNode[];
    nonBuildableDependencies: string[];
    topLevelDependencies: DependentBuildableProjectNode[];
};
/**
 * Util function to create tsconfig compilerOptions object with support for workspace libs paths.
 *
 *
 *
 * @param tsConfig String of config path or object parsed via ts.parseJsonConfigFileContent.
 * @param dependencies Dependencies calculated by Nx.
 */
export declare function computeCompilerOptionsPaths(tsConfig: string | ts.ParsedCommandLine, dependencies: DependentBuildableProjectNode[]): ts.MapLike<string[]>;
export declare function createTmpTsConfig(tsconfigPath: string, workspaceRoot: string, projectRoot: string, dependencies: DependentBuildableProjectNode[], useWorkspaceAsBaseUrl?: boolean): string;
export declare function updatePaths(dependencies: DependentBuildableProjectNode[], paths: Record<string, string[]>): void;
/**
 * Updates the peerDependencies section in the `dist/lib/xyz/package.json` with
 * the proper dependency and version
 */
export declare function updateBuildableProjectPackageJsonDependencies(root: string, projectName: string, targetName: string, configurationName: string, node: ProjectGraphProjectNode, dependencies: DependentBuildableProjectNode[], typeOfDependency?: 'dependencies' | 'peerDependencies'): void;
//# sourceMappingURL=buildable-libs-utils.d.ts.map
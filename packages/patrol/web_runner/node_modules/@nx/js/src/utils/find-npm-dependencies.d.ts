import { type ProjectFileMap, type ProjectGraph, type ProjectGraphProjectNode } from '@nx/devkit';
/**
 * Finds all npm dependencies and their expected versions for a given project.
 */
export declare function findNpmDependencies(workspaceRoot: string, sourceProject: ProjectGraphProjectNode, projectGraph: ProjectGraph, projectFileMap: ProjectFileMap, buildTarget: string, options?: {
    includeTransitiveDependencies?: boolean;
    ignoredFiles?: string[];
    useLocalPathsForWorkspaceDependencies?: boolean;
    runtimeHelpers?: string[];
}): Record<string, string>;
//# sourceMappingURL=find-npm-dependencies.d.ts.map
import type { FileData, ProjectFileMap, ProjectGraph, ProjectGraphProjectNode } from '@nx/devkit';
export declare function getPath(graph: ProjectGraph, sourceProjectName: string, targetProjectName: string): Array<ProjectGraphProjectNode>;
export declare function pathExists(graph: ProjectGraph, sourceProjectName: string, targetProjectName: string): boolean;
export declare function checkCircularPath(graph: ProjectGraph, sourceProject: ProjectGraphProjectNode, targetProject: ProjectGraphProjectNode): ProjectGraphProjectNode[];
export declare function circularPathHasPair(circularPath: ProjectGraphProjectNode[], ignored: Map<string, Set<string>>): boolean;
export declare function findFilesInCircularPath(projectFileMap: ProjectFileMap, circularPath: ProjectGraphProjectNode[]): Array<string[]>;
export declare function findFilesWithDynamicImports(projectFileMap: ProjectFileMap, sourceProjectName: string, targetProjectName: string): FileData[];
export declare function expandIgnoredCircularDependencies(ignoredCircularDependencies: Array<[string, string]>, projectGraph: ProjectGraph): Map<string, Set<string>>;
//# sourceMappingURL=graph-utils.d.ts.map
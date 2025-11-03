import { ProjectGraph, ProjectGraphDependency, ProjectGraphExternalNode, ProjectGraphProjectNode } from '@nx/devkit';
import { TargetProjectLocator } from '@nx/js/src/internal';
import { TSESLint, TSESTree } from '@typescript-eslint/utils';
import { ProjectRootMappings } from 'nx/src/project-graph/utils/find-project-for-path';
export type Deps = {
    [projectName: string]: ProjectGraphDependency[];
};
type SingleSourceTagConstraint = {
    sourceTag: string;
    onlyDependOnLibsWithTags?: string[];
    notDependOnLibsWithTags?: string[];
    allowedExternalImports?: string[];
    bannedExternalImports?: string[];
};
type ComboSourceTagConstraint = {
    allSourceTags: string[];
    onlyDependOnLibsWithTags?: string[];
    notDependOnLibsWithTags?: string[];
    allowedExternalImports?: string[];
    bannedExternalImports?: string[];
};
export type DepConstraint = SingleSourceTagConstraint | ComboSourceTagConstraint;
export declare function stringifyTags(tags: string[]): string;
export declare function hasNoneOfTheseTags(proj: ProjectGraphProjectNode, tags: string[]): boolean;
export declare function isComboDepConstraint(depConstraint: DepConstraint): depConstraint is ComboSourceTagConstraint;
/**
 * Check if any of the given tags is included in the project
 * @param proj ProjectGraphProjectNode
 * @param tags
 * @returns
 */
export declare function findDependenciesWithTags(targetProject: ProjectGraphProjectNode, tags: string[], graph: ProjectGraph): ProjectGraphProjectNode[][];
export declare function matchImportWithWildcard(allowableImport: string, extractedImport: string): boolean;
export declare function isRelative(s: string): boolean;
export declare function getTargetProjectBasedOnRelativeImport(imp: string, projectPath: string, projectGraph: ProjectGraph, projectRootMappings: ProjectRootMappings, sourceFilePath: string): ProjectGraphProjectNode | undefined;
export declare function findProject(projectGraph: ProjectGraph, projectRootMappings: ProjectRootMappings, sourceFilePath: string): ProjectGraphProjectNode;
export declare function isAbsoluteImportIntoAnotherProject(imp: string, workspaceLayout?: {
    libsDir: string;
    appsDir: string;
}): boolean;
export declare function findProjectUsingImport(projectGraph: ProjectGraph, targetProjectLocator: TargetProjectLocator, filePath: string, imp: string): ProjectGraphProjectNode | ProjectGraphExternalNode;
export declare function findConstraintsFor(depConstraints: DepConstraint[], sourceProject: ProjectGraphProjectNode): DepConstraint[];
export declare function hasStaticImportOfDynamicResource(node: TSESTree.ImportDeclaration | TSESTree.ImportExpression | TSESTree.ExportAllDeclaration | TSESTree.ExportNamedDeclaration, graph: ProjectGraph, sourceProjectName: string, targetProjectName: string, importExpr: string, filePath: string): boolean;
export declare function getSourceFilePath(sourceFileName: string, projectPath: string): string;
export declare function hasBannedImport(source: ProjectGraphProjectNode, target: ProjectGraphExternalNode, depConstraints: DepConstraint[], imp: string): DepConstraint | undefined;
/**
 * Find all unique (transitive) external dependencies of given project
 * @param graph
 * @param source
 * @returns
 */
export declare function findTransitiveExternalDependencies(graph: ProjectGraph, source: ProjectGraphProjectNode): ProjectGraphDependency[];
/**
 * Check if
 * @param externalDependencies
 * @param graph
 * @param depConstraint
 * @returns
 */
export declare function hasBannedDependencies(externalDependencies: ProjectGraphDependency[], graph: ProjectGraph, depConstraint: DepConstraint, imp: string): Array<[ProjectGraphExternalNode, ProjectGraphProjectNode, DepConstraint]> | undefined;
export declare function isDirectDependency(source: ProjectGraphProjectNode, target: ProjectGraphExternalNode): boolean;
/**
 * Verifies whether the given node has a builder target
 * @param projectGraph the node to verify
 * @param buildTargets the list of targets to check for
 */
export declare function hasBuildExecutor(projectGraph: ProjectGraphProjectNode, buildTargets?: string[]): boolean;
export declare function isTerminalRun(): boolean;
/**
 * Takes an array of imports and tries to group them, so rather than having
 * `import { A } from './some-location'` and `import { B } from './some-location'` you get
 * `import { A, B } from './some-location'`
 * @param importsToRemap
 * @returns
 */
export declare function groupImports(importsToRemap: {
    member: string;
    importPath: string;
}[]): string;
/**
 * Checks if source file belongs to a secondary entry point different than the import one
 */
export declare function belongsToDifferentEntryPoint(importExpr: string, filePath: string, projectRoot: string): boolean;
export declare function getSecondaryEntryPointPath(importExpr: string, filePath: string, projectRoot: string): string | undefined;
export declare function parseExports(exports: string | null | Record<string, any>, projectRoot: string, entryPaths: Array<{
    path: string;
    file: string;
}>, basePath?: string): Array<{
    path: string;
    file: string;
}>;
/**
 * Returns true if the given project contains MFE config with "exposes:" section
 */
export declare function appIsMFERemote(project: ProjectGraphProjectNode): boolean;
/**
 * parserServices moved from the context object to the nested sourceCode object in v8,
 * and was removed from its original location in v9.
 */
export declare function getParserServices(context: Readonly<TSESLint.RuleContext<any, any>>): any;
export {};
//# sourceMappingURL=runtime-lint-utils.d.ts.map
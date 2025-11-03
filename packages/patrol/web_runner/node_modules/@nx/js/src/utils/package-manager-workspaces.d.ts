import { type GeneratorCallback, type Tree } from '@nx/devkit';
export type ProjectPackageManagerWorkspaceState = 'included' | 'excluded' | 'no-workspaces';
export declare function getProjectPackageManagerWorkspaceState(tree: Tree, projectRoot: string): ProjectPackageManagerWorkspaceState;
export declare function getPackageManagerWorkspacesPatterns(tree: Tree): string[];
export declare function isUsingPackageManagerWorkspaces(tree: Tree): boolean;
export declare function isWorkspacesEnabled(tree: Tree): boolean;
export declare function getProjectPackageManagerWorkspaceStateWarningTask(projectPackageManagerWorkspaceState: ProjectPackageManagerWorkspaceState, workspaceRoot: string): GeneratorCallback;
//# sourceMappingURL=package-manager-workspaces.d.ts.map
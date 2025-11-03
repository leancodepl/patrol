import { GeneratorCallback, ProjectConfiguration, Tree } from '@nx/devkit';
/**
 * Adds release option in nx.json to build the project before versioning
 */
export declare function addReleaseConfigForTsSolution(tree: Tree, projectName: string, projectConfiguration: ProjectConfiguration): Promise<void>;
/**
 * Add release configuration for non-ts solution projects
 * Add release option in project.json and add packageRoot to nx-release-publish target
 */
export declare function addReleaseConfigForNonTsSolution(tree: Tree, projectName: string, projectConfiguration: ProjectConfiguration, defaultOutputDirectory?: string): Promise<ProjectConfiguration>;
export declare function releaseTasks(tree: Tree): Promise<GeneratorCallback>;
//# sourceMappingURL=add-release-config.d.ts.map
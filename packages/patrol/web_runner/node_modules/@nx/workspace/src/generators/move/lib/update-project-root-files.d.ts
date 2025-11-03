import { ProjectConfiguration, Tree } from '@nx/devkit';
import { NormalizedSchema } from '../schema';
/**
 * Updates the files in the root of the project
 *
 * Typically these are config files which point outside of the project folder
 *
 * @param schema The options provided to the schematic
 */
export declare function updateProjectRootFiles(tree: Tree, schema: NormalizedSchema, project: ProjectConfiguration): void;
export declare function updateFilesForRootProjects(tree: Tree, schema: NormalizedSchema, project: ProjectConfiguration): void;
export declare function updateFilesForNonRootProjects(tree: Tree, schema: NormalizedSchema, project: ProjectConfiguration): void;
//# sourceMappingURL=update-project-root-files.d.ts.map
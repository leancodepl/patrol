import { ProjectConfiguration, Tree } from '@nx/devkit';
import { NormalizedSchema } from '../schema';
/**
 * Updates the project name and coverage folder in the jest.config.js if it exists
 *
 * (assume relative paths have been updated previously)
 *
 * @param schema The options provided to the schematic
 */
export declare function updateJestConfig(tree: Tree, schema: NormalizedSchema, project: ProjectConfiguration): void;
//# sourceMappingURL=update-jest-config.d.ts.map
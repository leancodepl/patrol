import { ProjectConfiguration, Tree } from '@nx/devkit';
import { NormalizedSchema } from '../schema';
/**
 * Updates the videos and screenshots folders in the cypress.json/cypress.config.ts if it exists (i.e. we're moving an e2e project)
 *
 * (assume relative paths have been updated previously)
 *
 * @param schema The options provided to the schematic
 */
export declare function updateCypressConfig(tree: Tree, schema: NormalizedSchema, project: ProjectConfiguration): Tree;
//# sourceMappingURL=update-cypress-config.d.ts.map
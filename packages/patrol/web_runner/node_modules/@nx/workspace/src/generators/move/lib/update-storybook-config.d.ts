import { ProjectConfiguration, Tree } from '@nx/devkit';
import { NormalizedSchema } from '../schema';
/**
 * Updates relative path to root storybook config for `main.js` & `webpack.config.js`
 *
 * @param {Tree} tree
 * @param {NormalizedSchema} schema The options provided to the schematic
 * @param {ProjectConfiguration} project
 */
export declare function updateStorybookConfig(tree: Tree, schema: NormalizedSchema, project: ProjectConfiguration): void;
//# sourceMappingURL=update-storybook-config.d.ts.map
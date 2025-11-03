import type { Tree } from '@nx/devkit';
import type { NormalizedSchema } from '../schema';
/**
 * Checks whether the destination folder is valid
 *
 * - must not be outside the workspace
 * - must be a new folder
 *
 * @param schema The options provided to the schematic
 */
export declare function checkDestination(tree: Tree, schema: NormalizedSchema, providedDestination: string): void;
//# sourceMappingURL=check-destination.d.ts.map
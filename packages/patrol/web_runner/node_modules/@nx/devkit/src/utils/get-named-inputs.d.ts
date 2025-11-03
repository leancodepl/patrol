import type { InputDefinition } from 'nx/src/config/workspace-json-project-json';
import { CreateNodesContextV2 } from 'nx/src/devkit-exports';
/**
 * Get the named inputs available for a directory
 */
export declare function getNamedInputs(directory: string, context: CreateNodesContextV2): {
    [inputName: string]: (string | InputDefinition)[];
};
//# sourceMappingURL=get-named-inputs.d.ts.map
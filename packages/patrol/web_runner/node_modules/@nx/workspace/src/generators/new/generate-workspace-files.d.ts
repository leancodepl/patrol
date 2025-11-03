import { type Tree } from '@nx/devkit';
import type { NormalizedSchema } from './new';
export declare function generateWorkspaceFiles(tree: Tree, options: NormalizedSchema): Promise<{
    token: string;
    aiAgentsCallback: () => unknown | undefined;
}>;
//# sourceMappingURL=generate-workspace-files.d.ts.map
import { type ExecutorContext } from '@nx/devkit';
import { type PruneLockfileOptions } from './schema';
export default function pruneLockfileExecutor(schema: PruneLockfileOptions, context: ExecutorContext): Promise<{
    success: boolean;
}>;
//# sourceMappingURL=prune-lockfile.d.ts.map
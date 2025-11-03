import { ExecutorContext } from '@nx/devkit';
import { NodeExecutorOptions } from './schema';
export declare function nodeExecutor(options: NodeExecutorOptions, context: ExecutorContext): AsyncGenerator<{
    success: boolean;
    options?: Record<string, any>;
}, void, any>;
export default nodeExecutor;
//# sourceMappingURL=node.impl.d.ts.map
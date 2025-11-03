import { ExecutorContext } from '@nx/devkit';
import { SwcExecutorOptions } from '../../utils/schema';
export declare function swcExecutor(_options: SwcExecutorOptions, context: ExecutorContext): AsyncGenerator<{
    success: boolean;
    outfile?: undefined;
} | {
    success: boolean;
    outfile: string;
}, any, any>;
export default swcExecutor;
//# sourceMappingURL=swc.impl.d.ts.map
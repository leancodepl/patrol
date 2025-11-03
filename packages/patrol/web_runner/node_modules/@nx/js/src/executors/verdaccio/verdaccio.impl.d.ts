import { ExecutorContext } from '@nx/devkit';
import { VerdaccioExecutorSchema } from './schema';
/**
 * - set npm and yarn to use local registry
 * - start verdaccio
 * - stop local registry when done
 */
export declare function verdaccioExecutor(options: VerdaccioExecutorSchema, context: ExecutorContext): Promise<{
    success: boolean;
    port: number;
}>;
export default verdaccioExecutor;
//# sourceMappingURL=verdaccio.impl.d.ts.map
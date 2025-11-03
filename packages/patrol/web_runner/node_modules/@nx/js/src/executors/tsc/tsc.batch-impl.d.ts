import { ExecutorContext, TaskGraph } from '@nx/devkit';
import type { BatchExecutorTaskResult } from 'nx/src/config/misc-interfaces';
import type { ExecutorOptions } from '../../utils/schema';
export declare function tscBatchExecutor(taskGraph: TaskGraph, inputs: Record<string, ExecutorOptions>, overrides: ExecutorOptions, context: ExecutorContext): AsyncGenerator<BatchExecutorTaskResult, any, unknown>;
export default tscBatchExecutor;
//# sourceMappingURL=tsc.batch-impl.d.ts.map
import { type ExecutorContext } from '@nx/devkit';
import type { NormalizedExecutorOptions } from '../../../utils/schema';
import type { TypescriptInMemoryTsConfig } from './typescript-compilation';
export declare function getProcessedTaskTsConfigs(tasks: string[], tasksOptions: Record<string, NormalizedExecutorOptions>, context: ExecutorContext): Record<string, TypescriptInMemoryTsConfig>;
//# sourceMappingURL=get-tsconfig.d.ts.map
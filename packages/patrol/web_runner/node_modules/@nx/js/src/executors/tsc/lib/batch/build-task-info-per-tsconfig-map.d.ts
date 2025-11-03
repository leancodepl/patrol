import type { ExecutorContext } from '@nx/devkit';
import type { NormalizedExecutorOptions } from '../../../../utils/schema';
import type { TypescriptInMemoryTsConfig } from '../typescript-compilation';
import type { TaskInfo } from './types';
export declare function createTaskInfoPerTsConfigMap(tasksOptions: Record<string, NormalizedExecutorOptions>, context: ExecutorContext, tasks: string[], taskInMemoryTsConfigMap: Record<string, TypescriptInMemoryTsConfig>): Record<string, TaskInfo>;
//# sourceMappingURL=build-task-info-per-tsconfig-map.d.ts.map
import type { TaskInfo } from './types';
export declare function watchTaskProjectsPackageJsonFileChanges(taskInfos: TaskInfo[], callback: (changedTaskInfos: TaskInfo[]) => void): Promise<() => void>;
export declare function watchTaskProjectsFileChangesForAssets(taskInfos: TaskInfo[]): Promise<() => void>;
//# sourceMappingURL=watch.d.ts.map
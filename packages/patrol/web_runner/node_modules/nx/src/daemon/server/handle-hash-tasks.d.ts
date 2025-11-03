import { Task, TaskGraph } from '../../config/task-graph';
export declare function handleHashTasks(payload: {
    runnerOptions: any;
    env: any;
    tasks: Task[];
    taskGraph: TaskGraph;
}): Promise<{
    response: import("../../hasher/task-hasher").Hash[];
    description: string;
}>;
//# sourceMappingURL=handle-hash-tasks.d.ts.map
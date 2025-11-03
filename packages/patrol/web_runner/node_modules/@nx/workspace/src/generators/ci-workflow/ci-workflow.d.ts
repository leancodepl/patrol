import { Tree } from '@nx/devkit';
export type Command = {
    command?: string;
    comments?: string[];
    alwaysRun?: boolean;
};
export interface Schema {
    name: string;
    ci: 'github' | 'azure' | 'circleci' | 'bitbucket-pipelines' | 'gitlab';
    useRunMany?: boolean;
}
export declare function ciWorkflowGenerator(tree: Tree, schema: Schema): Promise<void>;
//# sourceMappingURL=ci-workflow.d.ts.map
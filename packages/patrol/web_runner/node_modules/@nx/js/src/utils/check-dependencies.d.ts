import { ExecutorContext, ProjectGraphProjectNode } from '@nx/devkit';
import { DependentBuildableProjectNode } from './buildable-libs-utils';
export declare function checkDependencies(context: ExecutorContext, tsConfigPath: string): {
    tmpTsConfig: string | null;
    projectRoot: string;
    target: ProjectGraphProjectNode;
    dependencies: DependentBuildableProjectNode[];
};
//# sourceMappingURL=check-dependencies.d.ts.map
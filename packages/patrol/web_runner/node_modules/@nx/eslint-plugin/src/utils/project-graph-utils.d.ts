import { ProjectFileMap, ProjectGraph } from '@nx/devkit';
import { ProjectRootMappings } from 'nx/src/project-graph/utils/find-project-for-path';
import { TargetProjectLocator } from '@nx/js/src/internal';
export declare function ensureGlobalProjectGraph(ruleName: string): void;
export declare function readProjectGraph(ruleName: string): {
    projectGraph: ProjectGraph;
    projectFileMap: ProjectFileMap;
    projectRootMappings: ProjectRootMappings;
    targetProjectLocator: TargetProjectLocator;
};
//# sourceMappingURL=project-graph-utils.d.ts.map
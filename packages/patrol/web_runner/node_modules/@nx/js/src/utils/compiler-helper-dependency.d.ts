import { type ProjectGraph, type ProjectGraphDependency } from '@nx/devkit';
import { DependentBuildableProjectNode } from './buildable-libs-utils';
export declare enum HelperDependency {
    tsc = "npm:tslib",
    swc = "npm:@swc/helpers"
}
/**
 * Check and return a DependencyNode for the compiler's external helpers npm package. Return "null"
 * if it doesn't need it or it cannot be found in the Project Graph
 *
 * @param {HelperDependency} helperDependency
 * @param {string} configPath
 * @param {DependentBuildableProjectNode[]} dependencies
 * @param {ProjectGraph} projectGraph
 * @param {boolean=false} returnDependencyIfFound
 */
export declare function getHelperDependency(helperDependency: HelperDependency, configPath: string, dependencies: DependentBuildableProjectNode[], projectGraph: ProjectGraph, returnDependencyIfFound?: boolean): DependentBuildableProjectNode | null;
export declare function getHelperDependenciesFromProjectGraph(contextRoot: string, sourceProject: string, projectGraph: ProjectGraph): ProjectGraphDependency[];
//# sourceMappingURL=compiler-helper-dependency.d.ts.map
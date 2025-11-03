import { type TargetConfiguration } from '@nx/devkit';
import { type PackageManagerCommands } from 'nx/src/utils/package-manager';
import { type ParsedCommandLine } from 'typescript';
export type ExtendedConfigFile = {
    filePath: string;
    externalPackage?: string;
};
export type ParsedTsconfigData = Pick<ParsedCommandLine, 'options' | 'projectReferences' | 'raw'> & {
    extendedConfigFiles: ExtendedConfigFile[];
};
/**
 * Allow uses that use incremental builds to run `nx watch-deps` to continuously build all dependencies.
 */
export declare function addBuildAndWatchDepsTargets(workspaceRoot: string, projectRoot: string, targets: Record<string, TargetConfiguration>, options: {
    buildDepsTargetName?: string;
    watchDepsTargetName?: string;
}, pmc: PackageManagerCommands): void;
export declare function isValidPackageJsonBuildConfig(tsConfig: ParsedTsconfigData, workspaceRoot: string, projectRoot: string): boolean;
//# sourceMappingURL=util.d.ts.map
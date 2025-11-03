import { ExecutorContext, ProjectFileMap, ProjectGraphProjectNode } from '@nx/devkit';
import { DependentBuildableProjectNode } from '../buildable-libs-utils';
import type { PackageJson } from 'nx/src/utils/package-json';
export type SupportedFormat = 'cjs' | 'esm';
export interface UpdatePackageJsonOption {
    rootDir?: string;
    projectRoot: string;
    main: string;
    additionalEntryPoints?: string[];
    format?: SupportedFormat[];
    outputPath: string;
    outputFileName?: string;
    outputFileExtensionForCjs?: `.${string}`;
    outputFileExtensionForEsm?: `.${string}`;
    skipTypings?: boolean;
    generateExportsField?: boolean;
    excludeLibsInPackageJson?: boolean;
    updateBuildableProjectDepsInPackageJson?: boolean;
    buildableProjectDepsInPackageJsonType?: 'dependencies' | 'peerDependencies';
    generateLockfile?: boolean;
    packageJsonPath?: string;
    developmentConditionName?: string | null;
}
export declare function updatePackageJson(options: UpdatePackageJsonOption, context: ExecutorContext, target: ProjectGraphProjectNode, dependencies: DependentBuildableProjectNode[], fileMap?: ProjectFileMap): void;
interface Exports {
    '.': string;
    [name: string]: string;
}
export declare function getExports(options: Pick<UpdatePackageJsonOption, 'main' | 'rootDir' | 'projectRoot' | 'outputFileName' | 'additionalEntryPoints' | 'outputPath' | 'packageJsonPath'> & {
    fileExt: string;
}): Exports;
export declare function getUpdatedPackageJsonContent(packageJson: PackageJson, options: UpdatePackageJsonOption): PackageJson;
export declare function getOutputDir(options: Pick<UpdatePackageJsonOption, 'main' | 'rootDir' | 'projectRoot' | 'outputFileName' | 'outputPath' | 'packageJsonPath'>): string;
export {};
//# sourceMappingURL=update-package-json.d.ts.map
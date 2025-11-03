import { ExecutorContext } from '@nx/devkit';
import { DependentBuildableProjectNode } from '../buildable-libs-utils';
import type { UpdatePackageJsonOption } from './update-package-json';
export interface CopyPackageJsonOptions extends Omit<UpdatePackageJsonOption, 'projectRoot'> {
    watch?: boolean;
    extraDependencies?: DependentBuildableProjectNode[];
    overrideDependencies?: DependentBuildableProjectNode[];
}
export interface CopyPackageJsonResult {
    success?: boolean;
    stop?: () => void;
}
export declare function copyPackageJson(_options: CopyPackageJsonOptions, context: ExecutorContext): Promise<CopyPackageJsonResult>;
//# sourceMappingURL=index.d.ts.map
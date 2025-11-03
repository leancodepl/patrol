import type { PackageJson } from 'nx/src/utils/package-json';
export declare function getAllDependencies(packageJson: PackageJson): Record<string, string>;
export declare function getProductionDependencies(packageJson: PackageJson): Record<string, string>;
export declare function getPackageJson(path: string): PackageJson;
//# sourceMappingURL=package-json-utils.d.ts.map
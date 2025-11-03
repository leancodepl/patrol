import { PackageJson } from 'nx/src/utils/package-json';
export declare function parseRegistryOptions(cwd: string, pkg: {
    packageRoot: string;
    packageJson: PackageJson;
}, options: {
    registry?: string;
    tag?: string;
}, logWarnFn?: (message: string) => void): Promise<{
    registry: string;
    tag: string;
    registryConfigKey: string;
}>;
/**
 * Returns the npm registry that is used for publishing.
 *
 * @param scope the scope of the package for which to determine the registry
 * @param cwd the directory where the npm config should be read from
 */
export declare function getNpmRegistry(cwd: string, scope?: string): Promise<string>;
/**
 * Returns the npm tag that is used for publishing.
 *
 * @param cwd the directory where the npm config should be read from
 */
export declare function getNpmTag(cwd: string): Promise<string>;
//# sourceMappingURL=npm-config.d.ts.map
import { type GeneratorCallback, type Tree } from 'nx/src/devkit-exports';
import type { PackageJson, PackageJsonDependencySection } from 'nx/src/utils/package-json';
/**
 * Get the resolved version of a dependency from package.json.
 *
 * Retrieves a package version and automatically resolves PNPM catalog references
 * (e.g., "catalog:default") to their actual version strings. By default, searches
 * `dependencies` first, then falls back to `devDependencies`.
 *
 * **Tree-based usage** (generators and migrations):
 * Use when you have a `Tree` object, which is typical in Nx generators and migrations.
 *
 * **Filesystem-based usage** (CLI commands and scripts):
 * Use when reading directly from the filesystem without a `Tree` object.
 *
 * @example
 * ```typescript
 * // Tree-based - from root package.json (checks dependencies then devDependencies)
 * const reactVersion = getDependencyVersionFromPackageJson(tree, 'react');
 * // Returns: "^18.0.0" (resolves "catalog:default" if present)
 *
 * // Tree-based - check only dependencies section
 * const version = getDependencyVersionFromPackageJson(
 *   tree,
 *   'react',
 *   'package.json',
 *   ['dependencies']
 * );
 *
 * // Tree-based - check only devDependencies section
 * const version = getDependencyVersionFromPackageJson(
 *   tree,
 *   'jest',
 *   'package.json',
 *   ['devDependencies']
 * );
 *
 * // Tree-based - custom lookup order
 * const version = getDependencyVersionFromPackageJson(
 *   tree,
 *   'pkg',
 *   'package.json',
 *   ['devDependencies', 'dependencies', 'peerDependencies']
 * );
 *
 * // Tree-based - with pre-loaded package.json
 * const packageJson = readJson(tree, 'package.json');
 * const version = getDependencyVersionFromPackageJson(
 *   tree,
 *   'react',
 *   packageJson,
 *   ['dependencies']
 * );
 * ```
 *
 * @example
 * ```typescript
 * // Filesystem-based - from current directory
 * const reactVersion = getDependencyVersionFromPackageJson('react');
 *
 * // Filesystem-based - with workspace root
 * const version = getDependencyVersionFromPackageJson('react', '/path/to/workspace');
 *
 * // Filesystem-based - with specific package.json and section
 * const version = getDependencyVersionFromPackageJson(
 *   'react',
 *   '/path/to/workspace',
 *   'apps/my-app/package.json',
 *   ['dependencies']
 * );
 * ```
 *
 * @param dependencyLookup Array of dependency sections to check in order. Defaults to ['dependencies', 'devDependencies']
 * @returns The resolved version string, or `null` if the package is not found in any of the specified sections
 */
export declare function getDependencyVersionFromPackageJson(tree: Tree, packageName: string, packageJsonPath?: string, dependencyLookup?: PackageJsonDependencySection[]): string | null;
export declare function getDependencyVersionFromPackageJson(tree: Tree, packageName: string, packageJson?: PackageJson, dependencyLookup?: PackageJsonDependencySection[]): string | null;
export declare function getDependencyVersionFromPackageJson(packageName: string, workspaceRootPath?: string, packageJsonPath?: string, dependencyLookup?: PackageJsonDependencySection[]): string | null;
export declare function getDependencyVersionFromPackageJson(packageName: string, workspaceRootPath?: string, packageJson?: PackageJson, dependencyLookup?: PackageJsonDependencySection[]): string | null;
/**
 * Add Dependencies and Dev Dependencies to package.json
 *
 * For example:
 * ```typescript
 * addDependenciesToPackageJson(tree, { react: 'latest' }, { jest: 'latest' })
 * ```
 * This will **add** `react` and `jest` to the dependencies and devDependencies sections of package.json respectively.
 *
 * @param tree Tree representing file system to modify
 * @param dependencies Dependencies to be added to the dependencies section of package.json
 * @param devDependencies Dependencies to be added to the devDependencies section of package.json
 * @param packageJsonPath Path to package.json
 * @param keepExistingVersions If true, prevents existing dependencies from being bumped to newer versions
 * @returns Callback to install dependencies only if necessary, no-op otherwise
 */
export declare function addDependenciesToPackageJson(tree: Tree, dependencies: Record<string, string>, devDependencies: Record<string, string>, packageJsonPath?: string, keepExistingVersions?: boolean): GeneratorCallback;
/**
 * Remove Dependencies and Dev Dependencies from package.json
 *
 * For example:
 * ```typescript
 * removeDependenciesFromPackageJson(tree, ['react'], ['jest'])
 * ```
 * This will **remove** `react` and `jest` from the dependencies and devDependencies sections of package.json respectively.
 *
 * @param dependencies Dependencies to be removed from the dependencies section of package.json
 * @param devDependencies Dependencies to be removed from the devDependencies section of package.json
 * @returns Callback to uninstall dependencies only if necessary. undefined is returned if changes are not necessary.
 */
export declare function removeDependenciesFromPackageJson(tree: Tree, dependencies: string[], devDependencies: string[], packageJsonPath?: string): GeneratorCallback;
/**
 * @typedef EnsurePackageOptions
 * @type {object}
 * @property {boolean} dev indicate if the package is a dev dependency
 * @property {throwOnMissing} boolean throws an error when the package is missing
 */
/**
 * @deprecated Use the other function signature without a Tree
 *
 * Use a package that has not been installed as a dependency.
 *
 * For example:
 * ```typescript
 * ensurePackage(tree, '@nx/jest', nxVersion)
 * ```
 * This install the @nx/jest@<nxVersion> and return the module
 * When running with --dryRun, the function will throw when dependencies are missing.
 * Returns null for ESM dependencies. Import them with a dynamic import instead.
 *
 * @param tree the file system tree
 * @param pkg the package to check (e.g. @nx/jest)
 * @param requiredVersion the version or semver range to check (e.g. ~1.0.0, >=1.0.0 <2.0.0)
 * @param {EnsurePackageOptions} options?
 */
export declare function ensurePackage(tree: Tree, pkg: string, requiredVersion: string, options?: {
    dev?: boolean;
    throwOnMissing?: boolean;
}): void;
/**
 * Ensure that dependencies and devDependencies from package.json are installed at the required versions.
 * Returns null for ESM dependencies. Import them with a dynamic import instead.
 *
 * For example:
 * ```typescript
 * ensurePackage('@nx/jest', nxVersion)
 * ```
 *
 * @param pkg the package to install and require
 * @param version the version to install if the package doesn't exist already
 */
export declare function ensurePackage<T extends any = any>(pkg: string, version: string): T;
/**
 * @description The version of Nx used by the workspace. Returns null if no version is found.
 */
export declare const NX_VERSION: string;
//# sourceMappingURL=package-json.d.ts.map
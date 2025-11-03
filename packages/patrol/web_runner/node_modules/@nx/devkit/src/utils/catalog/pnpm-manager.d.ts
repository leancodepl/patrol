import { type Tree } from 'nx/src/devkit-exports';
import type { PnpmWorkspaceYaml } from 'nx/src/utils/pnpm-workspace';
import type { CatalogManager } from './manager';
import { type CatalogReference } from './types';
/**
 * PNPM-specific catalog manager implementation
 */
export declare class PnpmCatalogManager implements CatalogManager {
    readonly name = "pnpm";
    readonly catalogProtocol = "catalog:";
    isCatalogReference(version: string): boolean;
    parseCatalogReference(version: string): CatalogReference | null;
    getCatalogDefinitions(treeOrRoot: Tree | string): PnpmWorkspaceYaml | null;
    resolveCatalogReference(treeOrRoot: Tree | string, packageName: string, version: string): string | null;
    validateCatalogReference(treeOrRoot: Tree | string, packageName: string, version: string): void;
    updateCatalogVersions(treeOrRoot: Tree | string, updates: Array<{
        packageName: string;
        version: string;
        catalogName?: string;
    }>): void;
}
//# sourceMappingURL=pnpm-manager.d.ts.map
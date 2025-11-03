import { type Tree } from 'nx/src/devkit-exports';
import { getCatalogManager } from './manager-factory';
import type { CatalogManager } from './manager';
export { type CatalogManager, getCatalogManager };
/**
 * Detects which packages in a package.json use catalog references
 * Returns Map of package name -> catalog name (undefined for default catalog)
 */
export declare function getCatalogDependenciesFromPackageJson(tree: Tree, packageJsonPath: string, manager: CatalogManager): Map<string, string | undefined>;
//# sourceMappingURL=index.d.ts.map
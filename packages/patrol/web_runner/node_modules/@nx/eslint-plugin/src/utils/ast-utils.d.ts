import { ProjectGraphProjectNode } from '@nx/devkit';
/**
 *
 * @param importScope like `@myorg/somelib`
 * @returns
 */
export declare function getBarrelEntryPointByImportScope(importScope: string): string[];
export declare function getBarrelEntryPointProjectNode(projectNode: ProjectGraphProjectNode): {
    path: string;
    importScope: string;
}[] | null;
export declare function getRelativeImportPath(exportedMember: any, filePath: any): any;
//# sourceMappingURL=ast-utils.d.ts.map
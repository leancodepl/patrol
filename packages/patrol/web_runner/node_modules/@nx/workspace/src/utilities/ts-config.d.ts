import { Tree } from '@nx/devkit';
import type { Node, SyntaxKind } from 'typescript';
export declare function readTsConfig(tsConfigPath: string): import("typescript").ParsedCommandLine;
export declare function getRootTsConfigPathInTree(tree: Tree): string | null;
export declare function getRelativePathToRootTsConfig(tree: Tree, targetPath: string): string;
export declare function getRootTsConfigFileName(): string | null;
export declare function findNodes(node: Node, kind: SyntaxKind | SyntaxKind[], max?: number): Node[];
//# sourceMappingURL=ts-config.d.ts.map
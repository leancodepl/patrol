import type { Tree } from '@angular-devkit/schematics';
/**
 * @deprecated Nx no longer supports workspace.json
 */
export declare function getWorkspacePath(host: Tree): string;
export declare function parseTarget(targetString: string): {
    project: string;
    target: string;
    config: string;
};
export declare function editTarget(targetString: string, callback: any): string;
/**
 * @deprecated use the utility from nx/src/utils instead
 */
export declare function serializeTarget({ project, target, config }: {
    project: any;
    target: any;
    config: any;
}): string;
//# sourceMappingURL=cli-config-utils.d.ts.map
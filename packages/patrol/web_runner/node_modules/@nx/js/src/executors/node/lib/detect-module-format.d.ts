export type ModuleFormat = 'cjs' | 'esm';
export interface ModuleFormatDetectionOptions {
    projectRoot: string;
    workspaceRoot: string;
    tsConfig?: string;
    main: string;
    buildOptions?: any;
}
export declare function detectModuleFormat(options: ModuleFormatDetectionOptions): ModuleFormat;
//# sourceMappingURL=detect-module-format.d.ts.map
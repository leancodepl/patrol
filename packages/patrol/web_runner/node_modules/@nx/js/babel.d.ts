export interface NxWebBabelPresetOptions {
    useBuiltIns?: boolean | string;
    decorators?: {
        decoratorsBeforeExport?: boolean;
        legacy?: boolean;
    };
    loose?: boolean;
    /** @deprecated Use `loose` option instead of `classProperties.loose`
     */
    classProperties?: {
        loose?: boolean;
    };
}
//# sourceMappingURL=babel.d.ts.map
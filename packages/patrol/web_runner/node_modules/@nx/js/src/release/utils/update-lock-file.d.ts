export declare function updateLockFile(cwd: string, { dryRun, verbose, options, }: {
    dryRun?: boolean;
    verbose?: boolean;
    options?: {
        skipLockFileUpdate?: boolean;
        installArgs?: string;
        installIgnoreScripts?: boolean;
    };
}): Promise<string[]>;
//# sourceMappingURL=update-lock-file.d.ts.map
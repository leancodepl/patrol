"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.compileTypeScript = compileTypeScript;
exports.compileTypeScriptWatcher = compileTypeScriptWatcher;
const devkit_1 = require("@nx/devkit");
const fs_1 = require("fs");
const ts_config_1 = require("../ts-config");
const typescript_1 = require("../typescript");
let tsModule;
function compileTypeScript(options) {
    const normalizedOptions = normalizeOptions(options);
    const tsConfig = getNormalizedTsConfig(normalizedOptions);
    if (normalizedOptions.deleteOutputPath) {
        (0, fs_1.rmSync)(normalizedOptions.outputPath, { recursive: true, force: true });
    }
    return createProgram(tsConfig, normalizedOptions);
}
function compileTypeScriptWatcher(options, callback) {
    if (!tsModule) {
        tsModule = (0, typescript_1.ensureTypescript)();
    }
    const normalizedOptions = normalizeOptions(options);
    const tsConfig = getNormalizedTsConfig(normalizedOptions);
    if (normalizedOptions.deleteOutputPath) {
        (0, fs_1.rmSync)(normalizedOptions.outputPath, { recursive: true, force: true });
    }
    const host = tsModule.createWatchCompilerHost(tsConfig.fileNames, tsConfig.options, tsModule.sys);
    const originalAfterProgramCreate = host.afterProgramCreate;
    host.afterProgramCreate = (builderProgram) => {
        const originalProgramEmit = builderProgram.emit;
        builderProgram.emit = (targetSourceFile, writeFile, cancellationToken, emitOnlyDtsFiles, customTransformers) => {
            const consumerCustomTransformers = options.getCustomTransformers?.(builderProgram.getProgram());
            const mergedCustomTransformers = mergeCustomTransformers(customTransformers, consumerCustomTransformers);
            return originalProgramEmit(targetSourceFile, writeFile, cancellationToken, emitOnlyDtsFiles, mergedCustomTransformers);
        };
        if (originalAfterProgramCreate)
            originalAfterProgramCreate(builderProgram);
    };
    const originalOnWatchStatusChange = host.onWatchStatusChange;
    host.onWatchStatusChange = async (a, b, c, d) => {
        originalOnWatchStatusChange?.(a, b, c, d);
        await callback?.(a, b, c, d);
    };
    return tsModule.createWatchProgram(host);
}
function mergeCustomTransformers(originalCustomTransformers, consumerCustomTransformers) {
    if (!consumerCustomTransformers)
        return originalCustomTransformers;
    const mergedCustomTransformers = {};
    if (consumerCustomTransformers.before) {
        mergedCustomTransformers.before = originalCustomTransformers?.before
            ? [
                ...originalCustomTransformers.before,
                ...consumerCustomTransformers.before,
            ]
            : consumerCustomTransformers.before;
    }
    if (consumerCustomTransformers.after) {
        mergedCustomTransformers.after = originalCustomTransformers?.after
            ? [
                ...originalCustomTransformers.after,
                ...consumerCustomTransformers.after,
            ]
            : consumerCustomTransformers.after;
    }
    if (consumerCustomTransformers.afterDeclarations) {
        mergedCustomTransformers.afterDeclarations =
            originalCustomTransformers?.afterDeclarations
                ? [
                    ...originalCustomTransformers.afterDeclarations,
                    ...consumerCustomTransformers.afterDeclarations,
                ]
                : consumerCustomTransformers.afterDeclarations;
    }
    return mergedCustomTransformers;
}
function getNormalizedTsConfig(options) {
    const tsConfig = (0, ts_config_1.readTsConfig)(options.tsConfig);
    tsConfig.options.outDir = options.outputPath;
    tsConfig.options.noEmitOnError = true;
    tsConfig.options.rootDir = options.rootDir;
    if (tsConfig.options.incremental && !tsConfig.options.tsBuildInfoFile) {
        tsConfig.options.tsBuildInfoFile = (0, devkit_1.joinPathFragments)(options.outputPath, 'tsconfig.tsbuildinfo');
    }
    return tsConfig;
}
function createProgram(tsconfig, { projectName, getCustomTransformers }) {
    if (!tsModule) {
        tsModule = (0, typescript_1.ensureTypescript)();
    }
    const host = tsModule.createCompilerHost(tsconfig.options);
    const program = tsModule.createProgram({
        rootNames: tsconfig.fileNames,
        options: tsconfig.options,
        host,
    });
    devkit_1.logger.info(`Compiling TypeScript files for project "${projectName}"...`);
    const results = program.emit(undefined, undefined, undefined, undefined, getCustomTransformers?.(program));
    if (results.emitSkipped) {
        const diagnostics = tsModule.formatDiagnosticsWithColorAndContext(results.diagnostics, {
            getCurrentDirectory: () => tsModule.sys.getCurrentDirectory(),
            getNewLine: () => tsModule.sys.newLine,
            getCanonicalFileName: (name) => name,
        });
        devkit_1.logger.error(diagnostics);
        return { success: false };
    }
    else {
        devkit_1.logger.info(`Done compiling TypeScript files for project "${projectName}".`);
        return { success: true };
    }
}
function normalizeOptions(options) {
    return {
        ...options,
        deleteOutputPath: options.deleteOutputPath ?? true,
        rootDir: options.rootDir ?? options.projectRoot,
    };
}

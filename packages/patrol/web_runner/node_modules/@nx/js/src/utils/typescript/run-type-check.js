"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.runTypeCheckWatch = runTypeCheckWatch;
exports.runTypeCheck = runTypeCheck;
exports.getFormattedDiagnostic = getFormattedDiagnostic;
const chalk = require("chalk");
const path = require("path");
const code_frames_1 = require("nx/src/utils/code-frames");
const highlight_1 = require("../code-frames/highlight");
const ts_config_1 = require("../../utils/typescript/ts-config");
async function runTypeCheckWatch(options, callback) {
    const { ts, workspaceRoot, config, compilerOptions } = await setupTypeScript(options);
    const host = ts.createWatchCompilerHost(config.fileNames, compilerOptions, ts.sys, ts.createEmitAndSemanticDiagnosticsBuilderProgram);
    const originalOnWatchStatusChange = host.onWatchStatusChange;
    host.onWatchStatusChange = (diagnostic, newLine, opts, errorCount) => {
        originalOnWatchStatusChange?.(diagnostic, newLine, opts, errorCount);
        callback(diagnostic, getFormattedDiagnostic(ts, workspaceRoot, diagnostic), errorCount);
    };
    const watchProgram = ts.createWatchProgram(host);
    const program = watchProgram.getProgram().getProgram();
    const diagnostics = options.ignoreDiagnostics
        ? []
        : ts.getPreEmitDiagnostics(program);
    return {
        close: watchProgram.close.bind(watchProgram),
        preEmitErrors: diagnostics
            .filter((d) => d.category === ts.DiagnosticCategory.Error)
            .map((d) => getFormattedDiagnostic(ts, workspaceRoot, d)),
        preEmitWarnings: diagnostics
            .filter((d) => d.category === ts.DiagnosticCategory.Warning)
            .map((d) => getFormattedDiagnostic(ts, workspaceRoot, d)),
    };
}
async function runTypeCheck(options) {
    const { ts, workspaceRoot, cacheDir, config, compilerOptions } = await setupTypeScript(options);
    let program;
    let incremental = false;
    if (compilerOptions.incremental && cacheDir) {
        incremental = true;
        program = ts.createIncrementalProgram({
            rootNames: config.fileNames,
            options: {
                ...compilerOptions,
                incremental: true,
                tsBuildInfoFile: path.join(cacheDir, '.tsbuildinfo'),
            },
        });
    }
    else {
        program = ts.createProgram(config.fileNames, compilerOptions);
    }
    const result = program.emit();
    const allDiagnostics = options.ignoreDiagnostics
        ? []
        : ts.getPreEmitDiagnostics(program).concat(result.diagnostics);
    return getTypeCheckResult(ts, allDiagnostics, workspaceRoot, config.fileNames.length, program.getSourceFiles().length, incremental);
}
async function setupTypeScript(options) {
    const ts = await Promise.resolve().then(() => require('typescript'));
    const { workspaceRoot, tsConfigPath, cacheDir, incremental, projectRoot } = options;
    const config = (0, ts_config_1.readTsConfig)(tsConfigPath);
    if (config.errors.length) {
        const errorMessages = config.errors.map((e) => e.messageText).join('\n');
        throw new Error(`Invalid config file due to following: ${errorMessages}`);
    }
    const emitOptions = options.mode === 'emitDeclarationOnly'
        ? {
            emitDeclarationOnly: true,
            declaration: true,
            outDir: options.outDir,
            declarationDir: options.projectRoot && options.outDir.indexOf(projectRoot)
                ? options.outDir.replace(projectRoot, '')
                : undefined,
        }
        : { noEmit: true };
    const compilerOptions = {
        ...config.options,
        skipLibCheck: true,
        ...emitOptions,
        incremental,
        rootDir: options.rootDir || config.options.rootDir,
    };
    return { ts, workspaceRoot, cacheDir, config, compilerOptions };
}
function getTypeCheckResult(ts, allDiagnostics, workspaceRoot, inputFilesCount, totalFilesCount, incremental = false) {
    const errors = allDiagnostics
        .filter((d) => d.category === ts.DiagnosticCategory.Error)
        .map((d) => getFormattedDiagnostic(ts, workspaceRoot, d));
    const warnings = allDiagnostics
        .filter((d) => d.category === ts.DiagnosticCategory.Warning)
        .map((d) => getFormattedDiagnostic(ts, workspaceRoot, d));
    return {
        warnings,
        errors,
        inputFilesCount,
        totalFilesCount,
        incremental,
    };
}
function getFormattedDiagnostic(ts, workspaceRoot, diagnostic) {
    let message = '';
    const reason = ts.flattenDiagnosticMessageText(diagnostic.messageText, '\n');
    const category = diagnostic.category;
    switch (category) {
        case ts.DiagnosticCategory.Warning: {
            message += `${chalk.yellow.bold('warning')} ${chalk.gray(`TS${diagnostic.code}`)}: `;
            break;
        }
        case ts.DiagnosticCategory.Error: {
            message += `${chalk.red.bold('error')} ${chalk.gray(`TS${diagnostic.code}`)}: `;
            break;
        }
        case ts.DiagnosticCategory.Suggestion:
        case ts.DiagnosticCategory.Message:
        default: {
            message += `${chalk.cyan.bold(category === 2 ? 'suggestion' : 'info')}: `;
            break;
        }
    }
    message += reason + '\n';
    if (diagnostic.file) {
        const pos = diagnostic.file.getLineAndCharacterOfPosition(diagnostic.start);
        const line = pos.line + 1;
        const column = pos.character + 1;
        const fileName = path.relative(workspaceRoot, diagnostic.file.fileName);
        message =
            `${chalk.underline.blue(`${fileName}:${line}:${column}`)} - ` + message;
        const code = diagnostic.file.getFullText(diagnostic.file.getSourceFile());
        message +=
            '\n' +
                (0, code_frames_1.codeFrameColumns)(code, {
                    start: { line: line, column },
                }, { highlight: highlight_1.highlight });
    }
    return message;
}

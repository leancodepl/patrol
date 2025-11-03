"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.formatDiagnosticReport = formatDiagnosticReport;
exports.formatSolutionBuilderStatusReport = formatSolutionBuilderStatusReport;
const ts = require("typescript");
// adapted from TS default diagnostic reporter
function formatDiagnosticReport(diagnostic, host) {
    const diagnostics = new Array(1);
    diagnostics[0] = diagnostic;
    const formattedDiagnostic = '\n' +
        ts.formatDiagnosticsWithColorAndContext(diagnostics, host) +
        host.getNewLine();
    diagnostics[0] = undefined;
    return formattedDiagnostic;
}
// adapted from TS default solution builder status reporter
function formatSolutionBuilderStatusReport(diagnostic) {
    let formattedDiagnostic = `[${formatColorAndReset(getLocaleTimeString(), ForegroundColorEscapeSequences.Grey)}] `;
    formattedDiagnostic += `${ts.flattenDiagnosticMessageText(diagnostic.messageText, ts.sys.newLine)}${ts.sys.newLine + ts.sys.newLine}`;
    return formattedDiagnostic;
}
function formatColorAndReset(text, formatStyle) {
    const resetEscapeSequence = '\u001b[0m';
    return formatStyle + text + resetEscapeSequence;
}
function getLocaleTimeString() {
    return new Date().toLocaleTimeString();
}
var ForegroundColorEscapeSequences;
(function (ForegroundColorEscapeSequences) {
    ForegroundColorEscapeSequences["Grey"] = "\u001B[90m";
    ForegroundColorEscapeSequences["Red"] = "\u001B[91m";
    ForegroundColorEscapeSequences["Yellow"] = "\u001B[93m";
    ForegroundColorEscapeSequences["Blue"] = "\u001B[94m";
    ForegroundColorEscapeSequences["Cyan"] = "\u001B[96m";
})(ForegroundColorEscapeSequences || (ForegroundColorEscapeSequences = {}));

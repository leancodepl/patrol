"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createEntryPoints = createEntryPoints;
const tinyglobby_1 = require("tinyglobby");
const devkit_1 = require("@nx/devkit");
function createEntryPoints(additionalEntryPoints, root) {
    if (!additionalEntryPoints?.length)
        return [];
    const files = [];
    // NOTE: calling globSync for each pattern is slower than calling it all at once.
    // We're doing it this way in order to show a warning for unmatched patterns.
    // If a pattern is unmatched, it is very likely a mistake by the user.
    // Performance impact should be negligible since there shouldn't be that many entry points.
    // Benchmarks show only 1-3% difference in execution time.
    for (const pattern of additionalEntryPoints) {
        const normalizedPattern = (0, devkit_1.normalizePath)(pattern);
        const matched = (0, tinyglobby_1.globSync)([normalizedPattern], {
            cwd: root,
            expandDirectories: false,
        });
        if (!matched.length)
            devkit_1.logger.warn(`The pattern ${normalizedPattern} did not match any files.`);
        files.push(...matched);
    }
    return files;
}

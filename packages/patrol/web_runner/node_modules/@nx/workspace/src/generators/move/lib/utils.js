"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.normalizePathSlashes = normalizePathSlashes;
const devkit_1 = require("@nx/devkit");
/**
 * Normalizes slashes (removes duplicates)
 *
 * @param input
 */
function normalizePathSlashes(input) {
    return ((0, devkit_1.normalizePath)(input)
        // strip leading ./ or /
        .replace(/^\.?\//, '')
        .split('/')
        .filter((x) => !!x)
        .join('/'));
}

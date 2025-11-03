"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ensureTypescript = ensureTypescript;
const devkit_1 = require("@nx/devkit");
const versions_1 = require("../versions");
function ensureTypescript() {
    return (0, devkit_1.ensurePackage)('typescript', versions_1.typescriptVersion);
}

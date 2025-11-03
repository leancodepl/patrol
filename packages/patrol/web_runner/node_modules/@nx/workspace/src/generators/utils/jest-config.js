"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.findRootJestConfig = findRootJestConfig;
function findRootJestConfig(tree) {
    if (tree.exists('jest.config.js')) {
        return 'jest.config.js';
    }
    if (tree.exists('jest.config.ts')) {
        return 'jest.config.ts';
    }
    return null;
}

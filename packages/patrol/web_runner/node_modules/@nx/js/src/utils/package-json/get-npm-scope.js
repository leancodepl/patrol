"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getNpmScope = getNpmScope;
const devkit_1 = require("@nx/devkit");
/**
 * Read the npm scope that a workspace should use by default
 */
function getNpmScope(tree) {
    const { name } = tree.exists('package.json')
        ? (0, devkit_1.readJson)(tree, 'package.json')
        : { name: null };
    if (name?.startsWith('@')) {
        return name.split('/')[0].substring(1);
    }
}

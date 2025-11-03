"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getImportPath = getImportPath;
exports.getNpmScope = getNpmScope;
const json_1 = require("nx/src/generators/utils/json");
function getImportPath(tree, projectDirectory) {
    const npmScope = getNpmScope(tree);
    return npmScope
        ? `${npmScope === '@' ? '' : '@'}${npmScope}/${projectDirectory}`
        : projectDirectory;
}
function getNpmScope(tree) {
    const { name } = tree.exists('package.json')
        ? (0, json_1.readJson)(tree, 'package.json')
        : { name: null };
    if (name?.startsWith('@')) {
        return name.split('/')[0].substring(1);
    }
}

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getWorkspacePath = getWorkspacePath;
exports.parseTarget = parseTarget;
exports.editTarget = editTarget;
exports.serializeTarget = serializeTarget;
/**
 * @deprecated Nx no longer supports workspace.json
 */
function getWorkspacePath(host) {
    const possibleFiles = ['/angular.json', '/workspace.json'];
    return possibleFiles.filter((path) => host.exists(path))[0];
}
function parseTarget(targetString) {
    const [project, target, config] = targetString.split(':');
    return {
        project,
        target,
        config,
    };
}
function editTarget(targetString, callback) {
    const parsedTarget = parseTarget(targetString);
    return serializeTarget(callback(parsedTarget));
}
/**
 * @deprecated use the utility from nx/src/utils instead
 */
function serializeTarget({ project, target, config }) {
    return [project, target, config].filter((part) => !!part).join(':');
}

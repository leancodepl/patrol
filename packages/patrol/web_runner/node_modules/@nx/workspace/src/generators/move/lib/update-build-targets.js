"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateBuildTargets = updateBuildTargets;
const devkit_1 = require("@nx/devkit");
/**
 * Update other references to the source project's targets
 */
function updateBuildTargets(tree, schema) {
    (0, devkit_1.getProjects)(tree).forEach((projectConfig, project) => {
        let changed = false;
        Object.entries(projectConfig.targets || {}).forEach(([target, targetConfig]) => {
            changed =
                updateJsonValue(targetConfig, (value) => {
                    const [project, target, configuration] = value.split(':');
                    if (project === schema.projectName && target) {
                        return configuration
                            ? `${schema.newProjectName}:${target}:${configuration}`
                            : `${schema.newProjectName}:${target}`;
                    }
                }) || changed;
        });
        if (changed) {
            (0, devkit_1.updateProjectConfiguration)(tree, project, projectConfig);
        }
    });
}
function updateJsonValue(config, callback) {
    function recur(obj, key, value) {
        let changed = false;
        if (typeof value === 'string') {
            const result = callback(value);
            if (result && obj[key] !== result) {
                obj[key] = result;
                changed = true;
            }
        }
        else if (Array.isArray(value)) {
            value.forEach((x, idx) => recur(value, idx, x));
        }
        else if (typeof value === 'object') {
            Object.entries(value).forEach(([k, v]) => {
                changed = recur(value, k, v) || changed;
            });
        }
        return changed;
    }
    let changed = false;
    Object.entries(config).forEach(([k, v]) => {
        changed = recur(config, k, v) || changed;
    });
    return changed;
}

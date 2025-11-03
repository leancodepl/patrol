"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.runCommandsGenerator = runCommandsGenerator;
const devkit_1 = require("@nx/devkit");
async function runCommandsGenerator(host, schema) {
    const project = (0, devkit_1.readProjectConfiguration)(host, schema.project);
    project.targets = project.targets || {};
    project.targets[schema.name] = {
        executor: 'nx:run-commands',
        outputs: schema.outputs
            ? schema.outputs
                .split(',')
                .map((s) => (0, devkit_1.joinPathFragments)('{workspaceRoot}', s.trim()))
            : [],
        options: {
            command: schema.command,
            cwd: schema.cwd,
            envFile: schema.envFile,
        },
    };
    (0, devkit_1.updateProjectConfiguration)(host, schema.project, project);
    await (0, devkit_1.formatFiles)(host);
}
exports.default = runCommandsGenerator;

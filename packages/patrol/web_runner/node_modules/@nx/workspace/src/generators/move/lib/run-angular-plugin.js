"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.runAngularPlugin = runAngularPlugin;
async function runAngularPlugin(tree, schema) {
    let move;
    try {
        // nx-ignore-next-line
        move = require('@nx/angular/src/generators/move/move-impl').move;
    }
    catch { }
    if (!move) {
        return;
    }
    await move(tree, {
        oldProjectName: schema.projectName,
        newProjectName: schema.newProjectName,
    });
}

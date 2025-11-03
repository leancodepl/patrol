"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.addBabelInputs = addBabelInputs;
const devkit_1 = require("@nx/devkit");
/** @deprecated Do not use this function as the root babel.config.json file is no longer needed */
// TODO(jack): Remove This in Nx 17 once we don't need to support Nx 15 anymore. Currently this function is used in v15 migrations.
function addBabelInputs(tree) {
    const nxJson = (0, devkit_1.readNxJson)(tree);
    let globalBabelFile = ['babel.config.js', 'babel.config.json'].find((file) => tree.exists(file));
    if (!globalBabelFile) {
        (0, devkit_1.writeJson)(tree, '/babel.config.json', {
            babelrcRoots: ['*'], // Make sure .babelrc files other than root can be loaded in a monorepo
        });
        globalBabelFile = 'babel.config.json';
    }
    if (nxJson.namedInputs?.sharedGlobals) {
        const sharedGlobalFileset = new Set(nxJson.namedInputs.sharedGlobals);
        sharedGlobalFileset.add((0, devkit_1.joinPathFragments)('{workspaceRoot}', globalBabelFile));
        nxJson.namedInputs.sharedGlobals = Array.from(sharedGlobalFileset);
    }
    (0, devkit_1.updateNxJson)(tree, nxJson);
}

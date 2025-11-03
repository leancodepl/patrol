"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateEslintConfig = updateEslintConfig;
const devkit_1 = require("@nx/devkit");
/**
 * Update the .eslintrc file of the project if it exists.
 *
 * @param schema The options provided to the schematic
 */
function updateEslintConfig(tree, schema, project) {
    // if there is no suitable eslint config, we don't need to do anything
    if (!tree.exists('.eslintrc.json') &&
        !tree.exists('eslint.config.js') &&
        !tree.exists('eslint.config.cjs') &&
        !tree.exists('eslint.config.mjs') &&
        !tree.exists('.eslintrc.base.json') &&
        !tree.exists('eslint.base.config.js') &&
        !tree.exists('eslint.base.config.cjs') &&
        !tree.exists('eslint.base.config.mjs')) {
        return;
    }
    try {
        const { updateRelativePathsInConfig,
        // nx-ignore-next-line
         } = require('@nx/eslint/src/generators/utils/eslint-file');
        updateRelativePathsInConfig(tree, project.root, schema.relativeToRootDestination);
    }
    catch {
        devkit_1.output.warn({
            title: `Could not update the eslint config file.`,
            bodyLines: [
                'The @nx/eslint package could not be loaded. Please update the paths in eslint config manually.',
            ],
        });
    }
}

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateCypressConfig = updateCypressConfig;
const path = require("path");
/**
 * Updates the videos and screenshots folders in the cypress.json/cypress.config.ts if it exists (i.e. we're moving an e2e project)
 *
 * (assume relative paths have been updated previously)
 *
 * @param schema The options provided to the schematic
 */
function updateCypressConfig(tree, schema, project) {
    const cypressJsonPath = path.join(schema.relativeToRootDestination, 'cypress.json');
    if (tree.exists(cypressJsonPath)) {
        const cypressJson = JSON.parse(tree.read(cypressJsonPath).toString('utf-8'));
        // videosFolder is not required because videos can be turned off - it also has a default
        if (cypressJson.videosFolder) {
            cypressJson.videosFolder = cypressJson.videosFolder.replace(project.root, schema.relativeToRootDestination);
        }
        // screenshotsFolder is not required as it has a default
        if (cypressJson.screenshotsFolder) {
            cypressJson.screenshotsFolder = cypressJson.screenshotsFolder.replace(project.root, schema.relativeToRootDestination);
        }
        tree.write(cypressJsonPath, JSON.stringify(cypressJson));
        return tree;
    }
    const cypressConfigPath = path.join(schema.relativeToRootDestination, 'cypress.config.ts');
    // Search and replace for "e2e" directory is not safe, and will result in an invalid config file.
    // Leave it and let users fix the config if needed.
    if (project.root !== 'e2e' && tree.exists(cypressConfigPath)) {
        const oldContent = tree.read(cypressConfigPath, 'utf-8');
        const findName = new RegExp(`'${schema.projectName}'`, 'g');
        const findDir = new RegExp(project.root, 'g');
        const newContent = oldContent
            .replace(findName, `'${schema.newProjectName}'`)
            .replace(findDir, schema.relativeToRootDestination);
        tree.write(cypressConfigPath, newContent);
    }
}

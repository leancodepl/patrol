"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.newGenerator = newGenerator;
const devkit_1 = require("@nx/devkit");
const path_1 = require("path");
const presets_1 = require("../utils/presets");
const generate_workspace_files_1 = require("./generate-workspace-files");
const generate_preset_1 = require("./generate-preset");
const child_process_1 = require("child_process");
async function newGenerator(tree, opts) {
    const options = normalizeOptions(opts);
    validateOptions(options, tree);
    const { token, aiAgentsCallback } = await (0, generate_workspace_files_1.generateWorkspaceFiles)(tree, options);
    options.nxCloudToken = token;
    (0, generate_preset_1.addPresetDependencies)(tree, options);
    await (0, devkit_1.formatFiles)(tree);
    return async () => {
        if (!options.skipInstall) {
            const pmc = (0, devkit_1.getPackageManagerCommand)(options.packageManager);
            if (pmc.preInstall) {
                (0, child_process_1.execSync)(pmc.preInstall, {
                    cwd: (0, devkit_1.joinPathFragments)(tree.root, options.directory),
                    stdio: process.env.NX_GENERATE_QUIET === 'true' ? 'ignore' : 'inherit',
                    windowsHide: false,
                });
            }
            (0, devkit_1.installPackagesTask)(tree, false, options.directory, options.packageManager);
        }
        // TODO: move all of these into create-nx-workspace
        if (options.preset !== presets_1.Preset.NPM && !options.isCustomPreset) {
            await (0, generate_preset_1.generatePreset)(tree, options);
        }
        // if we move this into create-nx-workspace, we can also easily log things out like nx console install success
        if (aiAgentsCallback) {
            await aiAgentsCallback();
        }
    };
}
exports.default = newGenerator;
function validateOptions(options, host) {
    if (options.skipInstall &&
        options.preset !== presets_1.Preset.Apps &&
        options.preset !== presets_1.Preset.TS &&
        options.preset !== presets_1.Preset.NPM) {
        throw new Error(`Cannot select a preset when skipInstall is set to true.`);
    }
    if ((options.preset === presets_1.Preset.NodeStandalone ||
        options.preset === presets_1.Preset.NodeMonorepo) &&
        !options.framework) {
        throw new Error(`Cannot generate ${options.preset} without selecting a framework`);
    }
    if (host.exists(options.name) &&
        !host.isFile(options.name) &&
        host.children(options.name).length > 0) {
        throw new Error(`${(0, path_1.join)(host.root, options.name)} is not an empty directory.`);
    }
}
function parsePresetName(input) {
    // If the preset already contains a version in the name
    // -- my-package@2.0.1
    // -- @scope/package@version
    const atIndex = input.indexOf('@', 1); // Skip the beginning @ because it denotes a scoped package.
    if (atIndex > 0) {
        return {
            package: input.slice(0, atIndex),
            version: input.slice(atIndex + 1),
        };
    }
    else {
        if (!input) {
            throw new Error(`Invalid package name: ${input}`);
        }
        return { package: input };
    }
}
function normalizeOptions(options) {
    const normalized = {
        ...options,
        workspaceGlobs: Array.isArray(options.workspaceGlobs)
            ? options.workspaceGlobs
            : options.workspaceGlobs
                ? [options.workspaceGlobs]
                : undefined,
        aiAgents: Array.isArray(options.aiAgents)
            ? options.aiAgents
            : options.aiAgents
                ? [options.aiAgents]
                : undefined,
    };
    if (!options.directory) {
        normalized.directory = normalized.name;
    }
    const parsed = parsePresetName(options.preset);
    normalized.preset = parsed.package;
    // explicitly specified "presetVersion" takes priority over the one from the package name
    normalized.presetVersion ??= parsed.version;
    normalized.isCustomPreset = !Object.values(presets_1.Preset).includes(options.preset);
    return normalized;
}

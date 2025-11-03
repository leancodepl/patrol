"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.copyAssets = copyAssets;
const copy_assets_handler_1 = require("./copy-assets-handler");
const devkit_1 = require("@nx/devkit");
async function copyAssets(options, context) {
    const assetHandler = new copy_assets_handler_1.CopyAssetsHandler({
        projectDir: context.projectsConfigurations.projects[context.projectName].root,
        rootDir: context.root,
        outputDir: options.outputPath,
        assets: options.assets,
        callback: typeof options?.watch === 'object' ? options.watch.onCopy : undefined,
        includeIgnoredFiles: options.includeIgnoredAssetFiles,
    });
    const result = {
        success: true,
    };
    if (!(0, devkit_1.isDaemonEnabled)() && options.watch) {
        devkit_1.output.warn({
            title: 'Nx Daemon is not enabled. Assets will not be updated when they are changed.',
        });
    }
    if ((0, devkit_1.isDaemonEnabled)() && options.watch) {
        result.stop = await assetHandler.watchAndProcessOnAssetChange();
    }
    try {
        await assetHandler.processAllAssetsOnce();
    }
    catch {
        result.success = false;
    }
    return result;
}

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getCatalogManager = getCatalogManager;
const devkit_exports_1 = require("nx/src/devkit-exports");
const pnpm_manager_1 = require("./pnpm-manager");
/**
 * Factory function to get the appropriate catalog manager based on the package manager
 */
function getCatalogManager(workspaceRoot) {
    const packageManager = (0, devkit_exports_1.detectPackageManager)(workspaceRoot);
    switch (packageManager) {
        case 'pnpm':
            return new pnpm_manager_1.PnpmCatalogManager();
        default:
            return null;
    }
}

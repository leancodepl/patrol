"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.packageExists = packageExists;
/**
 * Checks if package is available
 * @param name name of the package
 * @returns
 */
function packageExists(name) {
    try {
        require.resolve(name);
        return true;
    }
    catch {
        return false;
    }
}

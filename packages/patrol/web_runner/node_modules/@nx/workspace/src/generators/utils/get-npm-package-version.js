"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getNpmPackageVersion = getNpmPackageVersion;
function getNpmPackageVersion(packageName, packageVersion) {
    try {
        const version = require('child_process').execSync(`npm view ${packageName}${packageVersion ? '@' + packageVersion : ''} version --json`, {
            stdio: ['pipe', 'pipe', 'ignore'],
            windowsHide: false,
        });
        if (version) {
            // package@1.12 => ["1.12.0", "1.12.1"]
            // package@1.12.1 => "1.12.1"
            // package@latest => "1.12.1"
            const versionOrArray = JSON.parse(version.toString());
            if (typeof versionOrArray === 'string') {
                return versionOrArray;
            }
            return versionOrArray.pop();
        }
    }
    catch (err) { }
    return packageVersion ?? null;
}

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isValidRange = isValidRange;
exports.isMatchingDependencyRange = isMatchingDependencyRange;
const semver_1 = require("semver");
function isValidRange(range) {
    // valid() will return null if a range (including ~,^,*) is used
    // Check that it is null, and therefore a range
    return !(0, semver_1.valid)(range) && (0, semver_1.validRange)(range) !== null;
}
function isMatchingDependencyRange(version, range) {
    const coercedVersion = (0, semver_1.coerce)(version, { includePrerelease: true })?.version;
    return isValidRange(range) && (0, semver_1.satisfies)(coercedVersion, range);
}

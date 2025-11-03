"use strict";
/**
 * Special thanks to changelogen for the original inspiration for many of these utilities:
 * https://github.com/unjs/changelogen
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.SemverSpecifierType = void 0;
exports.isRelativeVersionKeyword = isRelativeVersionKeyword;
exports.isValidSemverSpecifier = isValidSemverSpecifier;
exports.determineSemverChange = determineSemverChange;
exports.deriveNewSemverVersion = deriveNewSemverVersion;
const semver_1 = require("semver");
exports.SemverSpecifierType = {
    3: 'major',
    2: 'minor',
    1: 'patch',
};
function isRelativeVersionKeyword(val) {
    return semver_1.RELEASE_TYPES.includes(val);
}
function isValidSemverSpecifier(specifier) {
    return (specifier && !!((0, semver_1.valid)(specifier) || isRelativeVersionKeyword(specifier)));
}
function determineSemverChange(relevantCommits, config) {
    const semverChangePerProject = new Map();
    for (const [projectName, relevantCommit] of relevantCommits) {
        let highestChange = null;
        for (const { commit, isProjectScopedCommit } of relevantCommit) {
            if (!isProjectScopedCommit) {
                // commit is relevant to the project, but not directly, report patch change to match side-effectful bump behavior in update dependents in release-group-processor
                highestChange = Math.max(1 /* SemverSpecifier.PATCH */, highestChange ?? 0);
                continue;
            }
            const semverType = config.types[commit.type]?.semverBump;
            if (semverType === 'major' || commit.isBreaking) {
                highestChange = Math.max(3 /* SemverSpecifier.MAJOR */, highestChange ?? 0);
                break; // Major is highest priority, no need to check more commits
            }
            else if (semverType === 'minor') {
                highestChange = Math.max(2 /* SemverSpecifier.MINOR */, highestChange ?? 0);
            }
            else if (semverType === 'patch') {
                highestChange = Math.max(1 /* SemverSpecifier.PATCH */, highestChange ?? 0);
            }
        }
        semverChangePerProject.set(projectName, highestChange);
    }
    return semverChangePerProject;
}
function deriveNewSemverVersion(currentSemverVersion, semverSpecifier, preid) {
    if (!(0, semver_1.valid)(currentSemverVersion)) {
        throw new Error(`Invalid semver version "${currentSemverVersion}" provided.`);
    }
    let newVersion = semverSpecifier;
    if (isRelativeVersionKeyword(semverSpecifier)) {
        // Derive the new version from the current version combined with the new version specifier.
        const derivedVersion = (0, semver_1.inc)(currentSemverVersion, semverSpecifier, preid);
        if (!derivedVersion) {
            throw new Error(`Unable to derive new version from current version "${currentSemverVersion}" and version specifier "${semverSpecifier}"`);
        }
        newVersion = derivedVersion;
    }
    else {
        // Ensure the new version specifier is a valid semver version, given it is not a valid semver keyword
        if (!(0, semver_1.valid)(semverSpecifier)) {
            throw new Error(`Invalid semver version specifier "${semverSpecifier}" provided. Please provide either a valid semver version or a valid semver version keyword.`);
        }
    }
    return newVersion;
}

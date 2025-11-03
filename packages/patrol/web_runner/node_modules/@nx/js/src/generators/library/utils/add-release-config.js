"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.addReleaseConfigForTsSolution = addReleaseConfigForTsSolution;
exports.addReleaseConfigForNonTsSolution = addReleaseConfigForNonTsSolution;
exports.releaseTasks = releaseTasks;
const devkit_1 = require("@nx/devkit");
const find_matching_projects_1 = require("nx/src/utils/find-matching-projects");
const generator_1 = require("../../setup-verdaccio/generator");
/**
 * Adds release option in nx.json to build the project before versioning
 */
async function addReleaseConfigForTsSolution(tree, projectName, projectConfiguration) {
    const nxJson = (0, devkit_1.readNxJson)(tree);
    const addPreVersionCommand = () => {
        const pmc = (0, devkit_1.getPackageManagerCommand)();
        nxJson.release = {
            ...nxJson.release,
            version: {
                preVersionCommand: `${pmc.dlx} nx run-many -t build`,
                ...nxJson.release?.version,
            },
        };
    };
    // if the release configuration does not exist, it will be created
    if (!nxJson.release || (!nxJson.release.projects && !nxJson.release.groups)) {
        // skip adding any projects configuration since the new project should be
        // automatically included by nx release's default project detection logic
        addPreVersionCommand();
        (0, devkit_1.writeJson)(tree, 'nx.json', nxJson);
        return;
    }
    const project = {
        name: projectName,
        type: 'lib',
        data: {
            root: projectConfiguration.root,
            tags: projectConfiguration.tags,
        },
    };
    // if the project is already included in the release configuration, it will not be added again
    if (projectsConfigMatchesProject(nxJson.release.projects, project)) {
        devkit_1.output.log({
            title: `Project already included in existing release configuration`,
        });
        addPreVersionCommand();
        (0, devkit_1.writeJson)(tree, 'nx.json', nxJson);
        return;
    }
    // if the release configuration is a string, it will be converted to an array and added to it
    if (Array.isArray(nxJson.release.projects)) {
        nxJson.release.projects.push(projectName);
        addPreVersionCommand();
        (0, devkit_1.writeJson)(tree, 'nx.json', nxJson);
        devkit_1.output.log({
            title: `Added project to existing release configuration`,
        });
    }
    if (nxJson.release.groups) {
        const allGroups = Object.entries(nxJson.release.groups);
        for (const [name, group] of allGroups) {
            if (projectsConfigMatchesProject(group.projects, project)) {
                addPreVersionCommand();
                (0, devkit_1.writeJson)(tree, 'nx.json', nxJson);
                devkit_1.output.log({
                    title: `Project already included in existing release configuration for group ${name}`,
                });
                return;
            }
        }
        devkit_1.output.warn({
            title: `Could not find a release group that includes ${projectName}`,
            bodyLines: [
                `Ensure that ${projectName} is included in a release group's "projects" list in nx.json so it can be published with "nx release"`,
            ],
        });
        addPreVersionCommand();
        (0, devkit_1.writeJson)(tree, 'nx.json', nxJson);
        return;
    }
    if (typeof nxJson.release.projects === 'string') {
        nxJson.release.projects = [nxJson.release.projects, projectName];
        addPreVersionCommand();
        (0, devkit_1.writeJson)(tree, 'nx.json', nxJson);
        devkit_1.output.log({
            title: `Added project to existing release configuration`,
        });
        return;
    }
}
/**
 * Add release configuration for non-ts solution projects
 * Add release option in project.json and add packageRoot to nx-release-publish target
 */
async function addReleaseConfigForNonTsSolution(tree, projectName, projectConfiguration, defaultOutputDirectory = 'dist') {
    const packageRoot = (0, devkit_1.joinPathFragments)(defaultOutputDirectory, '{projectRoot}');
    projectConfiguration.targets ??= {};
    projectConfiguration.targets['nx-release-publish'] = {
        options: {
            packageRoot,
        },
    };
    projectConfiguration.release = {
        version: {
            manifestRootsToUpdate: [packageRoot],
            // using git tags to determine the current version is required here because
            // the version in the package root is overridden with every build
            currentVersionResolver: 'git-tag',
            fallbackCurrentVersionResolver: 'disk',
        },
    };
    await addReleaseConfigForTsSolution(tree, projectName, projectConfiguration);
    return projectConfiguration;
}
function projectsConfigMatchesProject(projectsConfig, project) {
    if (!projectsConfig) {
        return false;
    }
    if (typeof projectsConfig === 'string') {
        projectsConfig = [projectsConfig];
    }
    const graph = {
        [project.name]: project,
    };
    const matchingProjects = (0, find_matching_projects_1.findMatchingProjects)(projectsConfig, graph);
    return matchingProjects.includes(project.name);
}
async function releaseTasks(tree) {
    return (0, devkit_1.runTasksInSerial)(await (0, generator_1.default)(tree, { skipFormat: true }), () => logNxReleaseDocsInfo());
}
function logNxReleaseDocsInfo() {
    devkit_1.output.log({
        title: `📦 To learn how to publish this library, see https://nx.dev/core-features/manage-releases.`,
    });
}

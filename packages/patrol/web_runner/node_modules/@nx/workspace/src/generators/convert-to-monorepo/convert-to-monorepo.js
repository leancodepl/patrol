"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.monorepoGenerator = monorepoGenerator;
const devkit_1 = require("@nx/devkit");
const move_1 = require("../move/move");
const ts_solution_setup_1 = require("../../utils/ts-solution-setup");
async function monorepoGenerator(tree, options) {
    const projects = (0, devkit_1.getProjects)(tree);
    const nxJson = (0, devkit_1.readNxJson)(tree);
    (0, devkit_1.updateNxJson)(tree, nxJson);
    let rootProject;
    const projectsToMove = [];
    // Need to determine libs vs packages directory base on the type of root project.
    for (const [, project] of projects) {
        if (project.root === '.') {
            rootProject = project;
        }
        else {
            projectsToMove.push(project);
        }
    }
    projectsToMove.unshift(rootProject); // move the root project 1st
    // Currently, Nx only handles apps+libs or packages. You cannot mix and match them.
    // If the standalone project is an app (React, Angular, etc), then use apps+libs.
    // Otherwise, for TS standalone (lib), use packages.
    const isRootProjectApp = (0, ts_solution_setup_1.getProjectType)(tree, rootProject.root, rootProject.projectType) ===
        'application';
    const appsDir = isRootProjectApp ? 'apps' : 'packages';
    const libsDir = isRootProjectApp ? 'libs' : 'packages';
    if (rootProject) {
        // If project was created using `nx init` then it might not have project.json.
        // Need to create one to avoid name conflicts with root package.json.
        if (!tree.exists('project.json')) {
            (0, devkit_1.writeJson)(tree, 'project.json', { name: rootProject.name });
        }
        (0, devkit_1.updateJson)(tree, 'package.json', (json) => {
            // Avoid name conflicts once we move root project into its own folder.
            json.name = `@${rootProject.name}/source`;
            return json;
        });
    }
    for (const project of projectsToMove) {
        const projectType = (0, ts_solution_setup_1.getProjectType)(tree, project.root, project.projectType);
        await (0, move_1.moveGenerator)(tree, {
            projectName: project.name,
            newProjectName: project.name,
            destination: projectType === 'application'
                ? (0, devkit_1.joinPathFragments)(appsDir, project.root === '.' ? project.name : project.root)
                : (0, devkit_1.joinPathFragments)(libsDir, project.root === '.' ? project.name : project.root),
            updateImportPath: projectType === 'library',
        });
    }
}
exports.default = monorepoGenerator;

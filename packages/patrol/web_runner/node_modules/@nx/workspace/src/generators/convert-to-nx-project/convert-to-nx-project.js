"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateSchema = validateSchema;
exports.convertToNxProjectGenerator = convertToNxProjectGenerator;
const devkit_1 = require("@nx/devkit");
const path_1 = require("path");
const angular_json_1 = require("nx/src/adapter/angular-json");
const output_1 = require("../../utils/output");
async function validateSchema(schema, configName) {
    if (schema.project && schema.all) {
        throw new Error('--project and --all are mutually exclusive');
    }
    if (schema.project && schema.reformat) {
        throw new Error('--project and --reformat are mutually exclusive');
    }
    if (schema.all && schema.reformat) {
        throw new Error('--all and --reformat are mutually exclusive');
    }
    if ((configName === 'workspace.json' && schema.project) ||
        (configName === 'workspace.json' && schema.reformat)) {
        throw new Error('workspace.json is no longer supported. Please pass --all to convert all projects and remove workspace.json.');
    }
    if (!schema.project && !schema.all && !schema.reformat) {
        schema.all = true;
    }
}
async function convertToNxProjectGenerator(host, schema) {
    const configName = host.exists('angular.json')
        ? 'angular.json'
        : 'workspace.json';
    if (!host.exists(configName))
        return;
    await validateSchema(schema, configName);
    const projects = (0, angular_json_1.toNewFormat)((0, devkit_1.readJson)(host, configName)).projects;
    const leftOverProjects = {};
    for (const projectName of Object.keys(projects)) {
        const config = projects[projectName];
        if ((!schema.project || schema.project === projectName) &&
            !schema.reformat) {
            if (typeof config === 'string') {
                // configuration is in project.json
                const projectConfig = (0, devkit_1.readJson)(host, (0, path_1.join)(config, 'project.json'));
                if (projectConfig.name !== projectName) {
                    projectConfig.name = projectName;
                    projectConfig.root = config;
                    (0, devkit_1.updateProjectConfiguration)(host, projectName, projectConfig);
                }
            }
            else {
                // configuration is an object in workspace.json
                const path = (0, path_1.join)(config.root, 'project.json');
                if (!host.exists(path)) {
                    projects[projectName].name = projectName;
                    (0, devkit_1.addProjectConfiguration)(host, path, projects[projectName]);
                }
            }
        }
        else {
            leftOverProjects[projectName] = config;
        }
    }
    if (Object.keys(leftOverProjects).length > 0) {
        (0, devkit_1.writeJson)(host, 'angular.json', (0, angular_json_1.toOldFormat)({ version: 1, projects: leftOverProjects }));
    }
    else {
        host.delete(configName);
    }
    if (!schema.skipFormat) {
        await (0, devkit_1.formatFiles)(host);
    }
    output_1.output.note({
        title: 'Use "nx show projects" to read the list of projects.',
        bodyLines: [
            `If you read the list of projects from ${configName}, use "nx show projects" instead.`,
        ],
    });
}
exports.default = convertToNxProjectGenerator;

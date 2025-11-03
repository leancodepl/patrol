"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.determineAiAgents = determineAiAgents;
const enquirer_1 = require("enquirer");
const is_ci_1 = require("../../utils/is-ci");
const utils_1 = require("../../ai/utils");
const chalk = require("chalk");
async function determineAiAgents(aiAgents, interactive) {
    if (interactive === false || (0, is_ci_1.isCI)()) {
        return aiAgents ?? [];
    }
    if (aiAgents) {
        return aiAgents;
    }
    return await aiAgentsPrompt();
}
async function aiAgentsPrompt() {
    const promptConfig = {
        name: 'agents',
        message: 'Which AI agents, if any, would you like to set up?',
        type: 'multiselect',
        choices: utils_1.supportedAgents.map((a) => ({
            name: a,
            message: utils_1.agentDisplayMap[a],
        })),
        footer: () => chalk.dim('Multiple selections possible. <Space> to select. <Enter> to confirm.'),
    };
    return (await (0, enquirer_1.prompt)([promptConfig])).agents;
}

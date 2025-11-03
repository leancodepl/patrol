"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.normalizeLinterOption = normalizeLinterOption;
exports.normalizeUnitTestRunnerOption = normalizeUnitTestRunnerOption;
const prompt_1 = require("@nx/devkit/src/generators/prompt");
const ts_solution_setup_1 = require("./typescript/ts-solution-setup");
async function normalizeLinterOption(tree, linter) {
    if (linter) {
        return linter;
    }
    const isTsSolutionSetup = (0, ts_solution_setup_1.isUsingTsSolutionSetup)(tree);
    const choices = isTsSolutionSetup
        ? [{ name: 'none' }, { name: 'eslint' }]
        : [{ name: 'eslint' }, { name: 'none' }];
    const defaultValue = isTsSolutionSetup ? 'none' : 'eslint';
    return await (0, prompt_1.promptWhenInteractive)({
        type: 'autocomplete',
        name: 'linter',
        message: `Which linter would you like to use?`,
        choices,
        initial: 0,
    }, { linter: defaultValue }).then(({ linter }) => linter);
}
async function normalizeUnitTestRunnerOption(tree, unitTestRunner, testRunners = ['jest', 'vitest']) {
    if (unitTestRunner) {
        return unitTestRunner;
    }
    const isTsSolutionSetup = (0, ts_solution_setup_1.isUsingTsSolutionSetup)(tree);
    const choices = isTsSolutionSetup
        ? [{ name: 'none' }, ...testRunners.map((runner) => ({ name: runner }))]
        : [...testRunners.map((runner) => ({ name: runner })), { name: 'none' }];
    const defaultValue = (isTsSolutionSetup ? 'none' : testRunners[0]);
    return await (0, prompt_1.promptWhenInteractive)({
        type: 'autocomplete',
        name: 'unitTestRunner',
        message: `Which unit test runner would you like to use?`,
        choices,
        initial: 0,
    }, { unitTestRunner: defaultValue }).then(({ unitTestRunner }) => unitTestRunner);
}

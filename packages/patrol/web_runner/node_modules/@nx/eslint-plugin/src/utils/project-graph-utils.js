"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ensureGlobalProjectGraph = ensureGlobalProjectGraph;
exports.readProjectGraph = readProjectGraph;
const devkit_1 = require("@nx/devkit");
const runtime_lint_utils_1 = require("./runtime-lint-utils");
const chalk = require("chalk");
const find_project_for_path_1 = require("nx/src/project-graph/utils/find-project-for-path");
const configuration_1 = require("nx/src/config/configuration");
const internal_1 = require("@nx/js/src/internal");
const nx_deps_cache_1 = require("nx/src/project-graph/nx-deps-cache");
function ensureGlobalProjectGraph(ruleName) {
    /**
     * Only reuse graph when running from terminal
     * Enforce every IDE change to get a fresh nxdeps.json
     */
    if (!globalThis.projectGraph ||
        !globalThis.projectRootMappings ||
        !globalThis.projectFileMap ||
        !(0, runtime_lint_utils_1.isTerminalRun)()) {
        const nxJson = (0, configuration_1.readNxJson)();
        globalThis.workspaceLayout = nxJson.workspaceLayout;
        /**
         * Because there are a number of ways in which the rule can be invoked (executor vs ESLint CLI vs IDE Plugin),
         * the ProjectGraph may or may not exist by the time the lint rule is invoked for the first time.
         */
        try {
            const projectGraph = (0, devkit_1.readCachedProjectGraph)();
            globalThis.projectGraph = projectGraph;
            globalThis.projectRootMappings = (0, find_project_for_path_1.createProjectRootMappings)(projectGraph.nodes);
            globalThis.projectFileMap = (0, nx_deps_cache_1.readFileMapCache)().fileMap.projectFileMap;
            globalThis.targetProjectLocator = new internal_1.TargetProjectLocator(projectGraph.nodes, projectGraph.externalNodes);
        }
        catch {
            const WARNING_PREFIX = `${chalk.reset.keyword('orange')('warning')}`;
            const RULE_NAME_SUFFIX = `${chalk.reset.dim(`@nx/${ruleName}`)}`;
            process.stdout
                .write(`${WARNING_PREFIX} No cached ProjectGraph is available. The rule will be skipped.
          If you encounter this error as part of running standard \`nx\` commands then please open an issue on https://github.com/nrwl/nx
          ${RULE_NAME_SUFFIX}\n`);
        }
    }
}
function readProjectGraph(ruleName) {
    ensureGlobalProjectGraph(ruleName);
    return {
        projectGraph: globalThis.projectGraph,
        projectFileMap: globalThis.projectFileMap,
        projectRootMappings: globalThis.projectRootMappings,
        targetProjectLocator: globalThis.targetProjectLocator,
    };
}

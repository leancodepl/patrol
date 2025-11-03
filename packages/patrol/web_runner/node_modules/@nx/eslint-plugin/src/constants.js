"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.WORKSPACE_RULE_PREFIX = exports.WORKSPACE_PLUGIN_DIR = exports.WORKSPACE_RULES_PATH = void 0;
const devkit_1 = require("@nx/devkit");
const path_1 = require("path");
exports.WORKSPACE_RULES_PATH = 'tools/eslint-rules';
exports.WORKSPACE_PLUGIN_DIR = (0, path_1.join)(devkit_1.workspaceRoot, exports.WORKSPACE_RULES_PATH);
/**
 * We add a namespace so that we mitigate the risk of rule name collisions as much as
 * possible between what users might create in their workspaces and what we might want
 * to offer directly in @nx/eslint-plugin in the future.
 *
 * E.g. if a user writes a rule called "foo", then they will include it in their ESLint
 * config files as:
 *
 * "@nx/workspace-foo": "error"
 */
exports.WORKSPACE_RULE_PREFIX = 'workspace';

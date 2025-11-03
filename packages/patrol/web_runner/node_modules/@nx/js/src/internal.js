"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.findProjectsNpmDependencies = exports.isBuiltinModuleImport = exports.TargetProjectLocator = exports.registerTsConfigPaths = exports.registerTsProject = exports.resolveModuleByImport = void 0;
var ast_utils_1 = require("./utils/typescript/ast-utils");
Object.defineProperty(exports, "resolveModuleByImport", { enumerable: true, get: function () { return ast_utils_1.resolveModuleByImport; } });
// eslint-disable-next-line @typescript-eslint/no-restricted-imports
var register_1 = require("nx/src/plugins/js/utils/register");
Object.defineProperty(exports, "registerTsProject", { enumerable: true, get: function () { return register_1.registerTsProject; } });
Object.defineProperty(exports, "registerTsConfigPaths", { enumerable: true, get: function () { return register_1.registerTsConfigPaths; } });
// eslint-disable-next-line @typescript-eslint/no-restricted-imports
var target_project_locator_1 = require("nx/src/plugins/js/project-graph/build-dependencies/target-project-locator");
Object.defineProperty(exports, "TargetProjectLocator", { enumerable: true, get: function () { return target_project_locator_1.TargetProjectLocator; } });
Object.defineProperty(exports, "isBuiltinModuleImport", { enumerable: true, get: function () { return target_project_locator_1.isBuiltinModuleImport; } });
// eslint-disable-next-line @typescript-eslint/no-restricted-imports
var create_package_json_1 = require("nx/src/plugins/js/package-json/create-package-json");
Object.defineProperty(exports, "findProjectsNpmDependencies", { enumerable: true, get: function () { return create_package_json_1.findProjectsNpmDependencies; } });

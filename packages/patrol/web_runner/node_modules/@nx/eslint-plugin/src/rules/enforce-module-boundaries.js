"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RULE_NAME = void 0;
const devkit_1 = require("@nx/devkit");
const utils_1 = require("@typescript-eslint/utils");
const internal_1 = require("@nx/js/src/internal");
const fileutils_1 = require("nx/src/utils/fileutils");
const path_1 = require("path");
const ast_utils_1 = require("../utils/ast-utils");
const graph_utils_1 = require("../utils/graph-utils");
const project_graph_utils_1 = require("../utils/project-graph-utils");
const runtime_lint_utils_1 = require("../utils/runtime-lint-utils");
const project_graph_1 = require("nx/src/config/project-graph");
exports.RULE_NAME = 'enforce-module-boundaries';
exports.default = utils_1.ESLintUtils.RuleCreator(() => `https://github.com/nrwl/nx/blob/${devkit_1.NX_VERSION}/docs/generated/packages/eslint-plugin/documents/enforce-module-boundaries.md`)({
    name: exports.RULE_NAME,
    meta: {
        type: 'suggestion',
        docs: {
            description: `Ensure that module boundaries are respected within the monorepo`,
        },
        fixable: 'code',
        schema: [
            {
                type: 'object',
                properties: {
                    enforceBuildableLibDependency: { type: 'boolean' },
                    allowCircularSelfDependency: { type: 'boolean' },
                    checkDynamicDependenciesExceptions: {
                        type: 'array',
                        items: { type: 'string' },
                    },
                    ignoredCircularDependencies: {
                        type: 'array',
                        items: {
                            type: 'array',
                            items: { type: 'string' },
                            minItems: 2,
                            maxItems: 2,
                        },
                    },
                    banTransitiveDependencies: { type: 'boolean' },
                    checkNestedExternalImports: { type: 'boolean' },
                    allow: { type: 'array', items: { type: 'string' } },
                    buildTargets: { type: 'array', items: { type: 'string' } },
                    depConstraints: {
                        type: 'array',
                        items: {
                            oneOf: [
                                {
                                    type: 'object',
                                    properties: {
                                        sourceTag: { type: 'string' },
                                        onlyDependOnLibsWithTags: {
                                            type: 'array',
                                            items: { type: 'string' },
                                        },
                                        allowedExternalImports: {
                                            type: 'array',
                                            items: { type: 'string' },
                                        },
                                        bannedExternalImports: {
                                            type: 'array',
                                            items: { type: 'string' },
                                        },
                                        notDependOnLibsWithTags: {
                                            type: 'array',
                                            items: { type: 'string' },
                                        },
                                    },
                                    additionalProperties: false,
                                },
                                {
                                    type: 'object',
                                    properties: {
                                        allSourceTags: {
                                            type: 'array',
                                            items: { type: 'string' },
                                            minItems: 2,
                                        },
                                        onlyDependOnLibsWithTags: {
                                            type: 'array',
                                            items: { type: 'string' },
                                        },
                                        allowedExternalImports: {
                                            type: 'array',
                                            items: { type: 'string' },
                                        },
                                        bannedExternalImports: {
                                            type: 'array',
                                            items: { type: 'string' },
                                        },
                                        notDependOnLibsWithTags: {
                                            type: 'array',
                                            items: { type: 'string' },
                                        },
                                    },
                                    additionalProperties: false,
                                },
                            ],
                        },
                    },
                },
                additionalProperties: false,
            },
        ],
        messages: {
            noRelativeOrAbsoluteImportsAcrossLibraries: `Projects cannot be imported by a relative or absolute path, and must begin with a npm scope`,
            noRelativeOrAbsoluteExternals: `External resources cannot be imported using a relative or absolute path`,
            noCircularDependencies: `Circular dependency between "{{sourceProjectName}}" and "{{targetProjectName}}" detected: {{path}}\n\nCircular file chain:\n{{filePaths}}`,
            noSelfCircularDependencies: `Projects should use relative imports to import from other files within the same project. Use "./path/to/file" instead of import from "{{imp}}"`,
            noImportsOfApps: 'Imports of apps are forbidden',
            noImportsOfE2e: 'Imports of e2e projects are forbidden',
            noImportOfNonBuildableLibraries: 'Buildable libraries cannot import or export from non-buildable libraries',
            noImportsOfLazyLoadedLibraries: `Static imports of lazy-loaded libraries are forbidden.\n\nLibrary "{{targetProjectName}}" is lazy-loaded in these files:\n{{filePaths}}`,
            projectWithoutTagsCannotHaveDependencies: `A project without tags matching at least one constraint cannot depend on any libraries`,
            bannedExternalImportsViolation: `A project tagged with "{{sourceTag}}" is not allowed to import "{{imp}}"`,
            nestedBannedExternalImportsViolation: `A project tagged with "{{sourceTag}}" is not allowed to import "{{imp}}". Nested import found at {{childProjectName}}`,
            noTransitiveDependencies: `Only packages defined in the "package.json" can be imported. Transitive or unresolvable dependencies are not allowed.`,
            onlyTagsConstraintViolation: `A project tagged with "{{sourceTag}}" can only depend on libs tagged with {{tags}}`,
            emptyOnlyTagsConstraintViolation: 'A project tagged with "{{sourceTag}}" cannot depend on any libs with tags',
            notTagsConstraintViolation: `A project tagged with "{{sourceTag}}" can not depend on libs tagged with {{tags}}\n\nViolation detected in:\n{{projects}}`,
        },
    },
    defaultOptions: [
        {
            allow: [],
            buildTargets: ['build'],
            depConstraints: [],
            enforceBuildableLibDependency: false,
            allowCircularSelfDependency: false,
            checkDynamicDependenciesExceptions: [],
            ignoredCircularDependencies: [],
            banTransitiveDependencies: false,
            checkNestedExternalImports: false,
        },
    ],
    create(context, [{ allow, buildTargets, depConstraints, enforceBuildableLibDependency, allowCircularSelfDependency, checkDynamicDependenciesExceptions, ignoredCircularDependencies, banTransitiveDependencies, checkNestedExternalImports, },]) {
        /**
         * Globally cached info about workspace
         */
        const projectPath = (0, devkit_1.normalizePath)(global.projectPath || devkit_1.workspaceRoot);
        const fileName = (0, devkit_1.normalizePath)(context.filename ?? context.getFilename());
        const { projectGraph, projectRootMappings, projectFileMap, targetProjectLocator, } = (0, project_graph_utils_1.readProjectGraph)(exports.RULE_NAME);
        if (!projectGraph) {
            return {};
        }
        const workspaceLayout = global.workspaceLayout;
        const expandedIgnoreCircularDependencies = (0, graph_utils_1.expandIgnoredCircularDependencies)(ignoredCircularDependencies, projectGraph);
        function run(node) {
            // Ignoring ExportNamedDeclarations like:
            // export class Foo {}
            if (!node.source) {
                return;
            }
            // accept only literals because template literals have no value
            if (node.source.type !== utils_1.AST_NODE_TYPES.Literal) {
                return;
            }
            const imp = node.source.value;
            // whitelisted import
            if (allow.some((a) => (0, runtime_lint_utils_1.matchImportWithWildcard)(a, imp))) {
                return;
            }
            const sourceFilePath = (0, runtime_lint_utils_1.getSourceFilePath)(fileName, projectPath);
            const sourceProject = (0, runtime_lint_utils_1.findProject)(projectGraph, projectRootMappings, sourceFilePath);
            // If source is not part of an nx workspace, return.
            if (!sourceProject) {
                return;
            }
            // check for relative and absolute imports
            const isAbsoluteImportIntoAnotherProj = (0, runtime_lint_utils_1.isAbsoluteImportIntoAnotherProject)(imp, workspaceLayout);
            let targetProject;
            if (isAbsoluteImportIntoAnotherProj) {
                targetProject = (0, runtime_lint_utils_1.findProject)(projectGraph, projectRootMappings, imp);
            }
            else {
                targetProject = (0, runtime_lint_utils_1.getTargetProjectBasedOnRelativeImport)(imp, projectPath, projectGraph, projectRootMappings, sourceFilePath);
            }
            if ((targetProject && sourceProject !== targetProject) ||
                isAbsoluteImportIntoAnotherProj) {
                context.report({
                    node,
                    messageId: 'noRelativeOrAbsoluteImportsAcrossLibraries',
                    fix(fixer) {
                        if (targetProject) {
                            const indexTsPaths = (0, ast_utils_1.getBarrelEntryPointProjectNode)(targetProject);
                            if (indexTsPaths && indexTsPaths.length > 0) {
                                const specifiers = node.specifiers;
                                if (!specifiers || specifiers.length === 0) {
                                    return;
                                }
                                const imports = specifiers
                                    .filter((s) => s.type === 'ImportSpecifier')
                                    .map((s) => s.imported.name);
                                // process each potential entry point and try to find the imports
                                const importsToRemap = [];
                                for (const entryPointPath of indexTsPaths) {
                                    for (const importMember of imports) {
                                        const importPath = (0, ast_utils_1.getRelativeImportPath)(importMember, (0, path_1.join)(devkit_1.workspaceRoot, entryPointPath.path));
                                        // we cannot remap, so leave it as is
                                        if (importPath) {
                                            importsToRemap.push({
                                                member: importMember,
                                                importPath: entryPointPath.importScope,
                                            });
                                        }
                                    }
                                }
                                const adjustedRelativeImports = (0, runtime_lint_utils_1.groupImports)(importsToRemap);
                                if (adjustedRelativeImports !== '') {
                                    return fixer.replaceTextRange(node.range, adjustedRelativeImports);
                                }
                            }
                        }
                    },
                });
                return;
            }
            targetProject =
                targetProject ||
                    (0, runtime_lint_utils_1.findProjectUsingImport)(projectGraph, targetProjectLocator, sourceFilePath, imp);
            if (!targetProject) {
                // non-project imports cannot use relative or absolute paths
                if ((0, fileutils_1.isRelativePath)(imp) || imp.startsWith('/')) {
                    context.report({
                        node,
                        messageId: 'noRelativeOrAbsoluteExternals',
                    });
                }
                else if (banTransitiveDependencies && !(0, internal_1.isBuiltinModuleImport)(imp)) {
                    /**
                     * At this point, the target project could not be found in the project graph, and it is not a relative or absolute import.
                     * Therefore it could be an external/npm package dependency (but not a node built in module) which has not yet been installed
                     * in the workspace.
                     *
                     * If the banTransitiveDependencies option is enabled, we should flag this case as an error because the user is trying to
                     * depend on something which is not explicitly defined/resolvable on disk for their project.
                     */
                    context.report({
                        node,
                        messageId: 'noTransitiveDependencies',
                    });
                }
                // If target is not found (including node internals) we bail early
                return;
            }
            // we only allow relative paths within the same project
            // and if it's not a secondary entrypoint in an angular lib
            if (sourceProject === targetProject &&
                !(0, graph_utils_1.circularPathHasPair)([sourceProject, targetProject], expandedIgnoreCircularDependencies)) {
                if (!allowCircularSelfDependency &&
                    !(0, fileutils_1.isRelativePath)(imp) &&
                    !(0, runtime_lint_utils_1.belongsToDifferentEntryPoint)(imp, sourceFilePath, sourceProject.data.root)) {
                    context.report({
                        node,
                        messageId: 'noSelfCircularDependencies',
                        data: {
                            imp,
                        },
                        fix(fixer) {
                            // imp has form of @myorg/someproject/some/path
                            const indexTsPaths = (0, ast_utils_1.getBarrelEntryPointByImportScope)(imp);
                            if (indexTsPaths.length > 0) {
                                const specifiers = node.specifiers;
                                if (!specifiers || specifiers.length === 0) {
                                    return;
                                }
                                // imported JS functions to remap
                                const imports = specifiers
                                    .filter((s) => s.type === 'ImportSpecifier')
                                    .map((s) => s.imported.name);
                                // process each potential entry point and try to find the imports
                                const importsToRemap = [];
                                for (const entryPointPath of indexTsPaths) {
                                    for (const importMember of imports) {
                                        const importPath = (0, ast_utils_1.getRelativeImportPath)(importMember, (0, path_1.join)(devkit_1.workspaceRoot, entryPointPath));
                                        if (importPath) {
                                            // resolve the import path
                                            const relativePath = (0, path_1.relative)((0, path_1.dirname)(fileName), (0, path_1.dirname)(importPath));
                                            // the string we receive from elsewhere might not have a leading './' here despite still being a relative path
                                            // we'd like to ensure it's a normalized relative form starting from ./ or ../
                                            const ensureRelativeForm = (path) => path.startsWith('./') || path.startsWith('../')
                                                ? path
                                                : `./${path}`;
                                            // if the string is empty, it's the current file
                                            const importPathResolved = relativePath === ''
                                                ? `./${(0, path_1.basename)(importPath)}`
                                                : ensureRelativeForm((0, devkit_1.joinPathFragments)(relativePath, (0, path_1.basename)(importPath)));
                                            importsToRemap.push({
                                                member: importMember,
                                                // remove .ts or .tsx from the end of the file path
                                                importPath: importPathResolved.replace(/.tsx?$/, ''),
                                            });
                                        }
                                    }
                                }
                                const adjustedRelativeImports = (0, runtime_lint_utils_1.groupImports)(importsToRemap);
                                if (adjustedRelativeImports !== '') {
                                    return fixer.replaceTextRange(node.range, adjustedRelativeImports);
                                }
                            }
                        },
                    });
                }
                return;
            }
            // project => npm package
            if (targetProject.type === 'npm') {
                if (banTransitiveDependencies &&
                    !(0, runtime_lint_utils_1.isDirectDependency)(sourceProject, targetProject)) {
                    context.report({
                        node,
                        messageId: 'noTransitiveDependencies',
                    });
                }
                const constraint = (0, runtime_lint_utils_1.hasBannedImport)(sourceProject, targetProject, depConstraints, imp);
                if (constraint) {
                    context.report({
                        node,
                        messageId: 'bannedExternalImportsViolation',
                        data: {
                            sourceTag: (0, runtime_lint_utils_1.isComboDepConstraint)(constraint)
                                ? constraint.allSourceTags.join('" and "')
                                : constraint.sourceTag,
                            imp,
                        },
                    });
                }
                return;
            }
            if (!(0, project_graph_1.isProjectGraphProjectNode)(targetProject)) {
                return;
            }
            targetProject = targetProject;
            // check constraints between libs and apps
            // check for circular dependency
            const circularPath = (0, graph_utils_1.checkCircularPath)(projectGraph, sourceProject, targetProject);
            if (circularPath.length !== 0 &&
                !(0, graph_utils_1.circularPathHasPair)(circularPath, expandedIgnoreCircularDependencies)) {
                const circularFilePath = (0, graph_utils_1.findFilesInCircularPath)(projectFileMap, circularPath);
                // spacer text used for indirect dependencies when printing one line per file.
                // without this, we can end up with a very long line that does not display well in the terminal.
                const spacer = '  ';
                context.report({
                    node,
                    messageId: 'noCircularDependencies',
                    data: {
                        sourceProjectName: sourceProject.name,
                        targetProjectName: targetProject.name,
                        path: circularPath.reduce((acc, v) => `${acc} -> ${v.name}`, sourceProject.name),
                        filePaths: circularFilePath
                            .map((files) => files.length > 1
                            ? `[${files
                                .map((f) => `\n${spacer}${spacer}${f}`)
                                .join(',')}\n${spacer}]`
                            : files[0])
                            .reduce((acc, files) => `${acc}\n- ${files}`, `- ${sourceFilePath}`),
                    },
                });
                return;
            }
            // cannot import apps
            if (targetProject.type === 'app' && !(0, runtime_lint_utils_1.appIsMFERemote)(targetProject)) {
                context.report({
                    node,
                    messageId: 'noImportsOfApps',
                });
                return;
            }
            // cannot import e2e projects
            if (targetProject.type === 'e2e') {
                context.report({
                    node,
                    messageId: 'noImportsOfE2e',
                });
                return;
            }
            // buildable-lib is not allowed to import non-buildable-lib
            if (enforceBuildableLibDependency === true &&
                sourceProject.type === 'lib' &&
                targetProject.type === 'lib') {
                if ((0, runtime_lint_utils_1.hasBuildExecutor)(sourceProject, buildTargets) &&
                    !(0, runtime_lint_utils_1.hasBuildExecutor)(targetProject, buildTargets)) {
                    context.report({
                        node,
                        messageId: 'noImportOfNonBuildableLibraries',
                    });
                    return;
                }
            }
            // if we import a library using loadChildren, we should not import it using es6imports
            if (!checkDynamicDependenciesExceptions.some((a) => (0, runtime_lint_utils_1.matchImportWithWildcard)(a, imp)) &&
                (0, runtime_lint_utils_1.hasStaticImportOfDynamicResource)(node, projectGraph, sourceProject.name, targetProject.name, imp, sourceFilePath)) {
                const filesWithLazyImports = (0, graph_utils_1.findFilesWithDynamicImports)(projectFileMap, sourceProject.name, targetProject.name);
                context.report({
                    data: {
                        filePaths: filesWithLazyImports
                            .map(({ file }) => `- ${file}`)
                            .join('\n'),
                        targetProjectName: targetProject.name,
                    },
                    node,
                    messageId: 'noImportsOfLazyLoadedLibraries',
                });
                return;
            }
            // check that dependency constraints are satisfied
            if (depConstraints.length > 0) {
                const constraints = (0, runtime_lint_utils_1.findConstraintsFor)(depConstraints, sourceProject);
                // when no constrains found => error. Force the user to provision them.
                if (constraints.length === 0) {
                    context.report({
                        node,
                        messageId: 'projectWithoutTagsCannotHaveDependencies',
                    });
                    return;
                }
                const transitiveExternalDeps = checkNestedExternalImports
                    ? (0, runtime_lint_utils_1.findTransitiveExternalDependencies)(projectGraph, targetProject)
                    : [];
                for (let constraint of constraints) {
                    if (constraint.onlyDependOnLibsWithTags &&
                        constraint.onlyDependOnLibsWithTags.length &&
                        (0, runtime_lint_utils_1.hasNoneOfTheseTags)(targetProject, constraint.onlyDependOnLibsWithTags)) {
                        context.report({
                            node,
                            messageId: 'onlyTagsConstraintViolation',
                            data: {
                                sourceTag: (0, runtime_lint_utils_1.isComboDepConstraint)(constraint)
                                    ? constraint.allSourceTags.join('" and "')
                                    : constraint.sourceTag,
                                tags: (0, runtime_lint_utils_1.stringifyTags)(constraint.onlyDependOnLibsWithTags),
                            },
                        });
                        return;
                    }
                    if (constraint.onlyDependOnLibsWithTags &&
                        constraint.onlyDependOnLibsWithTags.length === 0 &&
                        targetProject.data.tags.length !== 0) {
                        context.report({
                            node,
                            messageId: 'emptyOnlyTagsConstraintViolation',
                            data: {
                                sourceTag: (0, runtime_lint_utils_1.isComboDepConstraint)(constraint)
                                    ? constraint.allSourceTags.join('" and "')
                                    : constraint.sourceTag,
                            },
                        });
                        return;
                    }
                    if (constraint.notDependOnLibsWithTags &&
                        constraint.notDependOnLibsWithTags.length) {
                        const projectPaths = (0, runtime_lint_utils_1.findDependenciesWithTags)(targetProject, constraint.notDependOnLibsWithTags, projectGraph);
                        if (projectPaths.length > 0) {
                            context.report({
                                node,
                                messageId: 'notTagsConstraintViolation',
                                data: {
                                    sourceTag: (0, runtime_lint_utils_1.isComboDepConstraint)(constraint)
                                        ? constraint.allSourceTags.join('" and "')
                                        : constraint.sourceTag,
                                    tags: (0, runtime_lint_utils_1.stringifyTags)(constraint.notDependOnLibsWithTags),
                                    projects: projectPaths
                                        .map((projectPath) => `- ${projectPath.map((p) => p.name).join(' -> ')}`)
                                        .join('\n'),
                                },
                            });
                            return;
                        }
                    }
                    if (checkNestedExternalImports &&
                        constraint.bannedExternalImports &&
                        constraint.bannedExternalImports.length) {
                        const matches = (0, runtime_lint_utils_1.hasBannedDependencies)(transitiveExternalDeps, projectGraph, constraint, imp);
                        if (matches.length > 0) {
                            matches.forEach(([target, violatingSource, constraint]) => {
                                context.report({
                                    node,
                                    messageId: 'nestedBannedExternalImportsViolation',
                                    data: {
                                        sourceTag: (0, runtime_lint_utils_1.isComboDepConstraint)(constraint)
                                            ? constraint.allSourceTags.join('" and "')
                                            : constraint.sourceTag,
                                        childProjectName: violatingSource.name,
                                        imp,
                                    },
                                });
                            });
                            return;
                        }
                    }
                }
            }
        }
        return {
            ImportDeclaration(node) {
                run(node);
            },
            ImportExpression(node) {
                run(node);
            },
            ExportAllDeclaration(node) {
                run(node);
            },
            ExportNamedDeclaration(node) {
                run(node);
            },
        };
    },
});

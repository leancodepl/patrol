"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RULE_NAME = void 0;
exports.checkCollectionFileNode = checkCollectionFileNode;
exports.checkCollectionNode = checkCollectionNode;
exports.validateEntry = validateEntry;
exports.validateImplementationNode = validateImplementationNode;
exports.validatePackageGroup = validatePackageGroup;
exports.validateVersionJsonExpression = validateVersionJsonExpression;
exports.checkIfIdentifierIsFunction = checkIfIdentifierIsFunction;
const tslib_1 = require("tslib");
const utils_1 = require("@typescript-eslint/utils");
const fs_1 = require("fs");
const tsquery_1 = require("@phenomnomnominal/tsquery");
const devkit_1 = require("@nx/devkit");
const js_1 = require("@nx/js");
const internal_1 = require("@nx/js/src/internal");
const path = tslib_1.__importStar(require("path"));
const semver_1 = require("semver");
const project_graph_utils_1 = require("../utils/project-graph-utils");
const runtime_lint_utils_1 = require("../utils/runtime-lint-utils");
const DEFAULT_OPTIONS = {
    generatorsJson: 'generators.json',
    executorsJson: 'executors.json',
    migrationsJson: 'migrations.json',
    packageJson: 'package.json',
    allowedVersionStrings: ['*', 'latest', 'next'],
    tsConfig: 'tsconfig.lib.json',
};
exports.RULE_NAME = 'nx-plugin-checks';
exports.default = utils_1.ESLintUtils.RuleCreator(() => ``)({
    name: exports.RULE_NAME,
    meta: {
        docs: {
            description: 'Checks common nx-plugin configuration files for validity',
        },
        schema: [
            {
                type: 'object',
                properties: {
                    generatorsJson: {
                        type: 'string',
                        description: "The path to the project's generators.json file, relative to the project root",
                    },
                    executorsJson: {
                        type: 'string',
                        description: "The path to the project's executors.json file, relative to the project root",
                    },
                    migrationsJson: {
                        type: 'string',
                        description: "The path to the project's migrations.json file, relative to the project root",
                    },
                    packageJson: {
                        type: 'string',
                        description: "The path to the project's package.json file, relative to the project root",
                    },
                    allowedVersionStrings: {
                        type: 'array',
                        description: 'A list of specifiers that are valid for versions within package group. Defaults to ["*", "latest", "next"]',
                        items: { type: 'string' },
                    },
                    tsConfig: {
                        type: 'string',
                        description: 'The path to the tsconfig file used to build the plugin. Defaults to "tsconfig.lib.json".',
                    },
                },
                additionalProperties: false,
            },
        ],
        type: 'problem',
        messages: {
            invalidSchemaPath: 'Schema path should point to a valid file',
            invalidImplementationPath: '{{ key }}: Implementation path should point to a valid file',
            invalidImplementationModule: '{{ key }}: Unable to find export {{ identifier }} in implementation module',
            unableToReadImplementationExports: '{{ key }}: Unable to read exports for implementation module',
            invalidVersion: '{{ key }}: Version should be a valid semver',
            noGeneratorsOrSchematicsFound: 'Unable to find `generators` or `schematics` property',
            noExecutorsOrBuildersFound: 'Unable to find `executors` or `builders` property',
            valueShouldBeObject: '{{ key }} should be an object',
            missingRequiredSchema: '{{ key }}: Missing required property - `schema`',
            missingImplementation: '{{ key }}: Missing required property - `implementation`',
            missingVersion: '{{ key }}: Missing required property - `version`',
        },
    },
    defaultOptions: [DEFAULT_OPTIONS],
    create(context) {
        // jsonc-eslint-parser adds this property to parserServices where appropriate
        if (!(0, runtime_lint_utils_1.getParserServices)(context).isJSON) {
            return {};
        }
        const { projectGraph, projectRootMappings } = (0, project_graph_utils_1.readProjectGraph)(exports.RULE_NAME);
        const sourceFilePath = (0, runtime_lint_utils_1.getSourceFilePath)(context.filename ?? context.getFilename(), devkit_1.workspaceRoot);
        const sourceProject = (0, runtime_lint_utils_1.findProject)(projectGraph, projectRootMappings, sourceFilePath);
        // If source is not part of an nx workspace, return.
        if (!sourceProject) {
            return {};
        }
        const options = normalizeOptions(sourceProject, context.options[0]);
        context.options[0] = options;
        const { generatorsJson, executorsJson, migrationsJson, packageJson } = options;
        if (![generatorsJson, executorsJson, migrationsJson, packageJson].includes(sourceFilePath)) {
            return {};
        }
        if (!global.tsProjectRegistered) {
            (0, internal_1.registerTsProject)((0, js_1.getRootTsConfigPath)());
            global.tsProjectRegistered = true;
        }
        return {
            ['JSONExpressionStatement > JSONObjectExpression'](node) {
                if (sourceFilePath === generatorsJson) {
                    checkCollectionFileNode(node, 'generator', context, options);
                }
                else if (sourceFilePath === migrationsJson) {
                    checkCollectionFileNode(node, 'migration', context, options);
                }
                else if (sourceFilePath === executorsJson) {
                    checkCollectionFileNode(node, 'executor', context, options);
                }
                else if (sourceFilePath === packageJson) {
                    validatePackageGroup(node, context);
                }
            },
        };
    },
});
function normalizeOptions(sourceProject, options) {
    let rootDir;
    let outDir;
    const base = { ...DEFAULT_OPTIONS, ...options };
    let runtimeTsConfig;
    if (sourceProject.data.targets?.build?.executor === '@nx/js:tsc') {
        rootDir = sourceProject.data.targets.build.options.rootDir;
        outDir = sourceProject.data.targets.build.options.outputPath;
    }
    if (!rootDir && !outDir) {
        try {
            runtimeTsConfig = require.resolve(path.join(devkit_1.workspaceRoot, sourceProject.data.root, base.tsConfig));
            const tsConfig = (0, devkit_1.readJsonFile)(runtimeTsConfig);
            rootDir ??= tsConfig.compilerOptions?.rootDir
                ? path.join(sourceProject.data.root, tsConfig.compilerOptions.rootDir)
                : undefined;
            outDir ??= tsConfig.compilerOptions?.outDir
                ? path.join(sourceProject.data.root, tsConfig.compilerOptions.outDir)
                : undefined;
        }
        catch {
            // nothing
        }
    }
    const pathPrefix = sourceProject.data.root !== '.' ? `${sourceProject.data.root}/` : '';
    return {
        ...base,
        executorsJson: base.executorsJson
            ? `${pathPrefix}${base.executorsJson}`
            : undefined,
        generatorsJson: base.generatorsJson
            ? `${pathPrefix}${base.generatorsJson}`
            : undefined,
        migrationsJson: base.migrationsJson
            ? `${pathPrefix}${base.migrationsJson}`
            : undefined,
        packageJson: base.packageJson
            ? `${pathPrefix}${base.packageJson}`
            : undefined,
        rootDir,
        outDir,
    };
}
function checkCollectionFileNode(baseNode, mode, context, options) {
    const schematicsRootNode = baseNode.properties.find((x) => x.key.type === 'JSONLiteral' && x.key.value === 'schematics');
    const generatorsRootNode = baseNode.properties.find((x) => x.key.type === 'JSONLiteral' && x.key.value === 'generators');
    const executorsRootNode = baseNode.properties.find((x) => x.key.type === 'JSONLiteral' && x.key.value === 'executors');
    const buildersRootNode = baseNode.properties.find((x) => x.key.type === 'JSONLiteral' && x.key.value === 'builders');
    if (!schematicsRootNode && !generatorsRootNode && mode !== 'executor') {
        context.report({
            messageId: 'noGeneratorsOrSchematicsFound',
            node: baseNode,
        });
        return;
    }
    if (!executorsRootNode && !buildersRootNode && mode === 'executor') {
        context.report({
            messageId: 'noExecutorsOrBuildersFound',
            node: baseNode,
        });
        return;
    }
    const collectionNodes = [
        { collectionNode: schematicsRootNode, key: 'schematics' },
        { collectionNode: generatorsRootNode, key: 'generators' },
        { collectionNode: executorsRootNode, key: 'executors' },
        { collectionNode: buildersRootNode, key: 'builders' },
    ].filter(({ collectionNode }) => !!collectionNode);
    for (const { collectionNode, key } of collectionNodes) {
        if (collectionNode.value.type !== 'JSONObjectExpression') {
            context.report({
                messageId: 'valueShouldBeObject',
                data: { key },
                node: schematicsRootNode,
            });
        }
        else {
            checkCollectionNode(collectionNode.value, mode, context, options);
        }
    }
}
function checkCollectionNode(baseNode, mode, context, options) {
    const entries = baseNode.properties;
    for (const entryNode of entries) {
        if (entryNode.value.type !== 'JSONObjectExpression') {
            context.report({
                messageId: 'valueShouldBeObject',
                data: { key: entryNode.key.value },
                node: entryNode,
            });
        }
        else if (entryNode.key.type === 'JSONLiteral') {
            validateEntry(entryNode.value, entryNode.key.value.toString(), mode, context, options);
        }
    }
}
function validateEntry(baseNode, key, mode, context, options) {
    const schemaNode = baseNode.properties.find((x) => x.key.type === 'JSONLiteral' && x.key.value === 'schema');
    if (mode !== 'migration' && !schemaNode) {
        context.report({
            messageId: 'missingRequiredSchema',
            data: {
                key,
            },
            node: baseNode,
        });
    }
    else if (schemaNode) {
        if (schemaNode.value.type !== 'JSONLiteral' ||
            typeof schemaNode.value.value !== 'string') {
            context.report({
                messageId: 'invalidSchemaPath',
                node: schemaNode.value,
            });
        }
        else {
            let validJsonFound = false;
            const schemaFilePath = path.join(path.dirname(context.filename ?? context.getFilename()), schemaNode.value.value);
            try {
                (0, devkit_1.readJsonFile)(schemaFilePath);
                validJsonFound = true;
            }
            catch {
                try {
                    // Try to map back to source, which will be the case with TS solution setup.
                    (0, devkit_1.readJsonFile)(schemaFilePath.replace(options.outDir, options.rootDir));
                    validJsonFound = true;
                }
                catch {
                    // nothing, will be reported below
                }
            }
            if (!validJsonFound) {
                context.report({
                    messageId: 'invalidSchemaPath',
                    node: schemaNode.value,
                });
            }
        }
    }
    const implementationNode = baseNode.properties.find((x) => x.key.type === 'JSONLiteral' &&
        (x.key.value === 'implementation' || x.key.value === 'factory'));
    if (!implementationNode) {
        context.report({
            messageId: 'missingImplementation',
            data: {
                key,
            },
            node: baseNode,
        });
    }
    else {
        validateImplementationNode(implementationNode, key, context, options);
    }
    if (mode === 'migration') {
        const versionNode = baseNode.properties.find((x) => x.key.type === 'JSONLiteral' && x.key.value === 'version');
        if (!versionNode) {
            context.report({
                messageId: 'missingVersion',
                data: {
                    key,
                },
                node: baseNode,
            });
        }
        else if (versionNode.value.type !== 'JSONLiteral' ||
            typeof versionNode.value.value !== 'string') {
            context.report({
                messageId: 'invalidVersion',
                data: {
                    key,
                },
                node: versionNode.value,
            });
        }
        else {
            const specifiedVersion = versionNode.value.value;
            if (!(0, semver_1.valid)(specifiedVersion)) {
                context.report({
                    messageId: 'invalidVersion',
                    data: {
                        key,
                    },
                    node: versionNode.value,
                });
            }
        }
    }
}
function validateImplementationNode(implementationNode, key, context, options) {
    if (implementationNode.value.type !== 'JSONLiteral' ||
        typeof implementationNode.value.value !== 'string') {
        context.report({
            messageId: 'invalidImplementationPath',
            data: {
                key,
            },
            node: implementationNode.value,
        });
    }
    else {
        const [implementationPath, identifier] = implementationNode.value.value.split('#');
        let resolvedPath;
        const modulePath = path.join(path.dirname(context.filename ?? context.getFilename()), implementationPath);
        try {
            resolvedPath = require.resolve(modulePath);
        }
        catch {
            try {
                resolvedPath = require.resolve(modulePath.replace(options.outDir, options.rootDir));
            }
            catch {
                // nothing, will be reported below
            }
        }
        if (!resolvedPath) {
            context.report({
                messageId: 'invalidImplementationPath',
                data: {
                    key,
                },
                node: implementationNode.value,
            });
        }
        if (identifier) {
            try {
                if (!checkIfIdentifierIsFunction(resolvedPath, identifier)) {
                    context.report({
                        messageId: 'invalidImplementationModule',
                        node: implementationNode.value,
                        data: {
                            identifier,
                            key,
                        },
                    });
                }
            }
            catch {
                // require can throw if the module is not found
                context.report({
                    messageId: 'unableToReadImplementationExports',
                    node: implementationNode.value,
                    data: {
                        key,
                    },
                });
            }
        }
    }
}
function validatePackageGroup(baseNode, context) {
    const migrationsNode = baseNode.properties.find((x) => x.key.type === 'JSONLiteral' &&
        x.value.type === 'JSONObjectExpression' &&
        (x.key.value === 'nx-migrations' ||
            x.key.value === 'ng-update' ||
            x.key.value === 'migrations'))?.value;
    const packageGroupNode = migrationsNode?.properties.find((x) => x.key.type === 'JSONLiteral' && x.key.value === 'packageGroup');
    if (packageGroupNode) {
        // Package group is defined as an array
        if (packageGroupNode.value.type === 'JSONArrayExpression') {
            // Look at entries which are an object
            const members = packageGroupNode.value.elements.filter((x) => x.type === 'JSONObjectExpression');
            // validate that the version property exists and is valid
            for (const member of members) {
                const versionPropertyNode = member.properties.find((x) => x.key.type === 'JSONLiteral' && x.key.value === 'version');
                const packageNode = member.properties.find((x) => x.key.type === 'JSONLiteral' && x.key.value === 'package');
                const key = packageNode?.value?.value ?? 'unknown';
                if (versionPropertyNode) {
                    if (!validateVersionJsonExpression(versionPropertyNode.value, context))
                        context.report({
                            messageId: 'invalidVersion',
                            data: { key },
                            node: versionPropertyNode.value,
                        });
                }
                else {
                    context.report({
                        messageId: 'missingVersion',
                        data: { key },
                        node: member,
                    });
                }
            }
            // Package group is defined as an object (Record<PackageName, Version>)
        }
        else if (packageGroupNode.value.type === 'JSONObjectExpression') {
            const properties = packageGroupNode.value.properties;
            // For each property, ensure its value is a valid version
            for (const propertyNode of properties) {
                if (!validateVersionJsonExpression(propertyNode.value, context)) {
                    context.report({
                        messageId: 'invalidVersion',
                        data: {
                            key: propertyNode.key.value,
                        },
                        node: propertyNode.value,
                    });
                }
            }
        }
    }
}
function validateVersionJsonExpression(node, context) {
    return (node &&
        node.type === 'JSONLiteral' &&
        typeof node.value === 'string' &&
        ((0, semver_1.valid)(node.value) ||
            context.options[0]?.allowedVersionStrings.includes(node.value)));
}
function checkIfIdentifierIsFunction(filePath, identifier) {
    try {
        const ts = require('typescript');
        const sourceCode = (0, fs_1.readFileSync)(filePath, 'utf-8');
        const sourceFile = ts.createSourceFile(filePath, sourceCode, ts.ScriptTarget.Latest, true);
        const exportedFunctions = (0, tsquery_1.tsquery)(sourceFile, `
      FunctionDeclaration[name.text="${identifier}"][modifiers],
      ExportDeclaration > FunctionDeclaration[name.text="${identifier}"],
      VariableStatement[modifiers] VariableDeclaration[name.text="${identifier}"] ArrowFunction,
      VariableStatement[modifiers] VariableDeclaration[name.text="${identifier}"] FunctionExpression,
      ExportDeclaration > VariableStatement VariableDeclaration[name.text="${identifier}"] ArrowFunction,
      ExportDeclaration > VariableStatement VariableDeclaration[name.text="${identifier}"] FunctionExpression,
      ExportDeclaration ExportSpecifier[name.text="${identifier}"]
    `);
        return exportedFunctions.length > 0;
    }
    catch {
        // ignore
    }
    // Fallback to require()
    const m = require(filePath);
    return identifier in m && typeof m[identifier] === 'function';
}

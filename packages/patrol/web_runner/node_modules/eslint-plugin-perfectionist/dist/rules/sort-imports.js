'use strict'
const commonJsonSchemas = require('../utils/common-json-schemas.js')
const reportErrors = require('../utils/report-errors.js')
const validateNewlinesAndPartitionConfiguration = require('../utils/validate-newlines-and-partition-configuration.js')
const validateGeneratedGroupsConfiguration = require('../utils/validate-generated-groups-configuration.js')
const validateSideEffectsConfiguration = require('./sort-imports/validate-side-effects-configuration.js')
const validateCustomSortConfiguration = require('../utils/validate-custom-sort-configuration.js')
const getCustomGroupsCompareOptions = require('../utils/get-custom-groups-compare-options.js')
const readClosestTsConfigByPath = require('./sort-imports/read-closest-ts-config-by-path.js')
const getOptionsWithCleanGroups = require('../utils/get-options-with-clean-groups.js')
const computeCommonSelectors = require('./sort-imports/compute-common-selectors.js')
const isSideEffectOnlyGroup = require('./sort-imports/is-side-effect-only-group.js')
const generatePredefinedGroups = require('../utils/generate-predefined-groups.js')
const sortNodesByDependencies = require('../utils/sort-nodes-by-dependencies.js')
const getEslintDisabledLines = require('../utils/get-eslint-disabled-lines.js')
const isNodeEslintDisabled = require('../utils/is-node-eslint-disabled.js')
const doesCustomGroupMatch = require('../utils/does-custom-group-match.js')
const types = require('./sort-imports/types.js')
const sortNodesByGroups = require('../utils/sort-nodes-by-groups.js')
const createEslintRule = require('../utils/create-eslint-rule.js')
const reportAllErrors = require('../utils/report-all-errors.js')
const shouldPartition = require('../utils/should-partition.js')
const computeGroup = require('../utils/compute-group.js')
const rangeToDiff = require('../utils/range-to-diff.js')
const getSettings = require('../utils/get-settings.js')
const isSortable = require('../utils/is-sortable.js')
const complete = require('../utils/complete.js')
let cachedGroupsByModifiersAndSelectors = /* @__PURE__ */ new Map()
let defaultOptions = {
  groups: [
    'type-import',
    ['value-builtin', 'value-external'],
    'type-internal',
    'value-internal',
    ['type-parent', 'type-sibling', 'type-index'],
    ['value-parent', 'value-sibling', 'value-index'],
    'ts-equals-import',
    'unknown',
  ],
  internalPattern: ['^~/.+', '^@/.+'],
  fallbackSort: { type: 'unsorted' },
  partitionByComment: false,
  partitionByNewLine: false,
  specialCharacters: 'keep',
  sortSideEffects: false,
  type: 'alphabetical',
  environment: 'node',
  newlinesBetween: 1,
  customGroups: [],
  ignoreCase: true,
  locales: 'en-US',
  alphabet: '',
  order: 'asc',
}
const sortImports = createEslintRule.createEslintRule({
  create: context => {
    let settings = getSettings.getSettings(context.settings)
    let userOptions = context.options.at(0)
    let options = getOptionsWithCleanGroups.getOptionsWithCleanGroups(
      complete.complete(userOptions, settings, defaultOptions),
    )
    validateGeneratedGroupsConfiguration.validateGeneratedGroupsConfiguration({
      options: {
        ...options,
        customGroups: Array.isArray(options.customGroups)
          ? options.customGroups
          : {
              ...options.customGroups.type,
              ...options.customGroups.value,
            },
      },
      selectors: [...types.allSelectors, ...types.allDeprecatedSelectors],
      modifiers: types.allModifiers,
    })
    validateCustomSortConfiguration.validateCustomSortConfiguration(options)
    validateNewlinesAndPartitionConfiguration.validateNewlinesAndPartitionConfiguration(
      options,
    )
    validateSideEffectsConfiguration.validateSideEffectsConfiguration(options)
    let tsconfigRootDirectory =
      options.tsconfig?.rootDir ?? options.tsconfigRootDir
    let tsConfigOutput = tsconfigRootDirectory
      ? readClosestTsConfigByPath.readClosestTsConfigByPath({
          tsconfigFilename: options.tsconfig?.filename ?? 'tsconfig.json',
          tsconfigRootDir: tsconfigRootDirectory,
          filePath: context.physicalFilename,
          contextCwd: context.cwd,
        })
      : null
    let { sourceCode, filename, id } = context
    let eslintDisabledLines = getEslintDisabledLines.getEslintDisabledLines({
      ruleName: id,
      sourceCode,
    })
    let sortingNodesWithoutPartitionId = []
    let flatGroups = new Set(options.groups.flat())
    let shouldRegroupSideEffectNodes = flatGroups.has('side-effect')
    let shouldRegroupSideEffectStyleNodes = flatGroups.has('side-effect-style')
    function registerNode(node) {
      let name = getNodeName({
        sourceCode,
        node,
      })
      let commonSelectors = computeCommonSelectors.computeCommonSelectors({
        tsConfigOutput,
        filename,
        options,
        name,
      })
      let selectors = []
      let modifiers = []
      let group = null
      if (node.type !== 'VariableDeclaration' && node.importKind === 'type') {
        if (node.type === 'ImportDeclaration') {
          if (!Array.isArray(options.customGroups)) {
            group = computeGroupExceptUnknown({
              customGroups: options.customGroups.type,
              options,
              name,
            })
          }
          for (let selector of commonSelectors) {
            if (selector !== 'subpath' && selector !== 'tsconfig-path') {
              selectors.push(`${selector}-type`)
            }
          }
        }
        selectors.push('type')
        modifiers.push('type')
        if (!group && !Array.isArray(options.customGroups)) {
          group = computeGroupExceptUnknown({
            customGroups: [],
            selectors,
            modifiers,
            options,
            name,
          })
        }
      }
      let isSideEffect = isSideEffectImport({ sourceCode, node })
      let isStyleValue = isStyle(name)
      let isStyleSideEffect = isSideEffect && isStyleValue
      if (!group && !Array.isArray(options.customGroups)) {
        group = computeGroupExceptUnknown({
          customGroups: options.customGroups.value,
          options,
          name,
        })
      }
      if (!isNonExternalReferenceTsImportEquals(node)) {
        if (isStyleSideEffect) {
          selectors.push('side-effect-style')
        }
        if (isSideEffect) {
          selectors.push('side-effect')
          modifiers.push('side-effect')
        }
        if (isStyleValue) {
          selectors.push('style')
        }
        for (let selector of commonSelectors) {
          selectors.push(selector)
        }
      }
      selectors.push('import')
      if (!modifiers.includes('type')) {
        modifiers.push('value')
      }
      if (node.type === 'TSImportEqualsDeclaration') {
        modifiers.push('ts-equals')
      }
      if (node.type === 'VariableDeclaration') {
        modifiers.push('require')
      }
      if (hasSpecifier(node, 'ImportDefaultSpecifier')) {
        modifiers.push('default')
      }
      if (hasSpecifier(node, 'ImportNamespaceSpecifier')) {
        modifiers.push('wildcard')
      }
      if (hasSpecifier(node, 'ImportSpecifier')) {
        modifiers.push('named')
      }
      group ??=
        computeGroupExceptUnknown({
          customGroups: Array.isArray(options.customGroups)
            ? options.customGroups
            : [],
          selectors,
          modifiers,
          options,
          name,
        }) ?? 'unknown'
      let hasMultipleImportDeclarations = isSortable.isSortable(node.specifiers)
      let size = rangeToDiff.rangeToDiff(node, sourceCode)
      if (
        hasMultipleImportDeclarations &&
        options.maxLineLength &&
        size > options.maxLineLength
      ) {
        size = name.length + 10
      }
      sortingNodesWithoutPartitionId.push({
        isIgnored:
          !options.sortSideEffects &&
          isSideEffect &&
          !shouldRegroupSideEffectNodes &&
          (!isStyleSideEffect || !shouldRegroupSideEffectStyleNodes),
        isEslintDisabled: isNodeEslintDisabled.isNodeEslintDisabled(
          node,
          eslintDisabledLines,
        ),
        dependencyNames: computeDependencyNames({ sourceCode, node }),
        dependencies: computeDependencies(node),
        addSafetySemicolonWhenInline: true,
        group,
        size,
        name,
        node,
      })
    }
    return {
      'Program:exit': () => {
        let contentSeparatedSortingNodeGroups = [[[]]]
        for (let sortingNodeWithoutPartitionId of sortingNodesWithoutPartitionId) {
          let lastGroupWithNoContentBetween =
            contentSeparatedSortingNodeGroups.at(-1)
          let lastGroup = lastGroupWithNoContentBetween.at(-1)
          let lastSortingNode = lastGroup.at(-1)
          if (
            lastSortingNode &&
            hasContentBetweenNodes(
              sourceCode,
              lastSortingNode,
              sortingNodeWithoutPartitionId,
            )
          ) {
            lastGroup = []
            lastGroupWithNoContentBetween = [lastGroup]
            contentSeparatedSortingNodeGroups.push(
              lastGroupWithNoContentBetween,
            )
          } else if (
            shouldPartition.shouldPartition({
              sortingNode: sortingNodeWithoutPartitionId,
              lastSortingNode,
              sourceCode,
              options,
            })
          ) {
            lastGroup = []
            lastGroupWithNoContentBetween.push(lastGroup)
          }
          lastGroup.push({
            ...sortingNodeWithoutPartitionId,
            partitionId: lastGroupWithNoContentBetween.length,
          })
        }
        for (let sortingNodeGroups of contentSeparatedSortingNodeGroups) {
          let createSortNodesExcludingEslintDisabled = function (nodeGroups) {
            return function (ignoreEslintDisabledNodes) {
              let nodesSortedByGroups = nodeGroups.flatMap(nodes2 =>
                sortNodesByGroups.sortNodesByGroups({
                  getOptionsByGroupIndex: groupIndex => {
                    let customGroupOverriddenOptions =
                      getCustomGroupsCompareOptions.getCustomGroupOverriddenOptions(
                        {
                          options: {
                            ...options,
                            customGroups: Array.isArray(options.customGroups)
                              ? options.customGroups
                              : [],
                          },
                          groupIndex,
                        },
                      )
                    if (options.sortSideEffects) {
                      return {
                        options: {
                          ...options,
                          ...customGroupOverriddenOptions,
                        },
                      }
                    }
                    let overriddenOptions = {
                      ...options,
                      ...customGroupOverriddenOptions,
                    }
                    return {
                      options: {
                        ...overriddenOptions,
                        type:
                          overriddenOptions.groups[groupIndex] &&
                          isSideEffectOnlyGroup.isSideEffectOnlyGroup(
                            overriddenOptions.groups[groupIndex],
                          )
                            ? 'unsorted'
                            : overriddenOptions.type,
                      },
                    }
                  },
                  isNodeIgnored: node => node.isIgnored,
                  ignoreEslintDisabledNodes,
                  groups: options.groups,
                  nodes: nodes2,
                }),
              )
              return sortNodesByDependencies.sortNodesByDependencies(
                nodesSortedByGroups,
                {
                  ignoreEslintDisabledNodes,
                },
              )
            }
          }
          let nodes = sortingNodeGroups.flat()
          reportAllErrors.reportAllErrors({
            availableMessageIds: {
              unexpectedDependencyOrder: 'unexpectedImportsDependencyOrder',
              missedSpacingBetweenMembers: 'missedSpacingBetweenImports',
              extraSpacingBetweenMembers: 'extraSpacingBetweenImports',
              unexpectedGroupOrder: 'unexpectedImportsGroupOrder',
              missedCommentAbove: 'missedCommentAboveImport',
              unexpectedOrder: 'unexpectedImportsOrder',
            },
            options: {
              ...options,
              customGroups: Array.isArray(options.customGroups)
                ? options.customGroups
                : [],
            },
            sortNodesExcludingEslintDisabled:
              createSortNodesExcludingEslintDisabled(sortingNodeGroups),
            sourceCode,
            context,
            nodes,
          })
        }
      },
      VariableDeclaration: node => {
        if (
          node.declarations[0].init &&
          node.declarations[0].init.type === 'CallExpression' &&
          node.declarations[0].init.callee.type === 'Identifier' &&
          node.declarations[0].init.callee.name === 'require' &&
          node.declarations[0].init.arguments[0]?.type === 'Literal'
        ) {
          registerNode(node)
        }
      },
      TSImportEqualsDeclaration: registerNode,
      ImportDeclaration: registerNode,
    }
  },
  meta: {
    schema: {
      items: {
        properties: {
          ...commonJsonSchemas.commonJsonSchemas,
          customGroups: {
            oneOf: [
              {
                properties: {
                  value: {
                    ...commonJsonSchemas.deprecatedCustomGroupsJsonSchema,
                    description: 'Specifies custom groups for value imports.',
                  },
                  type: {
                    ...commonJsonSchemas.deprecatedCustomGroupsJsonSchema,
                    description: 'Specifies custom groups for type imports.',
                  },
                },
                description: 'Specifies custom groups.',
                additionalProperties: false,
                type: 'object',
              },
              commonJsonSchemas.buildCustomGroupsArrayJsonSchema({
                singleCustomGroupJsonSchema: types.singleCustomGroupJsonSchema,
              }),
            ],
          },
          tsconfig: {
            properties: {
              rootDir: {
                description: 'Specifies the tsConfig root directory.',
                type: 'string',
              },
              filename: {
                description: 'Specifies the tsConfig filename.',
                type: 'string',
              },
            },
            additionalProperties: false,
            required: ['rootDir'],
            type: 'object',
          },
          maxLineLength: {
            description: 'Specifies the maximum line length.',
            exclusiveMinimum: true,
            type: 'integer',
            minimum: 0,
          },
          sortSideEffects: {
            description:
              'Controls whether side-effect imports should be sorted.',
            type: 'boolean',
          },
          environment: {
            description: 'Specifies the environment.',
            enum: ['node', 'bun'],
            type: 'string',
          },
          tsconfigRootDir: {
            description: 'Specifies the tsConfig root directory.',
            type: 'string',
          },
          partitionByComment: commonJsonSchemas.partitionByCommentJsonSchema,
          partitionByNewLine: commonJsonSchemas.partitionByNewLineJsonSchema,
          newlinesBetween: commonJsonSchemas.newlinesBetweenJsonSchema,
          internalPattern: commonJsonSchemas.regexJsonSchema,
          groups: commonJsonSchemas.groupsJsonSchema,
        },
        additionalProperties: false,
        type: 'object',
      },
      uniqueItems: true,
      type: 'array',
    },
    messages: {
      unexpectedImportsDependencyOrder: reportErrors.DEPENDENCY_ORDER_ERROR,
      missedCommentAboveImport: reportErrors.MISSED_COMMENT_ABOVE_ERROR,
      missedSpacingBetweenImports: reportErrors.MISSED_SPACING_ERROR,
      extraSpacingBetweenImports: reportErrors.EXTRA_SPACING_ERROR,
      unexpectedImportsGroupOrder: reportErrors.GROUP_ORDER_ERROR,
      unexpectedImportsOrder: reportErrors.ORDER_ERROR,
    },
    docs: {
      url: 'https://perfectionist.dev/rules/sort-imports',
      description: 'Enforce sorted imports.',
      recommended: true,
    },
    type: 'suggestion',
    fixable: 'code',
  },
  defaultOptions: [defaultOptions],
  name: 'sort-imports',
})
function hasSpecifier(node, specifier) {
  return (
    node.type === 'ImportDeclaration' &&
    node.specifiers.some(nodeSpecifier => nodeSpecifier.type === specifier)
  )
}
function hasContentBetweenNodes(sourceCode, left, right) {
  return (
    sourceCode.getTokensBetween(left.node, right.node, {
      includeComments: false,
    }).length > 0
  )
}
let styleExtensions = [
  '.less',
  '.scss',
  '.sass',
  '.styl',
  '.pcss',
  '.css',
  '.sss',
]
function computeGroupExceptUnknown({
  customGroups,
  selectors,
  modifiers,
  options,
  name,
}) {
  let predefinedGroups =
    modifiers && selectors
      ? generatePredefinedGroups.generatePredefinedGroups({
          cache: cachedGroupsByModifiersAndSelectors,
          selectors,
          modifiers,
        })
      : []
  let computedCustomGroup = computeGroup.computeGroup({
    customGroupMatcher: customGroup =>
      doesCustomGroupMatch.doesCustomGroupMatch({
        modifiers,
        selectors,
        elementName: name,
        customGroup,
      }),
    options: {
      ...options,
      customGroups,
    },
    predefinedGroups,
    name,
  })
  if (computedCustomGroup === 'unknown') {
    return null
  }
  return computedCustomGroup
}
function computeDependencyNames({ sourceCode, node }) {
  if (node.type === 'VariableDeclaration') {
    return []
  }
  if (node.type === 'TSImportEqualsDeclaration') {
    return [node.id.name]
  }
  let returnValue = []
  for (let specifier of node.specifiers) {
    switch (specifier.type) {
      case 'ImportNamespaceSpecifier':
        returnValue.push(sourceCode.getText(specifier.local))
        break
      case 'ImportDefaultSpecifier':
        returnValue.push(sourceCode.getText(specifier.local))
        break
      case 'ImportSpecifier':
        returnValue.push(sourceCode.getText(specifier.imported))
        break
    }
  }
  return returnValue
}
function getNodeName({ sourceCode, node }) {
  if (node.type === 'ImportDeclaration') {
    return node.source.value
  }
  if (node.type === 'TSImportEqualsDeclaration') {
    if (node.moduleReference.type === 'TSExternalModuleReference') {
      return node.moduleReference.expression.value
    }
    return sourceCode.getText(node.moduleReference)
  }
  let callExpression = node.declarations[0].init
  let { value } = callExpression.arguments[0]
  return value.toString()
}
function computeDependencies(node) {
  if (node.type !== 'TSImportEqualsDeclaration') {
    return []
  }
  if (node.moduleReference.type !== 'TSQualifiedName') {
    return []
  }
  let qualifiedName = getQualifiedNameDependencyName(node.moduleReference)
  if (!qualifiedName) {
    return []
  }
  return [qualifiedName]
}
function isSideEffectImport({ sourceCode, node }) {
  return (
    node.type === 'ImportDeclaration' &&
    node.specifiers.length ===
      0 /* Avoid matching on named imports without specifiers */ &&
    !/\}\s*from\s+/u.test(sourceCode.getText(node))
  )
}
function isNonExternalReferenceTsImportEquals(node) {
  if (node.type !== 'TSImportEqualsDeclaration') {
    return false
  }
  return node.moduleReference.type !== 'TSExternalModuleReference'
}
function getQualifiedNameDependencyName(node) {
  switch (node.type) {
    case 'TSQualifiedName':
      return getQualifiedNameDependencyName(node.left)
    case 'Identifier':
      return node.name
  }
  return null
}
function isStyle(value) {
  let [cleanedValue] = value.split('?')
  return styleExtensions.some(extension => cleanedValue?.endsWith(extension))
}
module.exports = sortImports

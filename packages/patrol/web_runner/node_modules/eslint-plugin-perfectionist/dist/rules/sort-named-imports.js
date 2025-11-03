'use strict'
const commonJsonSchemas = require('../utils/common-json-schemas.js')
const reportErrors = require('../utils/report-errors.js')
const validateNewlinesAndPartitionConfiguration = require('../utils/validate-newlines-and-partition-configuration.js')
const types = require('./sort-named-imports/types.js')
const getCustomGroupsCompareOptions = require('../utils/get-custom-groups-compare-options.js')
const validateGeneratedGroupsConfiguration = require('../utils/validate-generated-groups-configuration.js')
const validateCustomSortConfiguration = require('../utils/validate-custom-sort-configuration.js')
const generatePredefinedGroups = require('../utils/generate-predefined-groups.js')
const getEslintDisabledLines = require('../utils/get-eslint-disabled-lines.js')
const isNodeEslintDisabled = require('../utils/is-node-eslint-disabled.js')
const doesCustomGroupMatch = require('../utils/does-custom-group-match.js')
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
  fallbackSort: { type: 'unsorted' },
  specialCharacters: 'keep',
  partitionByNewLine: false,
  partitionByComment: false,
  newlinesBetween: 'ignore',
  type: 'alphabetical',
  ignoreAlias: false,
  groupKind: 'mixed',
  customGroups: [],
  ignoreCase: true,
  locales: 'en-US',
  alphabet: '',
  order: 'asc',
  groups: [],
}
const sortNamedImports = createEslintRule.createEslintRule({
  create: context => ({
    ImportDeclaration: node => {
      let specifiers = node.specifiers.filter(
        ({ type }) => type === 'ImportSpecifier',
      )
      if (!isSortable.isSortable(specifiers)) {
        return
      }
      let settings = getSettings.getSettings(context.settings)
      let options = complete.complete(
        context.options.at(0),
        settings,
        defaultOptions,
      )
      validateCustomSortConfiguration.validateCustomSortConfiguration(options)
      validateGeneratedGroupsConfiguration.validateGeneratedGroupsConfiguration(
        {
          modifiers: types.allModifiers,
          selectors: types.allSelectors,
          options,
        },
      )
      validateNewlinesAndPartitionConfiguration.validateNewlinesAndPartitionConfiguration(
        options,
      )
      let { sourceCode, id } = context
      let eslintDisabledLines = getEslintDisabledLines.getEslintDisabledLines({
        ruleName: id,
        sourceCode,
      })
      let formattedMembers = [[]]
      for (let specifier of specifiers) {
        let { name } = specifier.local
        if (specifier.type === 'ImportSpecifier' && options.ignoreAlias) {
          if (specifier.imported.type === 'Identifier') {
            ;({ name } = specifier.imported)
          } else {
            name = specifier.imported.value
          }
        }
        let selector = 'import'
        let modifiers = []
        if (
          specifier.type === 'ImportSpecifier' &&
          specifier.importKind === 'type'
        ) {
          modifiers.push('type')
        } else {
          modifiers.push('value')
        }
        let predefinedGroups =
          generatePredefinedGroups.generatePredefinedGroups({
            cache: cachedGroupsByModifiersAndSelectors,
            selectors: [selector],
            modifiers,
          })
        let group = computeGroup.computeGroup({
          customGroupMatcher: customGroup =>
            doesCustomGroupMatch.doesCustomGroupMatch({
              selectors: [selector],
              elementName: name,
              customGroup,
              modifiers,
            }),
          predefinedGroups,
          options,
        })
        let sortingNode = {
          groupKind:
            specifier.type === 'ImportSpecifier' &&
            specifier.importKind === 'type'
              ? 'type'
              : 'value',
          isEslintDisabled: isNodeEslintDisabled.isNodeEslintDisabled(
            specifier,
            eslintDisabledLines,
          ),
          size: rangeToDiff.rangeToDiff(specifier, sourceCode),
          node: specifier,
          group,
          name,
        }
        let lastSortingNode = formattedMembers.at(-1)?.at(-1)
        if (
          shouldPartition.shouldPartition({
            lastSortingNode,
            sortingNode,
            sourceCode,
            options,
          })
        ) {
          formattedMembers.push([])
        }
        formattedMembers.at(-1).push({
          ...sortingNode,
          partitionId: formattedMembers.length,
        })
      }
      let groupKindOrder
      if (options.groupKind === 'values-first') {
        groupKindOrder = ['value', 'type']
      } else if (options.groupKind === 'types-first') {
        groupKindOrder = ['type', 'value']
      } else {
        groupKindOrder = ['any']
      }
      for (let nodes of formattedMembers) {
        let sortNodesExcludingEslintDisabled = function (
          ignoreEslintDisabledNodes,
        ) {
          return filteredGroupKindNodes.flatMap(groupedNodes =>
            sortNodesByGroups.sortNodesByGroups({
              getOptionsByGroupIndex:
                getCustomGroupsCompareOptions.buildGetCustomGroupOverriddenOptionsFunction(
                  options,
                ),
              ignoreEslintDisabledNodes,
              groups: options.groups,
              nodes: groupedNodes,
            }),
          )
        }
        let filteredGroupKindNodes = groupKindOrder.map(groupKind =>
          nodes.filter(
            currentNode =>
              groupKind === 'any' || currentNode.groupKind === groupKind,
          ),
        )
        reportAllErrors.reportAllErrors({
          availableMessageIds: {
            missedSpacingBetweenMembers: 'missedSpacingBetweenNamedImports',
            extraSpacingBetweenMembers: 'extraSpacingBetweenNamedImports',
            unexpectedGroupOrder: 'unexpectedNamedImportsGroupOrder',
            unexpectedOrder: 'unexpectedNamedImportsOrder',
          },
          sortNodesExcludingEslintDisabled,
          sourceCode,
          options,
          context,
          nodes,
        })
      }
    },
  }),
  meta: {
    schema: {
      items: {
        properties: {
          ...commonJsonSchemas.commonJsonSchemas,
          groupKind: {
            description: '[DEPRECATED] Specifies top-level groups.',
            enum: ['mixed', 'values-first', 'types-first'],
            type: 'string',
          },
          ignoreAlias: {
            description: 'Controls whether to ignore alias names.',
            type: 'boolean',
          },
          customGroups: commonJsonSchemas.buildCustomGroupsArrayJsonSchema({
            singleCustomGroupJsonSchema: types.singleCustomGroupJsonSchema,
          }),
          partitionByComment: commonJsonSchemas.partitionByCommentJsonSchema,
          partitionByNewLine: commonJsonSchemas.partitionByNewLineJsonSchema,
          newlinesBetween: commonJsonSchemas.newlinesBetweenJsonSchema,
          groups: commonJsonSchemas.groupsJsonSchema,
        },
        additionalProperties: false,
        type: 'object',
      },
      uniqueItems: true,
      type: 'array',
    },
    messages: {
      missedSpacingBetweenNamedImports: reportErrors.MISSED_SPACING_ERROR,
      extraSpacingBetweenNamedImports: reportErrors.EXTRA_SPACING_ERROR,
      unexpectedNamedImportsGroupOrder: reportErrors.GROUP_ORDER_ERROR,
      unexpectedNamedImportsOrder: reportErrors.ORDER_ERROR,
    },
    docs: {
      url: 'https://perfectionist.dev/rules/sort-named-imports',
      description: 'Enforce sorted named imports.',
      recommended: true,
    },
    type: 'suggestion',
    fixable: 'code',
  },
  defaultOptions: [defaultOptions],
  name: 'sort-named-imports',
})
module.exports = sortNamedImports

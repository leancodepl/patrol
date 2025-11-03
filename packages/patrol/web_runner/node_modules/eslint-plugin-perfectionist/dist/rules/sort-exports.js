'use strict'
const commonJsonSchemas = require('../utils/common-json-schemas.js')
const reportErrors = require('../utils/report-errors.js')
const validateNewlinesAndPartitionConfiguration = require('../utils/validate-newlines-and-partition-configuration.js')
const getCustomGroupsCompareOptions = require('../utils/get-custom-groups-compare-options.js')
const validateGeneratedGroupsConfiguration = require('../utils/validate-generated-groups-configuration.js')
const validateCustomSortConfiguration = require('../utils/validate-custom-sort-configuration.js')
const generatePredefinedGroups = require('../utils/generate-predefined-groups.js')
const getEslintDisabledLines = require('../utils/get-eslint-disabled-lines.js')
const isNodeEslintDisabled = require('../utils/is-node-eslint-disabled.js')
const doesCustomGroupMatch = require('../utils/does-custom-group-match.js')
const types = require('./sort-exports/types.js')
const sortNodesByGroups = require('../utils/sort-nodes-by-groups.js')
const createEslintRule = require('../utils/create-eslint-rule.js')
const reportAllErrors = require('../utils/report-all-errors.js')
const shouldPartition = require('../utils/should-partition.js')
const computeGroup = require('../utils/compute-group.js')
const rangeToDiff = require('../utils/range-to-diff.js')
const getSettings = require('../utils/get-settings.js')
const complete = require('../utils/complete.js')
let cachedGroupsByModifiersAndSelectors = /* @__PURE__ */ new Map()
let defaultOptions = {
  fallbackSort: { type: 'unsorted' },
  specialCharacters: 'keep',
  partitionByComment: false,
  newlinesBetween: 'ignore',
  partitionByNewLine: false,
  type: 'alphabetical',
  groupKind: 'mixed',
  customGroups: [],
  ignoreCase: true,
  locales: 'en-US',
  alphabet: '',
  order: 'asc',
  groups: [],
}
const sortExports = createEslintRule.createEslintRule({
  create: context => {
    let settings = getSettings.getSettings(context.settings)
    let options = complete.complete(
      context.options.at(0),
      settings,
      defaultOptions,
    )
    validateCustomSortConfiguration.validateCustomSortConfiguration(options)
    validateGeneratedGroupsConfiguration.validateGeneratedGroupsConfiguration({
      modifiers: types.allModifiers,
      selectors: types.allSelectors,
      options,
    })
    validateNewlinesAndPartitionConfiguration.validateNewlinesAndPartitionConfiguration(
      options,
    )
    let { sourceCode, id } = context
    let eslintDisabledLines = getEslintDisabledLines.getEslintDisabledLines({
      ruleName: id,
      sourceCode,
    })
    let formattedMembers = [[]]
    function registerNode(node) {
      let selector = 'export'
      let modifiers = []
      if (node.exportKind === 'value') {
        modifiers.push('value')
      } else {
        modifiers.push('type')
      }
      let name = node.source.value
      let predefinedGroups = generatePredefinedGroups.generatePredefinedGroups({
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
        isEslintDisabled: isNodeEslintDisabled.isNodeEslintDisabled(
          node,
          eslintDisabledLines,
        ),
        groupKind: node.exportKind === 'value' ? 'value' : 'type',
        size: rangeToDiff.rangeToDiff(node, sourceCode),
        addSafetySemicolonWhenInline: true,
        group,
        name,
        node,
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
    return {
      'Program:exit': () => {
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
              missedSpacingBetweenMembers: 'missedSpacingBetweenExports',
              extraSpacingBetweenMembers: 'extraSpacingBetweenExports',
              unexpectedGroupOrder: 'unexpectedExportsGroupOrder',
              missedCommentAbove: 'missedCommentAboveExport',
              unexpectedOrder: 'unexpectedExportsOrder',
            },
            sortNodesExcludingEslintDisabled,
            sourceCode,
            options,
            context,
            nodes,
          })
        }
      },
      ExportNamedDeclaration: node => {
        if (node.source !== null) {
          registerNode(node)
        }
      },
      ExportAllDeclaration: registerNode,
    }
  },
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
      missedCommentAboveExport: reportErrors.MISSED_COMMENT_ABOVE_ERROR,
      missedSpacingBetweenExports: reportErrors.MISSED_SPACING_ERROR,
      extraSpacingBetweenExports: reportErrors.EXTRA_SPACING_ERROR,
      unexpectedExportsGroupOrder: reportErrors.GROUP_ORDER_ERROR,
      unexpectedExportsOrder: reportErrors.ORDER_ERROR,
    },
    docs: {
      url: 'https://perfectionist.dev/rules/sort-exports',
      description: 'Enforce sorted exports.',
      recommended: true,
    },
    type: 'suggestion',
    fixable: 'code',
  },
  defaultOptions: [defaultOptions],
  name: 'sort-exports',
})
module.exports = sortExports

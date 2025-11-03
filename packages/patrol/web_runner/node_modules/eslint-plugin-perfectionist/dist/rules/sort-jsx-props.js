'use strict'
const types$1 = require('@typescript-eslint/types')
const commonJsonSchemas = require('../utils/common-json-schemas.js')
const reportErrors = require('../utils/report-errors.js')
const validateNewlinesAndPartitionConfiguration = require('../utils/validate-newlines-and-partition-configuration.js')
const getCustomGroupsCompareOptions = require('../utils/get-custom-groups-compare-options.js')
const validateGeneratedGroupsConfiguration = require('../utils/validate-generated-groups-configuration.js')
const validateCustomSortConfiguration = require('../utils/validate-custom-sort-configuration.js')
const getMatchingContextOptions = require('../utils/get-matching-context-options.js')
const generatePredefinedGroups = require('../utils/generate-predefined-groups.js')
const getEslintDisabledLines = require('../utils/get-eslint-disabled-lines.js')
const isNodeEslintDisabled = require('../utils/is-node-eslint-disabled.js')
const doesCustomGroupMatch = require('../utils/does-custom-group-match.js')
const types = require('./sort-jsx-props/types.js')
const sortNodesByGroups = require('../utils/sort-nodes-by-groups.js')
const createEslintRule = require('../utils/create-eslint-rule.js')
const reportAllErrors = require('../utils/report-all-errors.js')
const shouldPartition = require('../utils/should-partition.js')
const computeGroup = require('../utils/compute-group.js')
const rangeToDiff = require('../utils/range-to-diff.js')
const getSettings = require('../utils/get-settings.js')
const isSortable = require('../utils/is-sortable.js')
const complete = require('../utils/complete.js')
const matches = require('../utils/matches.js')
let cachedGroupsByModifiersAndSelectors = /* @__PURE__ */ new Map()
let defaultOptions = {
  fallbackSort: { type: 'unsorted' },
  specialCharacters: 'keep',
  newlinesBetween: 'ignore',
  partitionByNewLine: false,
  useConfigurationIf: {},
  type: 'alphabetical',
  ignorePattern: [],
  ignoreCase: true,
  customGroups: {},
  locales: 'en-US',
  alphabet: '',
  order: 'asc',
  groups: [],
}
const sortJsxProps = createEslintRule.createEslintRule({
  create: context => ({
    JSXElement: node => {
      if (!isSortable.isSortable(node.openingElement.attributes)) {
        return
      }
      let settings = getSettings.getSettings(context.settings)
      let { sourceCode, id } = context
      let matchedContextOptions = getMatchingContextOptions
        .getMatchingContextOptions({
          nodeNames: node.openingElement.attributes
            .filter(
              attribute =>
                attribute.type !==
                types$1.TSESTree.AST_NODE_TYPES.JSXSpreadAttribute,
            )
            .map(attribute => getNodeName({ attribute })),
          contextOptions: context.options,
        })
        .find(options2 => {
          if (!options2.useConfigurationIf?.tagMatchesPattern) {
            return true
          }
          return matches.matches(
            sourceCode.getText(node.openingElement.name),
            options2.useConfigurationIf.tagMatchesPattern,
          )
        })
      let options = complete.complete(
        matchedContextOptions,
        settings,
        defaultOptions,
      )
      validateCustomSortConfiguration.validateCustomSortConfiguration(options)
      validateGeneratedGroupsConfiguration.validateGeneratedGroupsConfiguration(
        {
          selectors: types.allSelectors,
          modifiers: types.allModifiers,
          options,
        },
      )
      validateNewlinesAndPartitionConfiguration.validateNewlinesAndPartitionConfiguration(
        options,
      )
      let shouldIgnore = matches.matches(
        sourceCode.getText(node.openingElement.name),
        options.ignorePattern,
      )
      if (
        shouldIgnore ||
        !isSortable.isSortable(node.openingElement.attributes)
      ) {
        return
      }
      let eslintDisabledLines = getEslintDisabledLines.getEslintDisabledLines({
        ruleName: id,
        sourceCode,
      })
      let formattedMembers = node.openingElement.attributes.reduce(
        (accumulator, attribute) => {
          if (
            attribute.type ===
            types$1.TSESTree.AST_NODE_TYPES.JSXSpreadAttribute
          ) {
            accumulator.push([])
            return accumulator
          }
          let name = getNodeName({ attribute })
          let selectors = []
          let modifiers = []
          if (attribute.value === null) {
            selectors.push('shorthand')
            modifiers.push('shorthand')
          }
          if (attribute.loc.start.line !== attribute.loc.end.line) {
            selectors.push('multiline')
            modifiers.push('multiline')
          }
          selectors.push('prop')
          let predefinedGroups =
            generatePredefinedGroups.generatePredefinedGroups({
              cache: cachedGroupsByModifiersAndSelectors,
              selectors,
              modifiers,
            })
          let group = computeGroup.computeGroup({
            customGroupMatcher: customGroup =>
              doesCustomGroupMatch.doesCustomGroupMatch({
                elementValue: attribute.value
                  ? sourceCode.getText(attribute.value)
                  : null,
                elementName: name,
                customGroup,
                selectors,
                modifiers,
              }),
            predefinedGroups,
            options,
            name,
          })
          let sortingNode = {
            isEslintDisabled: isNodeEslintDisabled.isNodeEslintDisabled(
              attribute,
              eslintDisabledLines,
            ),
            size: rangeToDiff.rangeToDiff(attribute, sourceCode),
            node: attribute,
            group,
            name,
          }
          let lastSortingNode = accumulator.at(-1)?.at(-1)
          if (
            shouldPartition.shouldPartition({
              lastSortingNode,
              sortingNode,
              sourceCode,
              options,
            })
          ) {
            accumulator.push([])
          }
          accumulator.at(-1).push({
            ...sortingNode,
            partitionId: accumulator.length,
          })
          return accumulator
        },
        [[]],
      )
      for (let currentNodes of formattedMembers) {
        let createSortNodesExcludingEslintDisabled = function (nodes) {
          return function (ignoreEslintDisabledNodes) {
            return sortNodesByGroups.sortNodesByGroups({
              getOptionsByGroupIndex:
                getCustomGroupsCompareOptions.buildGetCustomGroupOverriddenOptionsFunction(
                  options,
                ),
              ignoreEslintDisabledNodes,
              groups: options.groups,
              nodes,
            })
          }
        }
        reportAllErrors.reportAllErrors({
          availableMessageIds: {
            missedSpacingBetweenMembers: 'missedSpacingBetweenJSXPropsMembers',
            extraSpacingBetweenMembers: 'extraSpacingBetweenJSXPropsMembers',
            unexpectedGroupOrder: 'unexpectedJSXPropsGroupOrder',
            unexpectedOrder: 'unexpectedJSXPropsOrder',
          },
          sortNodesExcludingEslintDisabled:
            createSortNodesExcludingEslintDisabled(currentNodes),
          nodes: currentNodes,
          sourceCode,
          options,
          context,
        })
      }
    },
  }),
  meta: {
    schema: {
      items: {
        properties: {
          ...commonJsonSchemas.commonJsonSchemas,
          customGroups: {
            oneOf: [
              commonJsonSchemas.deprecatedCustomGroupsJsonSchema,
              commonJsonSchemas.buildCustomGroupsArrayJsonSchema({
                singleCustomGroupJsonSchema: types.singleCustomGroupJsonSchema,
              }),
            ],
          },
          useConfigurationIf:
            commonJsonSchemas.buildUseConfigurationIfJsonSchema({
              additionalProperties: {
                tagMatchesPattern: commonJsonSchemas.regexJsonSchema,
              },
            }),
          partitionByNewLine: commonJsonSchemas.partitionByNewLineJsonSchema,
          newlinesBetween: commonJsonSchemas.newlinesBetweenJsonSchema,
          ignorePattern: commonJsonSchemas.regexJsonSchema,
          groups: commonJsonSchemas.groupsJsonSchema,
        },
        additionalProperties: false,
        type: 'object',
      },
      uniqueItems: true,
      type: 'array',
    },
    messages: {
      missedSpacingBetweenJSXPropsMembers: reportErrors.MISSED_SPACING_ERROR,
      extraSpacingBetweenJSXPropsMembers: reportErrors.EXTRA_SPACING_ERROR,
      unexpectedJSXPropsGroupOrder: reportErrors.GROUP_ORDER_ERROR,
      unexpectedJSXPropsOrder: reportErrors.ORDER_ERROR,
    },
    docs: {
      url: 'https://perfectionist.dev/rules/sort-jsx-props',
      description: 'Enforce sorted JSX props.',
      recommended: true,
    },
    type: 'suggestion',
    fixable: 'code',
  },
  defaultOptions: [defaultOptions],
  name: 'sort-jsx-props',
})
function getNodeName({ attribute }) {
  return attribute.name.type ===
    types$1.TSESTree.AST_NODE_TYPES.JSXNamespacedName
    ? `${attribute.name.namespace.name}:${attribute.name.name.name}`
    : attribute.name.name
}
module.exports = sortJsxProps

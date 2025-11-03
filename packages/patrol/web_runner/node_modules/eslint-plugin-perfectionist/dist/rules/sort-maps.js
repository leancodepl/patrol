'use strict'
const commonJsonSchemas = require('../utils/common-json-schemas.js')
const reportErrors = require('../utils/report-errors.js')
const getCustomGroupsCompareOptions = require('../utils/get-custom-groups-compare-options.js')
const validateGeneratedGroupsConfiguration = require('../utils/validate-generated-groups-configuration.js')
const validateCustomSortConfiguration = require('../utils/validate-custom-sort-configuration.js')
const getMatchingContextOptions = require('../utils/get-matching-context-options.js')
const getEslintDisabledLines = require('../utils/get-eslint-disabled-lines.js')
const isNodeEslintDisabled = require('../utils/is-node-eslint-disabled.js')
const doesCustomGroupMatch = require('../utils/does-custom-group-match.js')
const sortNodesByGroups = require('../utils/sort-nodes-by-groups.js')
const types = require('./sort-maps/types.js')
const createEslintRule = require('../utils/create-eslint-rule.js')
const reportAllErrors = require('../utils/report-all-errors.js')
const shouldPartition = require('../utils/should-partition.js')
const computeGroup = require('../utils/compute-group.js')
const rangeToDiff = require('../utils/range-to-diff.js')
const getSettings = require('../utils/get-settings.js')
const isSortable = require('../utils/is-sortable.js')
const complete = require('../utils/complete.js')
let defaultOptions = {
  fallbackSort: { type: 'unsorted' },
  specialCharacters: 'keep',
  partitionByComment: false,
  partitionByNewLine: false,
  newlinesBetween: 'ignore',
  useConfigurationIf: {},
  type: 'alphabetical',
  ignoreCase: true,
  customGroups: [],
  locales: 'en-US',
  alphabet: '',
  order: 'asc',
  groups: [],
}
const sortMaps = createEslintRule.createEslintRule({
  create: context => ({
    NewExpression: node => {
      if (
        node.callee.type !== 'Identifier' ||
        node.callee.name !== 'Map' ||
        node.arguments.length === 0 ||
        node.arguments[0]?.type !== 'ArrayExpression'
      ) {
        return
      }
      let [{ elements }] = node.arguments
      if (!isSortable.isSortable(elements)) {
        return
      }
      let { sourceCode, id } = context
      let settings = getSettings.getSettings(context.settings)
      let matchedContextOptions =
        getMatchingContextOptions.getMatchingContextOptions({
          nodeNames: elements
            .filter(
              element => element !== null && element.type !== 'SpreadElement',
            )
            .map(element => getNodeName({ sourceCode, element })),
          contextOptions: context.options,
        })
      let options = complete.complete(
        matchedContextOptions[0],
        settings,
        defaultOptions,
      )
      validateCustomSortConfiguration.validateCustomSortConfiguration(options)
      validateGeneratedGroupsConfiguration.validateGeneratedGroupsConfiguration(
        {
          selectors: [],
          modifiers: [],
          options,
        },
      )
      let eslintDisabledLines = getEslintDisabledLines.getEslintDisabledLines({
        ruleName: id,
        sourceCode,
      })
      let parts = elements.reduce(
        (accumulator, element) => {
          if (element === null || element.type === 'SpreadElement') {
            accumulator.push([])
          } else {
            accumulator.at(-1).push(element)
          }
          return accumulator
        },
        [[]],
      )
      for (let part of parts) {
        let formattedMembers = [[]]
        for (let element of part) {
          let name = getNodeName({
            sourceCode,
            element,
          })
          let lastSortingNode = formattedMembers.at(-1)?.at(-1)
          let group = computeGroup.computeGroup({
            customGroupMatcher: customGroup =>
              doesCustomGroupMatch.doesCustomGroupMatch({
                elementName: name,
                selectors: [],
                modifiers: [],
                customGroup,
              }),
            predefinedGroups: [],
            options,
          })
          let sortingNode = {
            isEslintDisabled: isNodeEslintDisabled.isNodeEslintDisabled(
              element,
              eslintDisabledLines,
            ),
            size: rangeToDiff.rangeToDiff(element, sourceCode),
            node: element,
            group,
            name,
          }
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
        for (let nodes of formattedMembers) {
          let createSortNodesExcludingEslintDisabled = function (sortingNodes) {
            return function (ignoreEslintDisabledNodes) {
              return sortNodesByGroups.sortNodesByGroups({
                getOptionsByGroupIndex:
                  getCustomGroupsCompareOptions.buildGetCustomGroupOverriddenOptionsFunction(
                    options,
                  ),
                ignoreEslintDisabledNodes,
                groups: options.groups,
                nodes: sortingNodes,
              })
            }
          }
          reportAllErrors.reportAllErrors({
            availableMessageIds: {
              missedSpacingBetweenMembers:
                'missedSpacingBetweenMapElementsMembers',
              extraSpacingBetweenMembers:
                'extraSpacingBetweenMapElementsMembers',
              unexpectedGroupOrder: 'unexpectedMapElementsGroupOrder',
              unexpectedOrder: 'unexpectedMapElementsOrder',
            },
            sortNodesExcludingEslintDisabled:
              createSortNodesExcludingEslintDisabled(nodes),
            sourceCode,
            options,
            context,
            nodes,
          })
        }
      }
    },
  }),
  meta: {
    schema: {
      items: {
        properties: {
          ...commonJsonSchemas.commonJsonSchemas,
          customGroups: commonJsonSchemas.buildCustomGroupsArrayJsonSchema({
            singleCustomGroupJsonSchema: types.singleCustomGroupJsonSchema,
          }),
          useConfigurationIf:
            commonJsonSchemas.buildUseConfigurationIfJsonSchema(),
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
      missedSpacingBetweenMapElementsMembers: reportErrors.MISSED_SPACING_ERROR,
      extraSpacingBetweenMapElementsMembers: reportErrors.EXTRA_SPACING_ERROR,
      unexpectedMapElementsGroupOrder: reportErrors.GROUP_ORDER_ERROR,
      unexpectedMapElementsOrder: reportErrors.ORDER_ERROR,
    },
    docs: {
      url: 'https://perfectionist.dev/rules/sort-maps',
      description: 'Enforce sorted Map elements.',
      recommended: true,
    },
    type: 'suggestion',
    fixable: 'code',
  },
  defaultOptions: [defaultOptions],
  name: 'sort-maps',
})
function getNodeName({ sourceCode, element }) {
  if (element.type === 'ArrayExpression') {
    let [left] = element.elements
    if (!left) {
      return `${left}`
    } else if (left.type === 'Literal') {
      return left.raw
    }
    return sourceCode.getText(left)
  }
  return sourceCode.getText(element)
}
module.exports = sortMaps

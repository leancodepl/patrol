'use strict'
const commonJsonSchemas = require('../utils/common-json-schemas.js')
const reportErrors = require('../utils/report-errors.js')
const validateNewlinesAndPartitionConfiguration = require('../utils/validate-newlines-and-partition-configuration.js')
const validateGeneratedGroupsConfiguration = require('../utils/validate-generated-groups-configuration.js')
const validateCustomSortConfiguration = require('../utils/validate-custom-sort-configuration.js')
const getCustomGroupsCompareOptions = require('../utils/get-custom-groups-compare-options.js')
const sortNodesByDependencies = require('../utils/sort-nodes-by-dependencies.js')
const getEslintDisabledLines = require('../utils/get-eslint-disabled-lines.js')
const isNodeEslintDisabled = require('../utils/is-node-eslint-disabled.js')
const doesCustomGroupMatch = require('../utils/does-custom-group-match.js')
const sortNodesByGroups = require('../utils/sort-nodes-by-groups.js')
const types = require('./sort-enums/types.js')
const createEslintRule = require('../utils/create-eslint-rule.js')
const reportAllErrors = require('../utils/report-all-errors.js')
const shouldPartition = require('../utils/should-partition.js')
const getEnumMembers = require('../utils/get-enum-members.js')
const computeGroup = require('../utils/compute-group.js')
const rangeToDiff = require('../utils/range-to-diff.js')
const getSettings = require('../utils/get-settings.js')
const isSortable = require('../utils/is-sortable.js')
const complete = require('../utils/complete.js')
let defaultOptions = {
  fallbackSort: { type: 'unsorted' },
  partitionByComment: false,
  partitionByNewLine: false,
  specialCharacters: 'keep',
  newlinesBetween: 'ignore',
  forceNumericSort: false,
  type: 'alphabetical',
  sortByValue: false,
  ignoreCase: true,
  locales: 'en-US',
  customGroups: [],
  alphabet: '',
  order: 'asc',
  groups: [],
}
const sortEnums = createEslintRule.createEslintRule({
  create: context => ({
    TSEnumDeclaration: enumDeclaration => {
      let members = getEnumMembers.getEnumMembers(enumDeclaration)
      if (
        !isSortable.isSortable(members) ||
        !members.every(({ initializer }) => initializer)
      ) {
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
          selectors: [],
          modifiers: [],
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
      function extractDependencies(expression, enumName) {
        let dependencies = []
        let stack = [expression]
        while (stack.length > 0) {
          let node = stack.pop()
          if (
            node.type === 'MemberExpression' &&
            node.object.type === 'Identifier' &&
            node.object.name === enumName &&
            node.property.type === 'Identifier'
          ) {
            dependencies.push(node.property.name)
          } else if (node.type === 'Identifier') {
            dependencies.push(node.name)
          }
          if ('left' in node) {
            stack.push(node.left)
          }
          if ('right' in node) {
            stack.push(node.right)
          }
          if ('expressions' in node) {
            stack.push(...node.expressions)
          }
        }
        return dependencies
      }
      let formattedMembers = members.reduce(
        (accumulator, member) => {
          let dependencies = []
          if (member.initializer) {
            dependencies = extractDependencies(
              member.initializer,
              enumDeclaration.id.name,
            )
          }
          let name =
            member.id.type === 'Literal'
              ? `${member.id.value}`
              : sourceCode.getText(member.id)
          let group = computeGroup.computeGroup({
            customGroupMatcher: customGroup =>
              doesCustomGroupMatch.doesCustomGroupMatch({
                elementValue: sourceCode.getText(member.initializer),
                elementName: name,
                selectors: [],
                modifiers: [],
                customGroup,
              }),
            predefinedGroups: [],
            options,
          })
          let lastSortingNode = accumulator.at(-1)?.at(-1)
          let sortingNode = {
            numericValue: member.initializer
              ? getExpressionNumberValue(member.initializer)
              : null,
            value:
              member.initializer?.type === 'Literal'
                ? (member.initializer.value?.toString() ?? null)
                : null,
            isEslintDisabled: isNodeEslintDisabled.isNodeEslintDisabled(
              member,
              eslintDisabledLines,
            ),
            size: rangeToDiff.rangeToDiff(member, sourceCode),
            dependencyNames: [name],
            node: member,
            dependencies,
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
      let nodes = formattedMembers.flat()
      let isNumericEnum = nodes.every(
        sortingNode =>
          sortingNode.numericValue !== null &&
          !Number.isNaN(sortingNode.numericValue),
      )
      let nodeValueGetter = computeNodeValueGetter({
        isNumericEnum,
        options,
      })
      let overriddenOptions = {
        ...options,
        type: computeOptionType({
          isNumericEnum,
          options,
        }),
      }
      function sortNodesExcludingEslintDisabled(ignoreEslintDisabledNodes) {
        let nodesSortedByGroups = formattedMembers.flatMap(sortingNodes =>
          sortNodesByGroups.sortNodesByGroups({
            getOptionsByGroupIndex: groupIndex => ({
              options:
                getCustomGroupsCompareOptions.getCustomGroupOverriddenOptions({
                  options: overriddenOptions,
                  groupIndex,
                }),
              nodeValueGetter,
            }),
            ignoreEslintDisabledNodes,
            groups: options.groups,
            nodes: sortingNodes,
          }),
        )
        return sortNodesByDependencies.sortNodesByDependencies(
          nodesSortedByGroups,
          {
            ignoreEslintDisabledNodes,
          },
        )
      }
      reportAllErrors.reportAllErrors({
        availableMessageIds: {
          missedSpacingBetweenMembers: 'missedSpacingBetweenEnumsMembers',
          extraSpacingBetweenMembers: 'extraSpacingBetweenEnumsMembers',
          unexpectedDependencyOrder: 'unexpectedEnumsDependencyOrder',
          unexpectedGroupOrder: 'unexpectedEnumsGroupOrder',
          unexpectedOrder: 'unexpectedEnumsOrder',
        },
        sortNodesExcludingEslintDisabled,
        sourceCode,
        options,
        context,
        nodes,
      })
    },
  }),
  meta: {
    schema: [
      {
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
          forceNumericSort: {
            description:
              'Will always sort numeric enums by their value regardless of the sort type specified.',
            type: 'boolean',
          },
          sortByValue: {
            description: 'Compare enum values instead of names.',
            type: 'boolean',
          },
          partitionByComment: commonJsonSchemas.partitionByCommentJsonSchema,
          partitionByNewLine: commonJsonSchemas.partitionByNewLineJsonSchema,
          newlinesBetween: commonJsonSchemas.newlinesBetweenJsonSchema,
          groups: commonJsonSchemas.groupsJsonSchema,
        },
        additionalProperties: false,
        type: 'object',
      },
    ],
    messages: {
      unexpectedEnumsDependencyOrder: reportErrors.DEPENDENCY_ORDER_ERROR,
      missedSpacingBetweenEnumsMembers: reportErrors.MISSED_SPACING_ERROR,
      extraSpacingBetweenEnumsMembers: reportErrors.EXTRA_SPACING_ERROR,
      unexpectedEnumsGroupOrder: reportErrors.GROUP_ORDER_ERROR,
      unexpectedEnumsOrder: reportErrors.ORDER_ERROR,
    },
    docs: {
      url: 'https://perfectionist.dev/rules/sort-enums',
      description: 'Enforce sorted TypeScript enums.',
      recommended: true,
    },
    type: 'suggestion',
    fixable: 'code',
  },
  defaultOptions: [defaultOptions],
  name: 'sort-enums',
})
function getBinaryExpressionNumberValue(
  leftExpression,
  rightExpression,
  operator,
) {
  let left = getExpressionNumberValue(leftExpression)
  let right = getExpressionNumberValue(rightExpression)
  switch (operator) {
    case '**':
      return left ** right
    case '>>':
      return left >> right
    case '<<':
      return left << right
    case '+':
      return left + right
    case '-':
      return left - right
    case '*':
      return left * right
    case '/':
      return left / right
    case '%':
      return left % right
    case '|':
      return left | right
    case '&':
      return left & right
    case '^':
      return left ^ right
    /* v8 ignore next 2 - Unsure if we can reach it */
    default:
      return Number.NaN
  }
}
function getExpressionNumberValue(expression) {
  switch (expression.type) {
    case 'BinaryExpression':
      return getBinaryExpressionNumberValue(
        expression.left,
        expression.right,
        expression.operator,
      )
    case 'UnaryExpression':
      return getUnaryExpressionNumberValue(
        expression.argument,
        expression.operator,
      )
    case 'Literal':
      return typeof expression.value === 'number'
        ? expression.value
        : Number.NaN
    default:
      return Number.NaN
  }
}
function computeNodeValueGetter({ isNumericEnum, options }) {
  return options.sortByValue || (isNumericEnum && options.forceNumericSort)
    ? sortingNode => {
        if (isNumericEnum) {
          return sortingNode.numericValue.toString()
        }
        return sortingNode.value ?? ''
      }
    : null
}
function computeOptionType({ isNumericEnum, options }) {
  return isNumericEnum && (options.forceNumericSort || options.sortByValue)
    ? 'natural'
    : options.type
}
function getUnaryExpressionNumberValue(argumentExpression, operator) {
  let argument = getExpressionNumberValue(argumentExpression)
  switch (operator) {
    case '+':
      return argument
    case '-':
      return -argument
    case '~':
      return ~argument
    /* v8 ignore next 2 - Unsure if we can reach it */
    default:
      return Number.NaN
  }
}
module.exports = sortEnums

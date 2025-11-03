'use strict'
Object.defineProperties(exports, {
  __esModule: { value: true },
  [Symbol.toStringTag]: { value: 'Module' },
})
const commonJsonSchemas = require('../utils/common-json-schemas.js')
const reportErrors = require('../utils/report-errors.js')
const validateNewlinesAndPartitionConfiguration = require('../utils/validate-newlines-and-partition-configuration.js')
const getCustomGroupsCompareOptions = require('../utils/get-custom-groups-compare-options.js')
const validateGeneratedGroupsConfiguration = require('../utils/validate-generated-groups-configuration.js')
const validateCustomSortConfiguration = require('../utils/validate-custom-sort-configuration.js')
const types = require('./sort-array-includes/types.js')
const getMatchingContextOptions = require('../utils/get-matching-context-options.js')
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
  groupKind: 'literals-first',
  specialCharacters: 'keep',
  partitionByComment: false,
  partitionByNewLine: false,
  newlinesBetween: 'ignore',
  useConfigurationIf: {},
  type: 'alphabetical',
  ignoreCase: true,
  locales: 'en-US',
  customGroups: [],
  alphabet: '',
  order: 'asc',
  groups: [],
}
let jsonSchema = {
  items: {
    properties: {
      ...commonJsonSchemas.commonJsonSchemas,
      groupKind: {
        description: '[DEPRECATED] Specifies top-level groups.',
        enum: ['mixed', 'literals-first', 'spreads-first'],
        type: 'string',
      },
      customGroups: commonJsonSchemas.buildCustomGroupsArrayJsonSchema({
        singleCustomGroupJsonSchema: types.singleCustomGroupJsonSchema,
      }),
      useConfigurationIf: commonJsonSchemas.buildUseConfigurationIfJsonSchema(),
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
}
const sortArrayIncludes = createEslintRule.createEslintRule({
  create: context => ({
    MemberExpression: node => {
      if (
        (node.object.type === 'ArrayExpression' ||
          node.object.type === 'NewExpression') &&
        node.property.type === 'Identifier' &&
        node.property.name === 'includes'
      ) {
        let elements =
          node.object.type === 'ArrayExpression'
            ? node.object.elements
            : node.object.arguments
        sortArray({
          availableMessageIds: {
            missedSpacingBetweenMembers:
              'missedSpacingBetweenArrayIncludesMembers',
            extraSpacingBetweenMembers:
              'extraSpacingBetweenArrayIncludesMembers',
            unexpectedGroupOrder: 'unexpectedArrayIncludesGroupOrder',
            unexpectedOrder: 'unexpectedArrayIncludesOrder',
          },
          elements,
          context,
        })
      }
    },
  }),
  meta: {
    messages: {
      missedSpacingBetweenArrayIncludesMembers:
        reportErrors.MISSED_SPACING_ERROR,
      extraSpacingBetweenArrayIncludesMembers: reportErrors.EXTRA_SPACING_ERROR,
      unexpectedArrayIncludesGroupOrder: reportErrors.GROUP_ORDER_ERROR,
      unexpectedArrayIncludesOrder: reportErrors.ORDER_ERROR,
    },
    docs: {
      description: 'Enforce sorted arrays before include method.',
      url: 'https://perfectionist.dev/rules/sort-array-includes',
      recommended: true,
    },
    schema: jsonSchema,
    type: 'suggestion',
    fixable: 'code',
  },
  defaultOptions: [defaultOptions],
  name: 'sort-array-includes',
})
function sortArray({ availableMessageIds, elements, context }) {
  if (!isSortable.isSortable(elements)) {
    return
  }
  let { sourceCode, id } = context
  let settings = getSettings.getSettings(context.settings)
  let matchedContextOptions =
    getMatchingContextOptions.getMatchingContextOptions({
      nodeNames: elements
        .filter(element => element !== null)
        .map(element => getNodeName({ sourceCode, element })),
      contextOptions: context.options,
    })
  let options = complete.complete(
    matchedContextOptions[0],
    settings,
    defaultOptions,
  )
  validateCustomSortConfiguration.validateCustomSortConfiguration(options)
  validateGeneratedGroupsConfiguration.validateGeneratedGroupsConfiguration({
    selectors: types.allSelectors,
    modifiers: [],
    options,
  })
  validateNewlinesAndPartitionConfiguration.validateNewlinesAndPartitionConfiguration(
    options,
  )
  let eslintDisabledLines = getEslintDisabledLines.getEslintDisabledLines({
    ruleName: id,
    sourceCode,
  })
  let formattedMembers = elements.reduce(
    (accumulator, element) => {
      if (element === null) {
        return accumulator
      }
      let groupKind
      let selector
      if (element.type === 'SpreadElement') {
        groupKind = 'spread'
        selector = 'spread'
      } else {
        groupKind = 'literal'
        selector = 'literal'
      }
      let name = getNodeName({ sourceCode, element })
      let predefinedGroups = generatePredefinedGroups.generatePredefinedGroups({
        cache: cachedGroupsByModifiersAndSelectors,
        selectors: [selector],
        modifiers: [],
      })
      let group = computeGroup.computeGroup({
        customGroupMatcher: customGroup =>
          doesCustomGroupMatch.doesCustomGroupMatch({
            selectors: [selector],
            elementName: name,
            modifiers: [],
            customGroup,
          }),
        predefinedGroups,
        options,
      })
      let sortingNode = {
        isEslintDisabled: isNodeEslintDisabled.isNodeEslintDisabled(
          element,
          eslintDisabledLines,
        ),
        size: rangeToDiff.rangeToDiff(element, sourceCode),
        node: element,
        groupKind,
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
  let groupKindOrder
  if (options.groupKind === 'literals-first') {
    groupKindOrder = ['literal', 'spread']
  } else if (options.groupKind === 'spreads-first') {
    groupKindOrder = ['spread', 'literal']
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
      sortNodesExcludingEslintDisabled,
      availableMessageIds,
      sourceCode,
      options,
      context,
      nodes,
    })
  }
}
function getNodeName({ sourceCode, element }) {
  return element.type === 'Literal'
    ? `${element.value}`
    : sourceCode.getText(element)
}
exports.default = sortArrayIncludes
exports.defaultOptions = defaultOptions
exports.jsonSchema = jsonSchema
exports.sortArray = sortArray

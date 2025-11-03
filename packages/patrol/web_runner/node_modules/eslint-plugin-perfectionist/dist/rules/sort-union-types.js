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
const generatePredefinedGroups = require('../utils/generate-predefined-groups.js')
const getEslintDisabledLines = require('../utils/get-eslint-disabled-lines.js')
const isNodeEslintDisabled = require('../utils/is-node-eslint-disabled.js')
const doesCustomGroupMatch = require('../utils/does-custom-group-match.js')
const types = require('./sort-union-types/types.js')
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
  newlinesBetween: 'ignore',
  partitionByNewLine: false,
  partitionByComment: false,
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
}
const sortUnionTypes = createEslintRule.createEslintRule({
  create: context => ({
    TSUnionType: node => {
      sortUnionOrIntersectionTypes({
        availableMessageIds: {
          missedSpacingBetweenMembers: 'missedSpacingBetweenUnionTypes',
          extraSpacingBetweenMembers: 'extraSpacingBetweenUnionTypes',
          unexpectedGroupOrder: 'unexpectedUnionTypesGroupOrder',
          unexpectedOrder: 'unexpectedUnionTypesOrder',
        },
        tokenValueToIgnoreBefore: '|',
        context,
        node,
      })
    },
  }),
  meta: {
    messages: {
      missedSpacingBetweenUnionTypes: reportErrors.MISSED_SPACING_ERROR,
      extraSpacingBetweenUnionTypes: reportErrors.EXTRA_SPACING_ERROR,
      unexpectedUnionTypesGroupOrder: reportErrors.GROUP_ORDER_ERROR,
      unexpectedUnionTypesOrder: reportErrors.ORDER_ERROR,
    },
    docs: {
      url: 'https://perfectionist.dev/rules/sort-union-types',
      description: 'Enforce sorted union types.',
      recommended: true,
    },
    schema: jsonSchema,
    type: 'suggestion',
    fixable: 'code',
  },
  defaultOptions: [defaultOptions],
  name: 'sort-union-types',
})
function sortUnionOrIntersectionTypes({
  tokenValueToIgnoreBefore,
  availableMessageIds,
  context,
  node,
}) {
  let settings = getSettings.getSettings(context.settings)
  let options = complete.complete(
    context.options.at(0),
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
  let { sourceCode, id } = context
  let eslintDisabledLines = getEslintDisabledLines.getEslintDisabledLines({
    ruleName: id,
    sourceCode,
  })
  let formattedMembers = node.types.reduce(
    (accumulator, type) => {
      let selectors = []
      switch (type.type) {
        case 'TSTemplateLiteralType':
        case 'TSLiteralType':
          selectors.push('literal')
          break
        case 'TSIndexedAccessType':
        case 'TSTypeReference':
        case 'TSQualifiedName':
        case 'TSArrayType':
        case 'TSInferType':
          selectors.push('named')
          break
        case 'TSIntersectionType':
          selectors.push('intersection')
          break
        case 'TSUndefinedKeyword':
        case 'TSNullKeyword':
        case 'TSVoidKeyword':
          selectors.push('nullish')
          break
        case 'TSConditionalType':
          selectors.push('conditional')
          break
        case 'TSConstructorType':
        case 'TSFunctionType':
          selectors.push('function')
          break
        case 'TSBooleanKeyword':
        case 'TSUnknownKeyword':
        case 'TSBigIntKeyword':
        case 'TSNumberKeyword':
        case 'TSObjectKeyword':
        case 'TSStringKeyword':
        case 'TSSymbolKeyword':
        case 'TSNeverKeyword':
        case 'TSAnyKeyword':
        case 'TSThisType':
          selectors.push('keyword')
          break
        case 'TSTypeOperator':
        case 'TSTypeQuery':
          selectors.push('operator')
          break
        case 'TSTypeLiteral':
        case 'TSMappedType':
          selectors.push('object')
          break
        case 'TSImportType':
          selectors.push('import')
          break
        case 'TSTupleType':
          selectors.push('tuple')
          break
        case 'TSUnionType':
          selectors.push('union')
          break
      }
      let name = sourceCode.getText(type)
      let predefinedGroups = generatePredefinedGroups.generatePredefinedGroups({
        cache: cachedGroupsByModifiersAndSelectors,
        modifiers: [],
        selectors,
      })
      let group = computeGroup.computeGroup({
        customGroupMatcher: customGroup =>
          doesCustomGroupMatch.doesCustomGroupMatch({
            elementName: name,
            modifiers: [],
            customGroup,
            selectors,
          }),
        predefinedGroups,
        options,
      })
      let lastGroup = accumulator.at(-1)
      let lastSortingNode = lastGroup?.at(-1)
      let sortingNode = {
        isEslintDisabled: isNodeEslintDisabled.isNodeEslintDisabled(
          type,
          eslintDisabledLines,
        ),
        size: rangeToDiff.rangeToDiff(type, sourceCode),
        node: type,
        group,
        name,
      }
      if (
        shouldPartition.shouldPartition({
          tokenValueToIgnoreBefore,
          lastSortingNode,
          sortingNode,
          sourceCode,
          options,
        })
      ) {
        lastGroup = []
        accumulator.push(lastGroup)
      }
      lastGroup?.push({
        ...sortingNode,
        partitionId: accumulator.length,
      })
      return accumulator
    },
    [[]],
  )
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
      sortNodesExcludingEslintDisabled:
        createSortNodesExcludingEslintDisabled(nodes),
      availableMessageIds,
      sourceCode,
      options,
      context,
      nodes,
    })
  }
}
exports.default = sortUnionTypes
exports.jsonSchema = jsonSchema
exports.sortUnionOrIntersectionTypes = sortUnionOrIntersectionTypes

'use strict'
Object.defineProperties(exports, {
  __esModule: { value: true },
  [Symbol.toStringTag]: { value: 'Module' },
})
const commonJsonSchemas = require('../utils/common-json-schemas.js')
const reportErrors = require('../utils/report-errors.js')
const validateNewlinesAndPartitionConfiguration = require('../utils/validate-newlines-and-partition-configuration.js')
const types = require('./sort-object-types/types.js')
const validateGeneratedGroupsConfiguration = require('../utils/validate-generated-groups-configuration.js')
const getCustomGroupsCompareOptions = require('./sort-object-types/get-custom-groups-compare-options.js')
const validateCustomSortConfiguration = require('../utils/validate-custom-sort-configuration.js')
const getMatchingContextOptions = require('../utils/get-matching-context-options.js')
const generatePredefinedGroups = require('../utils/generate-predefined-groups.js')
const getEslintDisabledLines = require('../utils/get-eslint-disabled-lines.js')
const isMemberOptional = require('./sort-object-types/is-member-optional.js')
const isNodeEslintDisabled = require('../utils/is-node-eslint-disabled.js')
const doesCustomGroupMatch = require('../utils/does-custom-group-match.js')
const isNodeFunctionType = require('../utils/is-node-function-type.js')
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
  fallbackSort: { type: 'unsorted', sortBy: 'name' },
  partitionByComment: false,
  partitionByNewLine: false,
  newlinesBetween: 'ignore',
  specialCharacters: 'keep',
  useConfigurationIf: {},
  type: 'alphabetical',
  groupKind: 'mixed',
  ignorePattern: [],
  ignoreCase: true,
  customGroups: {},
  locales: 'en-US',
  sortBy: 'name',
  alphabet: '',
  order: 'asc',
  groups: [],
}
let jsonSchema = {
  items: {
    properties: {
      ...commonJsonSchemas.buildCommonJsonSchemas({
        additionalFallbackSortProperties: {
          sortBy: types.sortByJsonSchema,
        },
      }),
      customGroups: {
        oneOf: [
          commonJsonSchemas.deprecatedCustomGroupsJsonSchema,
          commonJsonSchemas.buildCustomGroupsArrayJsonSchema({
            additionalFallbackSortProperties: {
              sortBy: types.sortByJsonSchema,
            },
            singleCustomGroupJsonSchema: types.singleCustomGroupJsonSchema,
          }),
        ],
      },
      groupKind: {
        description: '[DEPRECATED] Specifies top-level groups.',
        enum: ['mixed', 'required-first', 'optional-first'],
        type: 'string',
      },
      useConfigurationIf: commonJsonSchemas.buildUseConfigurationIfJsonSchema({
        additionalProperties: {
          declarationMatchesPattern: commonJsonSchemas.regexJsonSchema,
        },
      }),
      partitionByComment: commonJsonSchemas.partitionByCommentJsonSchema,
      partitionByNewLine: commonJsonSchemas.partitionByNewLineJsonSchema,
      newlinesBetween: commonJsonSchemas.newlinesBetweenJsonSchema,
      ignorePattern: commonJsonSchemas.regexJsonSchema,
      sortBy: types.sortByJsonSchema,
      groups: commonJsonSchemas.groupsJsonSchema,
    },
    additionalProperties: false,
    type: 'object',
  },
  uniqueItems: true,
  type: 'array',
}
const sortObjectTypes = createEslintRule.createEslintRule({
  create: context => ({
    TSTypeLiteral: node =>
      sortObjectTypeElements({
        availableMessageIds: {
          missedSpacingBetweenMembers: 'missedSpacingBetweenObjectTypeMembers',
          extraSpacingBetweenMembers: 'extraSpacingBetweenObjectTypeMembers',
          unexpectedGroupOrder: 'unexpectedObjectTypesGroupOrder',
          unexpectedOrder: 'unexpectedObjectTypesOrder',
        },
        parentNodeName:
          node.parent.type === 'TSTypeAliasDeclaration'
            ? node.parent.id.name
            : null,
        elements: node.members,
        context,
      }),
  }),
  meta: {
    messages: {
      missedSpacingBetweenObjectTypeMembers: reportErrors.MISSED_SPACING_ERROR,
      extraSpacingBetweenObjectTypeMembers: reportErrors.EXTRA_SPACING_ERROR,
      unexpectedObjectTypesGroupOrder: reportErrors.GROUP_ORDER_ERROR,
      unexpectedObjectTypesOrder: reportErrors.ORDER_ERROR,
    },
    docs: {
      url: 'https://perfectionist.dev/rules/sort-object-types',
      description: 'Enforce sorted object types.',
      recommended: true,
    },
    schema: jsonSchema,
    type: 'suggestion',
    fixable: 'code',
  },
  defaultOptions: [defaultOptions],
  name: 'sort-object-types',
})
function sortObjectTypeElements({
  availableMessageIds,
  parentNodeName,
  elements,
  context,
}) {
  if (!isSortable.isSortable(elements)) {
    return
  }
  let settings = getSettings.getSettings(context.settings)
  let { sourceCode, id } = context
  let matchedContextOptions = getMatchingContextOptions
    .getMatchingContextOptions({
      nodeNames: elements.map(node =>
        getNodeName({ typeElement: node, sourceCode }),
      ),
      contextOptions: context.options,
    })
    .find(options2 => {
      if (!options2.useConfigurationIf?.declarationMatchesPattern) {
        return true
      }
      if (!parentNodeName) {
        return false
      }
      return matches.matches(
        parentNodeName,
        options2.useConfigurationIf.declarationMatchesPattern,
      )
    })
  let options = complete.complete(
    matchedContextOptions,
    settings,
    defaultOptions,
  )
  validateCustomSortConfiguration.validateCustomSortConfiguration(options)
  validateGeneratedGroupsConfiguration.validateGeneratedGroupsConfiguration({
    selectors: types.allSelectors,
    modifiers: types.allModifiers,
    options,
  })
  validateNewlinesAndPartitionConfiguration.validateNewlinesAndPartitionConfiguration(
    options,
  )
  if (
    parentNodeName &&
    matches.matches(parentNodeName, options.ignorePattern)
  ) {
    return
  }
  let eslintDisabledLines = getEslintDisabledLines.getEslintDisabledLines({
    ruleName: id,
    sourceCode,
  })
  let formattedMembers = elements.reduce(
    (accumulator, typeElement) => {
      if (
        typeElement.type === 'TSCallSignatureDeclaration' ||
        typeElement.type === 'TSConstructSignatureDeclaration'
      ) {
        accumulator.push([])
        return accumulator
      }
      let lastGroup = accumulator.at(-1)
      let lastSortingNode = lastGroup?.at(-1)
      let selectors = []
      let modifiers = []
      if (typeElement.type === 'TSIndexSignature') {
        selectors.push('index-signature')
      }
      if (isNodeFunctionType.isNodeFunctionType(typeElement)) {
        selectors.push('method')
      }
      if (typeElement.loc.start.line !== typeElement.loc.end.line) {
        modifiers.push('multiline')
        selectors.push('multiline')
      }
      if (
        !['index-signature', 'method'].some(selector =>
          selectors.includes(selector),
        )
      ) {
        selectors.push('property')
      }
      selectors.push('member')
      if (isMemberOptional.isMemberOptional(typeElement)) {
        modifiers.push('optional')
      } else {
        modifiers.push('required')
      }
      let name = getNodeName({ typeElement, sourceCode })
      let value = null
      if (
        typeElement.type === 'TSPropertySignature' &&
        typeElement.typeAnnotation
      ) {
        value = sourceCode.getText(typeElement.typeAnnotation.typeAnnotation)
      }
      let predefinedGroups = generatePredefinedGroups.generatePredefinedGroups({
        cache: cachedGroupsByModifiersAndSelectors,
        selectors,
        modifiers,
      })
      let group = computeGroup.computeGroup({
        customGroupMatcher: customGroup =>
          doesCustomGroupMatch.doesCustomGroupMatch({
            elementValue: value,
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
          typeElement,
          eslintDisabledLines,
        ),
        groupKind: isMemberOptional.isMemberOptional(typeElement)
          ? 'optional'
          : 'required',
        size: rangeToDiff.rangeToDiff(typeElement, sourceCode),
        addSafetySemicolonWhenInline: true,
        partitionId: accumulator.length,
        node: typeElement,
        group,
        value,
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
        lastGroup = []
        accumulator.push(lastGroup)
      }
      lastGroup?.push(sortingNode)
      return accumulator
    },
    [[]],
  )
  let groupKindOrder
  if (options.groupKind === 'required-first') {
    groupKindOrder = ['required', 'optional']
  } else if (options.groupKind === 'optional-first') {
    groupKindOrder = ['optional', 'required']
  } else {
    groupKindOrder = ['any']
  }
  for (let nodes of formattedMembers) {
    let sortNodesExcludingEslintDisabled = function (
      ignoreEslintDisabledNodes,
    ) {
      return filteredGroupKindNodes.flatMap(groupedNodes =>
        sortNodesByGroups.sortNodesByGroups({
          getOptionsByGroupIndex: groupIndex => {
            let {
              fallbackSortNodeValueGetter,
              options: overriddenOptions,
              nodeValueGetter,
            } = getCustomGroupsCompareOptions.getCustomGroupsCompareOptions(
              options,
              groupIndex,
            )
            return {
              options: {
                ...options,
                ...overriddenOptions,
              },
              fallbackSortNodeValueGetter,
              nodeValueGetter,
            }
          },
          isNodeIgnoredForGroup: (node, groupOptions) => {
            if (groupOptions.sortBy === 'value') {
              return !node.value
            }
            return false
          },
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
function getNodeName({ typeElement, sourceCode }) {
  let name
  function formatName(value) {
    return value.replace(/[,;]$/u, '')
  }
  if (typeElement.type === 'TSPropertySignature') {
    if (typeElement.key.type === 'Identifier') {
      ;({ name } = typeElement.key)
    } else if (typeElement.key.type === 'Literal') {
      name = `${typeElement.key.value}`
    } else {
      let end =
        typeElement.typeAnnotation?.range.at(0) ??
        typeElement.range.at(1) - (typeElement.optional ? '?'.length : 0)
      name = sourceCode.text.slice(typeElement.range.at(0), end)
    }
  } else if (typeElement.type === 'TSIndexSignature') {
    let endIndex =
      typeElement.typeAnnotation?.range.at(0) ?? typeElement.range.at(1)
    name = formatName(sourceCode.text.slice(typeElement.range.at(0), endIndex))
  } else if (
    typeElement.type === 'TSMethodSignature' &&
    'name' in typeElement.key
  ) {
    ;({ name } = typeElement.key)
  } else {
    name = formatName(
      sourceCode.text.slice(typeElement.range.at(0), typeElement.range.at(1)),
    )
  }
  return name
}
exports.default = sortObjectTypes
exports.jsonSchema = jsonSchema
exports.sortObjectTypeElements = sortObjectTypeElements

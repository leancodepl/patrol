'use strict'
const types$1 = require('@typescript-eslint/types')
const commonJsonSchemas = require('../utils/common-json-schemas.js')
const reportErrors = require('../utils/report-errors.js')
const validateNewlinesAndPartitionConfiguration = require('../utils/validate-newlines-and-partition-configuration.js')
const getCustomGroupsCompareOptions = require('../utils/get-custom-groups-compare-options.js')
const validateGeneratedGroupsConfiguration = require('../utils/validate-generated-groups-configuration.js')
const types = require('./sort-objects/types.js')
const validateCustomSortConfiguration = require('../utils/validate-custom-sort-configuration.js')
const getFirstNodeParentWithType = require('./sort-objects/get-first-node-parent-with-type.js')
const getMatchingContextOptions = require('../utils/get-matching-context-options.js')
const generatePredefinedGroups = require('../utils/generate-predefined-groups.js')
const sortNodesByDependencies = require('../utils/sort-nodes-by-dependencies.js')
const getEslintDisabledLines = require('../utils/get-eslint-disabled-lines.js')
const isNodeEslintDisabled = require('../utils/is-node-eslint-disabled.js')
const doesCustomGroupMatch = require('../utils/does-custom-group-match.js')
const unreachableCaseError = require('../utils/unreachable-case-error.js')
const sortNodesByGroups = require('../utils/sort-nodes-by-groups.js')
const createEslintRule = require('../utils/create-eslint-rule.js')
const reportAllErrors = require('../utils/report-all-errors.js')
const shouldPartition = require('../utils/should-partition.js')
const computeGroup = require('../utils/compute-group.js')
const rangeToDiff = require('../utils/range-to-diff.js')
const getSettings = require('../utils/get-settings.js')
const isSortable = require('../utils/is-sortable.js')
const sortNodes = require('../utils/sort-nodes.js')
const complete = require('../utils/complete.js')
const matches = require('../utils/matches.js')
let cachedGroupsByModifiersAndSelectors = /* @__PURE__ */ new Map()
let defaultOptions = {
  fallbackSort: { type: 'unsorted' },
  partitionByNewLine: false,
  partitionByComment: false,
  newlinesBetween: 'ignore',
  specialCharacters: 'keep',
  destructuredObjects: true,
  objectDeclarations: true,
  styledComponents: true,
  destructureOnly: false,
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
const sortObjects = createEslintRule.createEslintRule({
  create: context => {
    let settings = getSettings.getSettings(context.settings)
    let { sourceCode, id } = context
    function sortObject(nodeObject) {
      if (!isSortable.isSortable(nodeObject.properties)) {
        return
      }
      let objectParent = getObjectParent({
        onlyFirstParent: true,
        node: nodeObject,
        sourceCode,
      })
      let matchedContextOptions = getMatchingContextOptions
        .getMatchingContextOptions({
          nodeNames: nodeObject.properties
            .filter(
              property =>
                property.type !== 'SpreadElement' &&
                property.type !== 'RestElement',
            )
            .map(property => getNodeName({ sourceCode, property })),
          contextOptions: context.options,
        })
        .find(options2 => {
          if (!options2.useConfigurationIf?.callingFunctionNamePattern) {
            return true
          }
          if (
            objectParent?.type === 'VariableDeclarator' ||
            !objectParent?.name
          ) {
            return false
          }
          return matches.matches(
            objectParent.name,
            options2.useConfigurationIf.callingFunctionNamePattern,
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
      let isDestructuredObject = nodeObject.type === 'ObjectPattern'
      if (isDestructuredObject) {
        if (!options.destructuredObjects) {
          return
        }
      } else if (options.destructureOnly || !options.objectDeclarations) {
        return
      }
      let objectParentForIgnorePattern = getObjectParent({
        onlyFirstParent: false,
        node: nodeObject,
        sourceCode,
      })
      if (
        objectParentForIgnorePattern?.name &&
        matches.matches(
          objectParentForIgnorePattern.name,
          options.ignorePattern,
        )
      ) {
        return
      }
      let objectRoot =
        nodeObject.type === 'ObjectPattern' ? null : getRootObject(nodeObject)
      if (
        objectRoot &&
        !options.styledComponents &&
        (isStyledComponents(objectRoot.parent) ||
          (objectRoot.parent.type === 'ArrowFunctionExpression' &&
            isStyledComponents(objectRoot.parent.parent)))
      ) {
        return
      }
      let eslintDisabledLines = getEslintDisabledLines.getEslintDisabledLines({
        ruleName: id,
        sourceCode,
      })
      function extractDependencies(init) {
        let dependencies = []
        function checkNode(nodeValue) {
          if (
            nodeValue.type === 'ArrowFunctionExpression' ||
            nodeValue.type === 'FunctionExpression'
          ) {
            return
          }
          if (nodeValue.type === 'Identifier') {
            dependencies.push(nodeValue.name)
          }
          if (nodeValue.type === 'Property') {
            traverseNode(nodeValue.key)
            traverseNode(nodeValue.value)
          }
          if (nodeValue.type === 'ConditionalExpression') {
            traverseNode(nodeValue.test)
            traverseNode(nodeValue.consequent)
            traverseNode(nodeValue.alternate)
          }
          if (
            'expression' in nodeValue &&
            typeof nodeValue.expression !== 'boolean'
          ) {
            traverseNode(nodeValue.expression)
          }
          if ('object' in nodeValue) {
            traverseNode(nodeValue.object)
          }
          if ('callee' in nodeValue) {
            traverseNode(nodeValue.callee)
          }
          if ('left' in nodeValue) {
            traverseNode(nodeValue.left)
          }
          if ('right' in nodeValue) {
            traverseNode(nodeValue.right)
          }
          if ('elements' in nodeValue) {
            let elements = nodeValue.elements.filter(
              currentNode => currentNode !== null,
            )
            for (let element of elements) {
              traverseNode(element)
            }
          }
          if ('argument' in nodeValue && nodeValue.argument) {
            traverseNode(nodeValue.argument)
          }
          if ('arguments' in nodeValue) {
            for (let argument of nodeValue.arguments) {
              traverseNode(argument)
            }
          }
          if ('properties' in nodeValue) {
            for (let property of nodeValue.properties) {
              traverseNode(property)
            }
          }
          if ('expressions' in nodeValue) {
            for (let nodeExpression of nodeValue.expressions) {
              traverseNode(nodeExpression)
            }
          }
        }
        function traverseNode(nodeValue) {
          checkNode(nodeValue)
        }
        traverseNode(init)
        return dependencies
      }
      function formatProperties(props) {
        return props.reduce(
          (accumulator, property) => {
            if (
              property.type === 'SpreadElement' ||
              property.type === 'RestElement'
            ) {
              accumulator.push([])
              return accumulator
            }
            let lastSortingNode = accumulator.at(-1)?.at(-1)
            let dependencies = []
            let selectors = []
            let modifiers = []
            if (property.value.type === 'AssignmentPattern') {
              dependencies = extractDependencies(property.value.right)
            }
            if (
              property.value.type === 'ArrowFunctionExpression' ||
              property.value.type === 'FunctionExpression'
            ) {
              selectors.push('method')
            } else {
              selectors.push('property')
            }
            selectors.push('member')
            if (property.loc.start.line !== property.loc.end.line) {
              modifiers.push('multiline')
              selectors.push('multiline')
            }
            let name = getNodeName({ sourceCode, property })
            let predefinedGroups =
              generatePredefinedGroups.generatePredefinedGroups({
                cache: cachedGroupsByModifiersAndSelectors,
                selectors,
                modifiers,
              })
            let group = computeGroup.computeGroup({
              customGroupMatcher: customGroup =>
                doesCustomGroupMatch.doesCustomGroupMatch({
                  elementValue: getNodeValue({
                    sourceCode,
                    property,
                  }),
                  elementName: name,
                  customGroup,
                  selectors,
                  modifiers,
                }),
              predefinedGroups,
              options,
              name,
            })
            let dependencyName = name
            if (isDestructuredObject && property.value.type === 'Identifier') {
              dependencyName = property.value.name
            }
            let sortingNode = {
              isEslintDisabled: isNodeEslintDisabled.isNodeEslintDisabled(
                property,
                eslintDisabledLines,
              ),
              size: rangeToDiff.rangeToDiff(property, sourceCode),
              dependencyNames: [dependencyName],
              node: property,
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
      }
      let formattedMembers = formatProperties(nodeObject.properties)
      let sortingOptions = options
      let nodesSortingFunction =
        isDestructuredObject &&
        typeof options.destructuredObjects === 'object' &&
        !options.destructuredObjects.groups
          ? 'sortNodes'
          : 'sortNodesByGroups'
      function sortNodesExcludingEslintDisabled(ignoreEslintDisabledNodes) {
        let nodesSortedByGroups = formattedMembers.flatMap(nodes2 =>
          nodesSortingFunction === 'sortNodes'
            ? sortNodes.sortNodes({
                ignoreEslintDisabledNodes,
                options: sortingOptions,
                nodes: nodes2,
              })
            : sortNodesByGroups.sortNodesByGroups({
                getOptionsByGroupIndex:
                  getCustomGroupsCompareOptions.buildGetCustomGroupOverriddenOptionsFunction(
                    options,
                  ),
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
      let nodes = formattedMembers.flat()
      reportAllErrors.reportAllErrors({
        availableMessageIds: {
          missedSpacingBetweenMembers: 'missedSpacingBetweenObjectMembers',
          extraSpacingBetweenMembers: 'extraSpacingBetweenObjectMembers',
          unexpectedDependencyOrder: 'unexpectedObjectsDependencyOrder',
          unexpectedGroupOrder: 'unexpectedObjectsGroupOrder',
          unexpectedOrder: 'unexpectedObjectsOrder',
        },
        sortNodesExcludingEslintDisabled,
        sourceCode,
        options,
        context,
        nodes,
      })
    }
    return {
      ObjectExpression: sortObject,
      ObjectPattern: sortObject,
    }
  },
  meta: {
    schema: {
      items: {
        properties: {
          ...commonJsonSchemas.commonJsonSchemas,
          destructuredObjects: {
            oneOf: [
              {
                type: 'boolean',
              },
              {
                properties: {
                  groups: {
                    description:
                      'Controls whether to use groups to sort destructured objects.',
                    type: 'boolean',
                  },
                },
                additionalProperties: false,
                type: 'object',
              },
            ],
            description: 'Controls whether to sort destructured objects.',
          },
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
                callingFunctionNamePattern: commonJsonSchemas.regexJsonSchema,
              },
            }),
          destructureOnly: {
            description:
              '[DEPRECATED] Controls whether to sort only destructured objects.',
            type: 'boolean',
          },
          objectDeclarations: {
            description: 'Controls whether to sort object declarations.',
            type: 'boolean',
          },
          styledComponents: {
            description: 'Controls whether to sort styled components.',
            type: 'boolean',
          },
          partitionByComment: commonJsonSchemas.partitionByCommentJsonSchema,
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
      unexpectedObjectsDependencyOrder: reportErrors.DEPENDENCY_ORDER_ERROR,
      missedSpacingBetweenObjectMembers: reportErrors.MISSED_SPACING_ERROR,
      extraSpacingBetweenObjectMembers: reportErrors.EXTRA_SPACING_ERROR,
      unexpectedObjectsGroupOrder: reportErrors.GROUP_ORDER_ERROR,
      unexpectedObjectsOrder: reportErrors.ORDER_ERROR,
    },
    docs: {
      url: 'https://perfectionist.dev/rules/sort-objects',
      description: 'Enforce sorted objects.',
      recommended: true,
    },
    type: 'suggestion',
    fixable: 'code',
  },
  defaultOptions: [defaultOptions],
  name: 'sort-objects',
})
function getVariableParentName({ onlyFirstParent, node }) {
  let variableParent = getFirstNodeParentWithType.getFirstNodeParentWithType({
    allowedTypes: [
      types$1.TSESTree.AST_NODE_TYPES.VariableDeclarator,
      types$1.TSESTree.AST_NODE_TYPES.Property,
    ],
    onlyFirstParent,
    node,
  })
  if (!variableParent) {
    return null
  }
  let parentId
  switch (variableParent.type) {
    case types$1.TSESTree.AST_NODE_TYPES.VariableDeclarator:
      parentId = variableParent.id
      break
    case types$1.TSESTree.AST_NODE_TYPES.Property:
      parentId = variableParent.key
      break
    /* v8 ignore next 2 */
    default:
      throw new unreachableCaseError.UnreachableCaseError(variableParent)
  }
  return parentId.type === 'Identifier' ? parentId.name : null
}
function getObjectParent({ onlyFirstParent, sourceCode, node }) {
  let variableParentName = getVariableParentName({
    onlyFirstParent,
    node,
  })
  if (variableParentName) {
    return {
      type: 'VariableDeclarator',
      name: variableParentName,
    }
  }
  let callParentName = getCallExpressionParentName({
    onlyFirstParent,
    sourceCode,
    node,
  })
  if (callParentName) {
    return {
      type: 'CallExpression',
      name: callParentName,
    }
  }
  return null
}
function isStyledComponents(styledNode) {
  if (
    styledNode.type === 'JSXExpressionContainer' &&
    styledNode.parent.type === 'JSXAttribute' &&
    styledNode.parent.name.name === 'style'
  ) {
    return true
  }
  if (styledNode.type !== 'CallExpression') {
    return false
  }
  return (
    isCssCallExpression(styledNode.callee) ||
    (styledNode.callee.type === 'MemberExpression' &&
      isStyledCallExpression(styledNode.callee.object)) ||
    (styledNode.callee.type === 'CallExpression' &&
      isStyledCallExpression(styledNode.callee.callee))
  )
}
function getCallExpressionParentName({ onlyFirstParent, sourceCode, node }) {
  let callParent = getFirstNodeParentWithType.getFirstNodeParentWithType({
    allowedTypes: [types$1.TSESTree.AST_NODE_TYPES.CallExpression],
    onlyFirstParent,
    node,
  })
  if (!callParent) {
    return null
  }
  return sourceCode.getText(callParent.callee)
}
function getNodeName({ sourceCode, property }) {
  if (property.key.type === 'Identifier') {
    return property.key.name
  } else if (property.key.type === 'Literal') {
    return `${property.key.value}`
  }
  return sourceCode.getText(property.key)
}
function getNodeValue({ sourceCode, property }) {
  if (
    property.value.type === 'ArrowFunctionExpression' ||
    property.value.type === 'FunctionExpression'
  ) {
    return null
  }
  return sourceCode.getText(property.value)
}
function getRootObject(node) {
  let objectRoot = node
  while (
    objectRoot.parent.type === 'Property' &&
    objectRoot.parent.parent.type === 'ObjectExpression'
  ) {
    objectRoot = objectRoot.parent.parent
  }
  return objectRoot
}
function isStyledCallExpression(identifier) {
  return identifier.type === 'Identifier' && identifier.name === 'styled'
}
function isCssCallExpression(identifier) {
  return identifier.type === 'Identifier' && identifier.name === 'css'
}
module.exports = sortObjects

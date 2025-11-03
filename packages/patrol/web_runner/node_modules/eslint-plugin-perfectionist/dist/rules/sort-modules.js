'use strict'
const utils = require('@typescript-eslint/utils')
const commonJsonSchemas = require('../utils/common-json-schemas.js')
const reportErrors = require('../utils/report-errors.js')
const validateNewlinesAndPartitionConfiguration = require('../utils/validate-newlines-and-partition-configuration.js')
const getCustomGroupsCompareOptions = require('../utils/get-custom-groups-compare-options.js')
const validateGeneratedGroupsConfiguration = require('../utils/validate-generated-groups-configuration.js')
const types = require('./sort-modules/types.js')
const validateCustomSortConfiguration = require('../utils/validate-custom-sort-configuration.js')
const generatePredefinedGroups = require('../utils/generate-predefined-groups.js')
const sortNodesByDependencies = require('../utils/sort-nodes-by-dependencies.js')
const getEslintDisabledLines = require('../utils/get-eslint-disabled-lines.js')
const isNodeEslintDisabled = require('../utils/is-node-eslint-disabled.js')
const doesCustomGroupMatch = require('../utils/does-custom-group-match.js')
const sortNodesByGroups = require('../utils/sort-nodes-by-groups.js')
const getNodeDecorators = require('../utils/get-node-decorators.js')
const createEslintRule = require('../utils/create-eslint-rule.js')
const getDecoratorName = require('../utils/get-decorator-name.js')
const reportAllErrors = require('../utils/report-all-errors.js')
const shouldPartition = require('../utils/should-partition.js')
const getEnumMembers = require('../utils/get-enum-members.js')
const getGroupIndex = require('../utils/get-group-index.js')
const computeGroup = require('../utils/compute-group.js')
const rangeToDiff = require('../utils/range-to-diff.js')
const getSettings = require('../utils/get-settings.js')
const isSortable = require('../utils/is-sortable.js')
const complete = require('../utils/complete.js')
let cachedGroupsByModifiersAndSelectors = /* @__PURE__ */ new Map()
let defaultOptions = {
  groups: [
    'declare-enum',
    'export-enum',
    'enum',
    ['declare-interface', 'declare-type'],
    ['export-interface', 'export-type'],
    ['interface', 'type'],
    'declare-class',
    'class',
    'export-class',
    'declare-function',
    'export-function',
    'function',
  ],
  fallbackSort: { type: 'unsorted' },
  partitionByComment: false,
  partitionByNewLine: false,
  newlinesBetween: 'ignore',
  specialCharacters: 'keep',
  type: 'alphabetical',
  ignoreCase: true,
  customGroups: [],
  locales: 'en-US',
  alphabet: '',
  order: 'asc',
}
const sortModules = createEslintRule.createEslintRule({
  meta: {
    schema: [
      {
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
    ],
    messages: {
      unexpectedModulesDependencyOrder: reportErrors.DEPENDENCY_ORDER_ERROR,
      missedSpacingBetweenModulesMembers: reportErrors.MISSED_SPACING_ERROR,
      extraSpacingBetweenModulesMembers: reportErrors.EXTRA_SPACING_ERROR,
      unexpectedModulesGroupOrder: reportErrors.GROUP_ORDER_ERROR,
      unexpectedModulesOrder: reportErrors.ORDER_ERROR,
    },
    docs: {
      url: 'https://perfectionist.dev/rules/sort-modules',
      description: 'Enforce sorted modules.',
      recommended: true,
    },
    type: 'suggestion',
    fixable: 'code',
  },
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
    return {
      Program: program => {
        if (isSortable.isSortable(program.body)) {
          return analyzeModule({
            eslintDisabledLines,
            sourceCode,
            options,
            program,
            context,
          })
        }
      },
    }
  },
  defaultOptions: [defaultOptions],
  name: 'sort-modules',
})
function analyzeModule({
  eslintDisabledLines,
  sourceCode,
  options,
  program,
  context,
}) {
  let formattedNodes = [[]]
  for (let node of program.body) {
    let parseNode = function (nodeToParse) {
      if ('declare' in nodeToParse && nodeToParse.declare) {
        modifiers.push('declare')
      }
      switch (nodeToParse.type) {
        case utils.AST_NODE_TYPES.ExportDefaultDeclaration:
          modifiers.push('default', 'export')
          parseNode(nodeToParse.declaration)
          break
        case utils.AST_NODE_TYPES.ExportNamedDeclaration:
          if (nodeToParse.declaration) {
            parseNode(nodeToParse.declaration)
          }
          modifiers.push('export')
          break
        case utils.AST_NODE_TYPES.TSInterfaceDeclaration:
          selector = 'interface'
          ;({ name } = nodeToParse.id)
          break
        case utils.AST_NODE_TYPES.TSTypeAliasDeclaration:
          selector = 'type'
          ;({ name } = nodeToParse.id)
          addSafetySemicolonWhenInline = true
          break
        case utils.AST_NODE_TYPES.FunctionDeclaration:
        case utils.AST_NODE_TYPES.TSDeclareFunction:
          selector = 'function'
          if (nodeToParse.async) {
            modifiers.push('async')
          }
          if (modifiers.includes('declare')) {
            addSafetySemicolonWhenInline = true
          }
          name = nodeToParse.id?.name
          break
        case utils.AST_NODE_TYPES.TSModuleDeclaration:
          formattedNodes.push([])
          if (nodeToParse.body) {
            analyzeModule({
              program: nodeToParse.body,
              eslintDisabledLines,
              sourceCode,
              options,
              context,
            })
          }
          break
        case utils.AST_NODE_TYPES.VariableDeclaration:
        case utils.AST_NODE_TYPES.ExpressionStatement:
          formattedNodes.push([])
          break
        case utils.AST_NODE_TYPES.TSEnumDeclaration:
          selector = 'enum'
          ;({ name } = nodeToParse.id)
          dependencies = [
            ...dependencies,
            ...getEnumMembers
              .getEnumMembers(nodeToParse)
              .flatMap(extractDependencies),
          ]
          break
        case utils.AST_NODE_TYPES.ClassDeclaration:
          selector = 'class'
          name = nodeToParse.id?.name
          let nodeDecorators = getNodeDecorators.getNodeDecorators(nodeToParse)
          if (nodeDecorators.length > 0) {
            modifiers.push('decorated')
          }
          decorators = nodeDecorators.map(decorator =>
            getDecoratorName.getDecoratorName({
              sourceCode,
              decorator,
            }),
          )
          dependencies = [
            ...dependencies,
            ...(nodeToParse.superClass && 'name' in nodeToParse.superClass
              ? [nodeToParse.superClass.name]
              : []),
            ...extractDependencies(nodeToParse.body),
          ]
          break
      }
    }
    let selector
    let name
    let modifiers = []
    let dependencies = []
    let decorators = []
    let addSafetySemicolonWhenInline = false
    parseNode(node)
    if (!selector || !name) {
      continue
    }
    if (
      selector === 'class' &&
      modifiers.includes('export') &&
      modifiers.includes('decorated')
    ) {
      continue
    }
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
          decorators,
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
      size: rangeToDiff.rangeToDiff(node, sourceCode),
      addSafetySemicolonWhenInline,
      dependencyNames: [name],
      dependencies,
      group,
      name,
      node,
    }
    let lastSortingNode = formattedNodes.at(-1)?.at(-1)
    if (
      shouldPartition.shouldPartition({
        lastSortingNode,
        sortingNode,
        sourceCode,
        options,
      })
    ) {
      formattedNodes.push([])
    }
    formattedNodes.at(-1)?.push({
      ...sortingNode,
      partitionId: formattedNodes.length,
    })
  }
  function sortNodesExcludingEslintDisabled(ignoreEslintDisabledNodes) {
    let nodesSortedByGroups = formattedNodes.flatMap(nodes2 =>
      sortNodesByGroups.sortNodesByGroups({
        isNodeIgnored: sortingNode =>
          getGroupIndex.getGroupIndex(options.groups, sortingNode) ===
          options.groups.length,
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
  let nodes = formattedNodes.flat()
  reportAllErrors.reportAllErrors({
    availableMessageIds: {
      missedSpacingBetweenMembers: 'missedSpacingBetweenModulesMembers',
      extraSpacingBetweenMembers: 'extraSpacingBetweenModulesMembers',
      unexpectedDependencyOrder: 'unexpectedModulesDependencyOrder',
      unexpectedGroupOrder: 'unexpectedModulesGroupOrder',
      unexpectedOrder: 'unexpectedModulesOrder',
    },
    sortNodesExcludingEslintDisabled,
    sourceCode,
    options,
    context,
    nodes,
  })
}
function extractDependencies(expression) {
  let dependencies = []
  let searchStaticMethodsAndFunctionProperties =
    expression.type === 'ClassBody' &&
    expression.body.some(
      classElement =>
        classElement.type === 'StaticBlock' ||
        (classElement.static &&
          isPropertyOrAccessor(classElement) &&
          !isArrowFunction(classElement)),
    )
  function checkNode(nodeValue) {
    if (
      (nodeValue.type === 'MethodDefinition' || isArrowFunction(nodeValue)) &&
      (!nodeValue.static || !searchStaticMethodsAndFunctionProperties)
    ) {
      return
    }
    if ('decorators' in nodeValue) {
      traverseNode(nodeValue.decorators)
    }
    if (
      nodeValue.type === 'NewExpression' &&
      nodeValue.callee.type === 'Identifier'
    ) {
      dependencies.push(nodeValue.callee.name)
    }
    if (nodeValue.type === 'Identifier') {
      dependencies.push(nodeValue.name)
    }
    if (nodeValue.type === 'ConditionalExpression') {
      checkNode(nodeValue.test)
      checkNode(nodeValue.consequent)
      checkNode(nodeValue.alternate)
    }
    if (
      'expression' in nodeValue &&
      typeof nodeValue.expression !== 'boolean'
    ) {
      checkNode(nodeValue.expression)
    }
    if ('object' in nodeValue) {
      checkNode(nodeValue.object)
    }
    if ('callee' in nodeValue) {
      checkNode(nodeValue.callee)
    }
    if ('init' in nodeValue && nodeValue.init) {
      checkNode(nodeValue.init)
    }
    if ('body' in nodeValue && nodeValue.body) {
      traverseNode(nodeValue.body)
    }
    if ('left' in nodeValue) {
      checkNode(nodeValue.left)
    }
    if ('right' in nodeValue) {
      checkNode(nodeValue.right)
    }
    if ('initializer' in nodeValue && nodeValue.initializer) {
      checkNode(nodeValue.initializer)
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
      checkNode(nodeValue.argument)
    }
    if ('arguments' in nodeValue) {
      for (let argument of nodeValue.arguments) {
        checkNode(argument)
      }
    }
    if ('declarations' in nodeValue) {
      for (let declaration of nodeValue.declarations) {
        checkNode(declaration)
      }
    }
    if ('properties' in nodeValue) {
      for (let property of nodeValue.properties) {
        checkNode(property)
      }
    }
    if (
      'value' in nodeValue &&
      nodeValue.value &&
      typeof nodeValue.value === 'object' &&
      'type' in nodeValue.value
    ) {
      checkNode(nodeValue.value)
    }
    if ('expressions' in nodeValue) {
      for (let nodeExpression of nodeValue.expressions) {
        checkNode(nodeExpression)
      }
    }
  }
  function traverseNode(nodeValue) {
    if (Array.isArray(nodeValue)) {
      for (let nodeItem of nodeValue) {
        traverseNode(nodeItem)
      }
    } else {
      checkNode(nodeValue)
    }
  }
  checkNode(expression)
  return dependencies
}
function isArrowFunction(node) {
  return (
    isPropertyOrAccessor(node) &&
    node.value !== null &&
    node.value.type === 'ArrowFunctionExpression'
  )
}
function isPropertyOrAccessor(node) {
  return node.type === 'PropertyDefinition' || node.type === 'AccessorProperty'
}
module.exports = sortModules

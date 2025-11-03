'use strict'
const commonJsonSchemas = require('../utils/common-json-schemas.js')
const reportErrors = require('../utils/report-errors.js')
const validateNewlinesAndPartitionConfiguration = require('../utils/validate-newlines-and-partition-configuration.js')
const getCustomGroupsCompareOptions = require('../utils/get-custom-groups-compare-options.js')
const validateGeneratedGroupsConfiguration = require('../utils/validate-generated-groups-configuration.js')
const types = require('./sort-classes/types.js')
const validateCustomSortConfiguration = require('../utils/validate-custom-sort-configuration.js')
const getOverloadSignatureGroups = require('./sort-classes/get-overload-signature-groups.js')
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
const getGroupIndex = require('../utils/get-group-index.js')
const computeGroup = require('../utils/compute-group.js')
const rangeToDiff = require('../utils/range-to-diff.js')
const getSettings = require('../utils/get-settings.js')
const isSortable = require('../utils/is-sortable.js')
const complete = require('../utils/complete.js')
const matches = require('../utils/matches.js')
let cachedGroupsByModifiersAndSelectors = /* @__PURE__ */ new Map()
let defaultOptions = {
  groups: [
    'index-signature',
    ['static-property', 'static-accessor-property'],
    ['static-get-method', 'static-set-method'],
    ['protected-static-property', 'protected-static-accessor-property'],
    ['protected-static-get-method', 'protected-static-set-method'],
    ['private-static-property', 'private-static-accessor-property'],
    ['private-static-get-method', 'private-static-set-method'],
    'static-block',
    ['property', 'accessor-property'],
    ['get-method', 'set-method'],
    ['protected-property', 'protected-accessor-property'],
    ['protected-get-method', 'protected-set-method'],
    ['private-property', 'private-accessor-property'],
    ['private-get-method', 'private-set-method'],
    'constructor',
    ['static-method', 'static-function-property'],
    ['protected-static-method', 'protected-static-function-property'],
    ['private-static-method', 'private-static-function-property'],
    ['method', 'function-property'],
    ['protected-method', 'protected-function-property'],
    ['private-method', 'private-function-property'],
    'unknown',
  ],
  ignoreCallbackDependenciesPatterns: [],
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
const sortClasses = createEslintRule.createEslintRule({
  create: context => ({
    ClassBody: node => {
      if (!isSortable.isSortable(node.body)) {
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
      let className = node.parent.id?.name
      function getDependencyName(props) {
        return `${props.isStatic ? 'static ' : ''}${props.isPrivateHash ? '#' : ''}${props.nodeNameWithoutStartingHash}`
      }
      let classMethodsDependencyNames = new Set(
        node.body
          .map(member => {
            if (
              (member.type === 'MethodDefinition' ||
                member.type === 'TSAbstractMethodDefinition') &&
              'name' in member.key
            ) {
              return getDependencyName({
                isPrivateHash: member.key.type === 'PrivateIdentifier',
                nodeNameWithoutStartingHash: member.key.name,
                isStatic: member.static,
              })
            }
            return null
          })
          .filter(Boolean),
      )
      function extractDependencies(expression, isMemberStatic) {
        let dependencies = []
        function checkNode(nodeValue) {
          if (
            nodeValue.type === 'MemberExpression' &&
            (nodeValue.object.type === 'ThisExpression' ||
              (nodeValue.object.type === 'Identifier' &&
                nodeValue.object.name === className)) &&
            (nodeValue.property.type === 'Identifier' ||
              nodeValue.property.type === 'PrivateIdentifier')
          ) {
            let isStaticDependency =
              isMemberStatic || nodeValue.object.type === 'Identifier'
            let dependencyName = getDependencyName({
              isPrivateHash: nodeValue.property.type === 'PrivateIdentifier',
              nodeNameWithoutStartingHash: nodeValue.property.name,
              isStatic: isStaticDependency,
            })
            if (!classMethodsDependencyNames.has(dependencyName)) {
              dependencies.push(dependencyName)
            }
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
          if ('init' in nodeValue && nodeValue.init) {
            traverseNode(nodeValue.init)
          }
          if ('body' in nodeValue && nodeValue.body) {
            traverseNode(nodeValue.body)
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
            let shouldIgnore = false
            if (nodeValue.type === 'CallExpression') {
              let functionName =
                'name' in nodeValue.callee ? nodeValue.callee.name : null
              shouldIgnore =
                functionName !== null &&
                matches.matches(
                  functionName,
                  options.ignoreCallbackDependenciesPatterns,
                )
            }
            if (!shouldIgnore) {
              for (let argument of nodeValue.arguments) {
                traverseNode(argument)
              }
            }
          }
          if ('declarations' in nodeValue) {
            for (let declaration of nodeValue.declarations) {
              traverseNode(declaration)
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
          if (Array.isArray(nodeValue)) {
            for (let nodeItem of nodeValue) {
              traverseNode(nodeItem)
            }
          } else {
            checkNode(nodeValue)
          }
        }
        traverseNode(expression)
        return dependencies
      }
      let overloadSignatureGroups =
        getOverloadSignatureGroups.getOverloadSignatureGroups(node.body)
      let formattedNodes = node.body.reduce(
        (accumulator, member) => {
          let name
          let dependencies = []
          if (member.type === 'StaticBlock') {
            name = 'static'
          } else if (member.type === 'TSIndexSignature') {
            name = sourceCode.text.slice(
              member.range.at(0),
              member.typeAnnotation?.range.at(0) ?? member.range.at(1),
            )
          } else if (member.key.type === 'Identifier') {
            ;({ name } = member.key)
          } else {
            name = sourceCode.getText(member.key)
          }
          let isPrivateHash =
            'key' in member && member.key.type === 'PrivateIdentifier'
          let decorated = false
          let decorators = []
          if ('decorators' in member) {
            decorators = getNodeDecorators
              .getNodeDecorators(member)
              .map(decorator =>
                getDecoratorName.getDecoratorName({ sourceCode, decorator }),
              )
            decorated = decorators.length > 0
          }
          let memberValue
          let modifiers = []
          let selectors = []
          let addSafetySemicolonWhenInline = true
          switch (member.type) {
            case 'TSAbstractPropertyDefinition':
            case 'PropertyDefinition':
              if ('static' in member && member.static) {
                modifiers.push('static')
              }
              if ('declare' in member && member.declare) {
                modifiers.push('declare')
              }
              if (member.type === 'TSAbstractPropertyDefinition') {
                modifiers.push('abstract')
              }
              if (decorated) {
                modifiers.push('decorated')
              }
              if ('override' in member && member.override) {
                modifiers.push('override')
              }
              if ('readonly' in member && member.readonly) {
                modifiers.push('readonly')
              }
              if (
                'accessibility' in member &&
                member.accessibility === 'protected'
              ) {
                modifiers.push('protected')
              } else if (
                ('accessibility' in member &&
                  member.accessibility === 'private') ||
                isPrivateHash
              ) {
                modifiers.push('private')
              } else {
                modifiers.push('public')
              }
              if ('optional' in member && member.optional) {
                modifiers.push('optional')
              }
              if (
                member.value?.type === 'ArrowFunctionExpression' ||
                member.value?.type === 'FunctionExpression'
              ) {
                if (member.value.async) {
                  modifiers.push('async')
                }
                selectors.push('function-property')
              } else if (member.value) {
                memberValue = sourceCode.getText(member.value)
                dependencies = extractDependencies(member.value, member.static)
              }
              selectors.push('property')
              break
            case 'TSAbstractMethodDefinition':
            case 'MethodDefinition':
              if (member.static) {
                modifiers.push('static')
              }
              if (member.type === 'TSAbstractMethodDefinition') {
                modifiers.push('abstract')
              } else if (!node.parent.declare) {
                addSafetySemicolonWhenInline = false
              }
              if (decorated) {
                modifiers.push('decorated')
              }
              if (member.override) {
                modifiers.push('override')
              }
              if (member.accessibility === 'protected') {
                modifiers.push('protected')
              } else if (member.accessibility === 'private' || isPrivateHash) {
                modifiers.push('private')
              } else {
                modifiers.push('public')
              }
              if (member.optional) {
                modifiers.push('optional')
              }
              if (member.value.async) {
                modifiers.push('async')
              }
              if (member.kind === 'constructor') {
                selectors.push('constructor')
              }
              if (member.kind === 'get') {
                selectors.push('get-method')
              }
              if (member.kind === 'set') {
                selectors.push('set-method')
              }
              selectors.push('method')
              break
            case 'TSAbstractAccessorProperty':
            case 'AccessorProperty':
              if (member.static) {
                modifiers.push('static')
              }
              if (member.type === 'TSAbstractAccessorProperty') {
                modifiers.push('abstract')
              }
              if (decorated) {
                modifiers.push('decorated')
              }
              if (member.override) {
                modifiers.push('override')
              }
              if (member.accessibility === 'protected') {
                modifiers.push('protected')
              } else if (member.accessibility === 'private' || isPrivateHash) {
                modifiers.push('private')
              } else {
                modifiers.push('public')
              }
              selectors.push('accessor-property')
              break
            case 'TSIndexSignature':
              if (member.static) {
                modifiers.push('static')
              }
              if (member.readonly) {
                modifiers.push('readonly')
              }
              selectors.push('index-signature')
              break
            case 'StaticBlock':
              addSafetySemicolonWhenInline = false
              selectors.push('static-block')
              dependencies = extractDependencies(member, true)
              break
          }
          let predefinedGroups =
            generatePredefinedGroups.generatePredefinedGroups({
              cache: cachedGroupsByModifiersAndSelectors,
              selectors,
              modifiers,
            })
          let group = computeGroup.computeGroup({
            customGroupMatcher: customGroup =>
              doesCustomGroupMatch.doesCustomGroupMatch({
                elementValue: memberValue,
                elementName: name,
                customGroup,
                decorators,
                modifiers,
                selectors,
              }),
            predefinedGroups,
            options,
          })
          let overloadSignatureGroupMemberIndex =
            overloadSignatureGroups.findIndex(overloadSignatures =>
              overloadSignatures.includes(member),
            )
          let overloadSignatureGroupMember =
            overloadSignatureGroups[overloadSignatureGroupMemberIndex]?.at(-1)
          let sortingNode = {
            dependencyNames: [
              getDependencyName({
                nodeNameWithoutStartingHash: name.startsWith('#')
                  ? name.slice(1)
                  : name,
                isStatic: modifiers.includes('static'),
                isPrivateHash,
              }),
            ],
            overloadSignaturesGroupId:
              overloadSignatureGroupMemberIndex === -1
                ? null
                : overloadSignatureGroupMemberIndex,
            size: overloadSignatureGroupMember
              ? rangeToDiff.rangeToDiff(
                  overloadSignatureGroupMember,
                  sourceCode,
                )
              : rangeToDiff.rangeToDiff(member, sourceCode),
            isEslintDisabled: isNodeEslintDisabled.isNodeEslintDisabled(
              member,
              eslintDisabledLines,
            ),
            addSafetySemicolonWhenInline,
            node: member,
            dependencies,
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
        newlinesBetweenValueGetter: ({
          computedNewlinesBetween,
          right,
          left,
        }) => {
          if (
            left.overloadSignaturesGroupId !== null &&
            left.overloadSignaturesGroupId === right.overloadSignaturesGroupId
          ) {
            return 0
          }
          return computedNewlinesBetween
        },
        availableMessageIds: {
          missedSpacingBetweenMembers: 'missedSpacingBetweenClassMembers',
          extraSpacingBetweenMembers: 'extraSpacingBetweenClassMembers',
          unexpectedDependencyOrder: 'unexpectedClassesDependencyOrder',
          unexpectedGroupOrder: 'unexpectedClassesGroupOrder',
          unexpectedOrder: 'unexpectedClassesOrder',
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
          customGroups: commonJsonSchemas.buildCustomGroupsArrayJsonSchema({
            singleCustomGroupJsonSchema: types.singleCustomGroupJsonSchema,
          }),
          ignoreCallbackDependenciesPatterns: commonJsonSchemas.regexJsonSchema,
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
      unexpectedClassesDependencyOrder: reportErrors.DEPENDENCY_ORDER_ERROR,
      missedSpacingBetweenClassMembers: reportErrors.MISSED_SPACING_ERROR,
      extraSpacingBetweenClassMembers: reportErrors.EXTRA_SPACING_ERROR,
      unexpectedClassesGroupOrder: reportErrors.GROUP_ORDER_ERROR,
      unexpectedClassesOrder: reportErrors.ORDER_ERROR,
    },
    docs: {
      url: 'https://perfectionist.dev/rules/sort-classes',
      description: 'Enforce sorted classes.',
      recommended: true,
    },
    type: 'suggestion',
    fixable: 'code',
  },
  defaultOptions: [defaultOptions],
  name: 'sort-classes',
})
module.exports = sortClasses

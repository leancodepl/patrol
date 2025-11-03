'use strict'
const makeSingleNodeCommentAfterFixes = require('../utils/make-single-node-comment-after-fixes.js')
const validateCustomSortConfiguration = require('../utils/validate-custom-sort-configuration.js')
const reportErrors = require('../utils/report-errors.js')
const createNodeIndexMap = require('../utils/create-node-index-map.js')
const commonJsonSchemas = require('../utils/common-json-schemas.js')
const createEslintRule = require('../utils/create-eslint-rule.js')
const rangeToDiff = require('../utils/range-to-diff.js')
const getSettings = require('../utils/get-settings.js')
const isSortable = require('../utils/is-sortable.js')
const makeFixes = require('../utils/make-fixes.js')
const sortNodes = require('../utils/sort-nodes.js')
const pairwise = require('../utils/pairwise.js')
const complete = require('../utils/complete.js')
const compare = require('../utils/compare.js')
let defaultOptions = {
  fallbackSort: { type: 'unsorted' },
  specialCharacters: 'keep',
  type: 'alphabetical',
  ignoreCase: true,
  locales: 'en-US',
  alphabet: '',
  order: 'asc',
}
const sortSwitchCase = createEslintRule.createEslintRule({
  create: context => ({
    SwitchStatement: switchNode => {
      if (!isSortable.isSortable(switchNode.cases)) {
        return
      }
      let settings = getSettings.getSettings(context.settings)
      let options = complete.complete(
        context.options.at(0),
        settings,
        defaultOptions,
      )
      validateCustomSortConfiguration.validateCustomSortConfiguration(options)
      let { sourceCode } = context
      let isDiscriminantTrue =
        switchNode.discriminant.type === 'Literal' &&
        switchNode.discriminant.value === true
      if (isDiscriminantTrue) {
        return
      }
      let caseNameSortingNodeGroups = switchNode.cases.reduce(
        (accumulator, caseNode, index) => {
          if (caseNode.test) {
            accumulator.at(-1).push({
              size: rangeToDiff.rangeToDiff(caseNode.test, sourceCode),
              name: getCaseName(sourceCode, caseNode),
              partitionId: accumulator.length,
              isEslintDisabled: false,
              node: caseNode.test,
              group: 'unknown',
            })
          }
          if (
            caseNode.consequent.length > 0 &&
            index !== switchNode.cases.length - 1
          ) {
            accumulator.push([])
          }
          return accumulator
        },
        [[]],
      )
      let hasUnsortedNodes = false
      for (let caseNodesSortingNodeGroup of caseNameSortingNodeGroups) {
        let sortedCaseNameSortingNodes = sortNodes.sortNodes({
          nodes: caseNodesSortingNodeGroup,
          ignoreEslintDisabledNodes: false,
          options,
        })
        hasUnsortedNodes ||= sortedCaseNameSortingNodes.some(
          (node, index) => node !== caseNodesSortingNodeGroup[index],
        )
        let nodeIndexMap = createNodeIndexMap.createNodeIndexMap(
          sortedCaseNameSortingNodes,
        )
        pairwise.pairwise(caseNodesSortingNodeGroup, (left, right) => {
          if (!left) {
            return
          }
          let leftIndex = nodeIndexMap.get(left)
          let rightIndex = nodeIndexMap.get(right)
          if (leftIndex < rightIndex) {
            return
          }
          reportErrors.reportErrors({
            messageIds: ['unexpectedSwitchCaseOrder'],
            sortedNodes: sortedCaseNameSortingNodes,
            nodes: caseNodesSortingNodeGroup,
            sourceCode,
            context,
            right,
            left,
          })
        })
      }
      let sortingNodes = switchNode.cases.map(caseNode => ({
        size: caseNode.test
          ? rangeToDiff.rangeToDiff(caseNode.test, sourceCode)
          : 'default'.length,
        name: getCaseName(sourceCode, caseNode),
        addSafetySemicolonWhenInline: true,
        isDefaultClause: !caseNode.test,
        isEslintDisabled: false,
        group: 'unknown',
        partitionId: 0,
        node: caseNode,
      }))
      let sortingNodeGroupsForDefaultSort = reduceCaseSortingNodes(
        sortingNodes,
        caseNode => caseNode.node.consequent.length > 0,
      )
      let sortingNodesGroupWithDefault = sortingNodeGroupsForDefaultSort.find(
        caseNodeGroup => caseNodeGroup.some(node => node.isDefaultClause),
      )
      if (
        sortingNodesGroupWithDefault &&
        !sortingNodesGroupWithDefault.at(-1).isDefaultClause
      ) {
        let defaultCase = sortingNodesGroupWithDefault.find(
          node => node.isDefaultClause,
        )
        let lastCase = sortingNodesGroupWithDefault.at(-1)
        context.report({
          fix: fixer => {
            let punctuatorAfterLastCase = sourceCode.getTokenAfter(
              lastCase.node.test,
            )
            let lastCaseRange = [
              lastCase.node.range[0],
              punctuatorAfterLastCase.range[1],
            ]
            return [
              fixer.replaceText(
                defaultCase.node,
                sourceCode.text.slice(...lastCaseRange),
              ),
              fixer.replaceTextRange(
                lastCaseRange,
                sourceCode.getText(defaultCase.node),
              ),
              ...makeSingleNodeCommentAfterFixes.makeSingleNodeCommentAfterFixes(
                {
                  sortedNode: punctuatorAfterLastCase,
                  node: defaultCase.node,
                  sourceCode,
                  fixer,
                },
              ),
              ...makeSingleNodeCommentAfterFixes.makeSingleNodeCommentAfterFixes(
                {
                  node: punctuatorAfterLastCase,
                  sortedNode: defaultCase.node,
                  sourceCode,
                  fixer,
                },
              ),
            ]
          },
          data: {
            [reportErrors.LEFT]: defaultCase.name,
            [reportErrors.RIGHT]: lastCase.name,
          },
          messageId: 'unexpectedSwitchCaseOrder',
          node: defaultCase.node,
        })
      }
      let sortingNodeGroupsForBlockSort = reduceCaseSortingNodes(
        sortingNodes,
        caseNode => caseHasBreakOrReturn(caseNode.node),
      )
      let lastNodeGroup = sortingNodeGroupsForBlockSort.at(-1)
      let lastBlockCaseShouldStayInPlace = !caseHasBreakOrReturn(
        lastNodeGroup.at(-1).node,
      )
      let sortedSortingNodeGroupsForBlockSort = [
        ...sortingNodeGroupsForBlockSort,
      ]
        .sort((a, b) => {
          if (lastBlockCaseShouldStayInPlace) {
            if (a === lastNodeGroup) {
              return 1
            }
            if (b === lastNodeGroup) {
              return -1
            }
          }
          if (a.some(node => node.isDefaultClause)) {
            return 1
          }
          if (b.some(node => node.isDefaultClause)) {
            return -1
          }
          return compare.compare({
            a: a.at(0),
            b: b.at(0),
            options,
          })
        })
        .flat()
      let sortingNodeGroupsForBlockSortFlat =
        sortingNodeGroupsForBlockSort.flat()
      pairwise.pairwise(sortingNodeGroupsForBlockSortFlat, (left, right) => {
        if (!left) {
          return
        }
        let indexOfLeft = sortedSortingNodeGroupsForBlockSort.indexOf(left)
        let indexOfRight = sortedSortingNodeGroupsForBlockSort.indexOf(right)
        if (indexOfLeft < indexOfRight) {
          return
        }
        context.report({
          fix: fixer =>
            hasUnsortedNodes
              ? []
              : makeFixes.makeFixes({
                  sortedNodes: sortedSortingNodeGroupsForBlockSort,
                  nodes: sortingNodeGroupsForBlockSortFlat,
                  hasCommentAboveMissing: false,
                  sourceCode,
                  fixer,
                }),
          data: {
            [reportErrors.RIGHT]: right.name,
            [reportErrors.LEFT]: left.name,
          },
          messageId: 'unexpectedSwitchCaseOrder',
          node: right.node,
        })
      })
    },
  }),
  meta: {
    schema: [
      {
        properties: {
          ...commonJsonSchemas.commonJsonSchemas,
        },
        additionalProperties: false,
        type: 'object',
      },
    ],
    docs: {
      url: 'https://perfectionist.dev/rules/sort-switch-case',
      description: 'Enforce sorted switch cases.',
      recommended: true,
    },
    messages: {
      unexpectedSwitchCaseOrder: reportErrors.ORDER_ERROR,
    },
    type: 'suggestion',
    fixable: 'code',
  },
  defaultOptions: [defaultOptions],
  name: 'sort-switch-case',
})
function reduceCaseSortingNodes(caseNodes, endsBlock) {
  return caseNodes.reduce(
    (accumulator, caseNode, index) => {
      accumulator.at(-1).push(caseNode)
      if (endsBlock(caseNode) && index !== caseNodes.length - 1) {
        accumulator.push([])
      }
      return accumulator
    },
    [[]],
  )
}
function getCaseName(sourceCode, caseNode) {
  if (caseNode.test?.type === 'Literal') {
    return `${caseNode.test.value}`
  } else if (caseNode.test === null) {
    return 'default'
  }
  return sourceCode.getText(caseNode.test)
}
function caseHasBreakOrReturn(caseNode) {
  let statements =
    caseNode.consequent[0]?.type === 'BlockStatement'
      ? caseNode.consequent[0].body
      : caseNode.consequent
  return statements.some(statementIsBreakOrReturn)
}
function statementIsBreakOrReturn(statement) {
  return (
    statement.type === 'BreakStatement' || statement.type === 'ReturnStatement'
  )
}
module.exports = sortSwitchCase

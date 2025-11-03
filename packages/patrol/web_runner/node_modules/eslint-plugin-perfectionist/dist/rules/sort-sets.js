'use strict'
const reportErrors = require('../utils/report-errors.js')
const sortArrayIncludes = require('./sort-array-includes.js')
const createEslintRule = require('../utils/create-eslint-rule.js')
const sortSets = createEslintRule.createEslintRule({
  create: context => ({
    NewExpression: node => {
      if (
        node.callee.type === 'Identifier' &&
        node.callee.name === 'Set' &&
        node.arguments.length > 0 &&
        (node.arguments[0]?.type === 'ArrayExpression' ||
          (node.arguments[0]?.type === 'NewExpression' &&
            'name' in node.arguments[0].callee &&
            node.arguments[0].callee.name === 'Array'))
      ) {
        let elements =
          node.arguments[0].type === 'ArrayExpression'
            ? node.arguments[0].elements
            : node.arguments[0].arguments
        sortArrayIncludes.sortArray({
          availableMessageIds: {
            missedSpacingBetweenMembers: 'missedSpacingBetweenSetsMembers',
            extraSpacingBetweenMembers: 'extraSpacingBetweenSetsMembers',
            unexpectedGroupOrder: 'unexpectedSetsGroupOrder',
            unexpectedOrder: 'unexpectedSetsOrder',
          },
          elements,
          context,
        })
      }
    },
  }),
  meta: {
    messages: {
      missedSpacingBetweenSetsMembers: reportErrors.MISSED_SPACING_ERROR,
      extraSpacingBetweenSetsMembers: reportErrors.EXTRA_SPACING_ERROR,
      unexpectedSetsGroupOrder: reportErrors.GROUP_ORDER_ERROR,
      unexpectedSetsOrder: reportErrors.ORDER_ERROR,
    },
    docs: {
      url: 'https://perfectionist.dev/rules/sort-sets',
      description: 'Enforce sorted sets.',
      recommended: true,
    },
    schema: sortArrayIncludes.jsonSchema,
    type: 'suggestion',
    fixable: 'code',
  },
  defaultOptions: [sortArrayIncludes.defaultOptions],
  name: 'sort-sets',
})
module.exports = sortSets

'use strict'
const reportErrors = require('../utils/report-errors.js')
const sortUnionTypes = require('./sort-union-types.js')
const createEslintRule = require('../utils/create-eslint-rule.js')
let defaultOptions = {
  fallbackSort: { type: 'unsorted' },
  specialCharacters: 'keep',
  newlinesBetween: 'ignore',
  partitionByComment: false,
  partitionByNewLine: false,
  type: 'alphabetical',
  ignoreCase: true,
  locales: 'en-US',
  customGroups: [],
  alphabet: '',
  order: 'asc',
  groups: [],
}
const sortIntersectionTypes = createEslintRule.createEslintRule({
  meta: {
    messages: {
      missedSpacingBetweenIntersectionTypes: reportErrors.MISSED_SPACING_ERROR,
      extraSpacingBetweenIntersectionTypes: reportErrors.EXTRA_SPACING_ERROR,
      unexpectedIntersectionTypesGroupOrder: reportErrors.GROUP_ORDER_ERROR,
      unexpectedIntersectionTypesOrder: reportErrors.ORDER_ERROR,
    },
    docs: {
      url: 'https://perfectionist.dev/rules/sort-intersection-types',
      description: 'Enforce sorted intersection types.',
      recommended: true,
    },
    schema: sortUnionTypes.jsonSchema,
    type: 'suggestion',
    fixable: 'code',
  },
  create: context => ({
    TSIntersectionType: node => {
      sortUnionTypes.sortUnionOrIntersectionTypes({
        availableMessageIds: {
          missedSpacingBetweenMembers: 'missedSpacingBetweenIntersectionTypes',
          extraSpacingBetweenMembers: 'extraSpacingBetweenIntersectionTypes',
          unexpectedGroupOrder: 'unexpectedIntersectionTypesGroupOrder',
          unexpectedOrder: 'unexpectedIntersectionTypesOrder',
        },
        tokenValueToIgnoreBefore: '&',
        context,
        node,
      })
    },
  }),
  defaultOptions: [defaultOptions],
  name: 'sort-intersection-types',
})
module.exports = sortIntersectionTypes

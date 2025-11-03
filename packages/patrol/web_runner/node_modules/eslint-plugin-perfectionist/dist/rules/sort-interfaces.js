'use strict'
const reportErrors = require('../utils/report-errors.js')
const sortObjectTypes = require('./sort-object-types.js')
const createEslintRule = require('../utils/create-eslint-rule.js')
let defaultOptions = {
  fallbackSort: { type: 'unsorted' },
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
const sortInterfaces = createEslintRule.createEslintRule({
  create: context => ({
    TSInterfaceDeclaration: node =>
      sortObjectTypes.sortObjectTypeElements({
        availableMessageIds: {
          missedSpacingBetweenMembers: 'missedSpacingBetweenInterfaceMembers',
          extraSpacingBetweenMembers: 'extraSpacingBetweenInterfaceMembers',
          unexpectedGroupOrder: 'unexpectedInterfacePropertiesGroupOrder',
          unexpectedOrder: 'unexpectedInterfacePropertiesOrder',
        },
        parentNodeName: node.id.name,
        elements: node.body.body,
        context,
      }),
  }),
  meta: {
    messages: {
      unexpectedInterfacePropertiesGroupOrder: reportErrors.GROUP_ORDER_ERROR,
      missedSpacingBetweenInterfaceMembers: reportErrors.MISSED_SPACING_ERROR,
      extraSpacingBetweenInterfaceMembers: reportErrors.EXTRA_SPACING_ERROR,
      unexpectedInterfacePropertiesOrder: reportErrors.ORDER_ERROR,
    },
    docs: {
      url: 'https://perfectionist.dev/rules/sort-interfaces',
      description: 'Enforce sorted interface properties.',
      recommended: true,
    },
    schema: sortObjectTypes.jsonSchema,
    type: 'suggestion',
    fixable: 'code',
  },
  defaultOptions: [defaultOptions],
  name: 'sort-interfaces',
})
module.exports = sortInterfaces

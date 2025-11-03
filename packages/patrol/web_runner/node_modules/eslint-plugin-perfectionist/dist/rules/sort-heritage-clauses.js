'use strict'
const commonJsonSchemas = require('../utils/common-json-schemas.js')
const validateGeneratedGroupsConfiguration = require('../utils/validate-generated-groups-configuration.js')
const validateCustomSortConfiguration = require('../utils/validate-custom-sort-configuration.js')
const getEslintDisabledLines = require('../utils/get-eslint-disabled-lines.js')
const isNodeEslintDisabled = require('../utils/is-node-eslint-disabled.js')
const reportErrors = require('../utils/report-errors.js')
const sortNodesByGroups = require('../utils/sort-nodes-by-groups.js')
const createEslintRule = require('../utils/create-eslint-rule.js')
const reportAllErrors = require('../utils/report-all-errors.js')
const computeGroup = require('../utils/compute-group.js')
const rangeToDiff = require('../utils/range-to-diff.js')
const getSettings = require('../utils/get-settings.js')
const isSortable = require('../utils/is-sortable.js')
const complete = require('../utils/complete.js')
let defaultOptions = {
  fallbackSort: { type: 'unsorted' },
  specialCharacters: 'keep',
  type: 'alphabetical',
  ignoreCase: true,
  customGroups: {},
  locales: 'en-US',
  alphabet: '',
  order: 'asc',
  groups: [],
}
const sortHeritageClauses = createEslintRule.createEslintRule({
  meta: {
    schema: [
      {
        properties: {
          ...commonJsonSchemas.commonJsonSchemas,
          customGroups: commonJsonSchemas.deprecatedCustomGroupsJsonSchema,
          groups: commonJsonSchemas.groupsJsonSchema,
        },
        additionalProperties: false,
        type: 'object',
      },
    ],
    docs: {
      url: 'https://perfectionist.dev/rules/sort-heritage-clauses',
      description: 'Enforce sorted heritage clauses.',
      recommended: true,
    },
    messages: {
      unexpectedHeritageClausesGroupOrder: reportErrors.GROUP_ORDER_ERROR,
      unexpectedHeritageClausesOrder: reportErrors.ORDER_ERROR,
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
      selectors: [],
      modifiers: [],
      options,
    })
    return {
      TSInterfaceDeclaration: declaration =>
        sortHeritageClauses$1(context, options, declaration.extends),
      ClassDeclaration: declaration =>
        sortHeritageClauses$1(context, options, declaration.implements),
    }
  },
  defaultOptions: [defaultOptions],
  name: 'sort-heritage-clauses',
})
function sortHeritageClauses$1(context, options, heritageClauses) {
  if (!isSortable.isSortable(heritageClauses)) {
    return
  }
  let { sourceCode, id } = context
  let eslintDisabledLines = getEslintDisabledLines.getEslintDisabledLines({
    ruleName: id,
    sourceCode,
  })
  let nodes = heritageClauses.map(heritageClause => {
    let name = getHeritageClauseExpressionName(heritageClause.expression)
    let group = computeGroup.computeGroup({
      predefinedGroups: [],
      options,
      name,
    })
    return {
      isEslintDisabled: isNodeEslintDisabled.isNodeEslintDisabled(
        heritageClause,
        eslintDisabledLines,
      ),
      size: rangeToDiff.rangeToDiff(heritageClause, sourceCode),
      node: heritageClause,
      partitionId: 0,
      group,
      name,
    }
  })
  function sortNodesExcludingEslintDisabled(ignoreEslintDisabledNodes) {
    return sortNodesByGroups.sortNodesByGroups({
      getOptionsByGroupIndex: () => ({ options }),
      ignoreEslintDisabledNodes,
      groups: options.groups,
      nodes,
    })
  }
  reportAllErrors.reportAllErrors({
    availableMessageIds: {
      unexpectedGroupOrder: 'unexpectedHeritageClausesGroupOrder',
      unexpectedOrder: 'unexpectedHeritageClausesOrder',
    },
    sortNodesExcludingEslintDisabled,
    sourceCode,
    options,
    context,
    nodes,
  })
}
function getHeritageClauseExpressionName(expression) {
  if (expression.type === 'Identifier') {
    return expression.name
  }
  if ('property' in expression) {
    return getHeritageClauseExpressionName(expression.property)
  }
  throw new Error(
    'Unexpected heritage clause expression. Please report this issue here: https://github.com/azat-io/eslint-plugin-perfectionist/issues',
  )
}
module.exports = sortHeritageClauses

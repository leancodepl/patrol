'use strict'
const commonJsonSchemas = require('../utils/common-json-schemas.js')
const validateGeneratedGroupsConfiguration = require('../utils/validate-generated-groups-configuration.js')
const validateCustomSortConfiguration = require('../utils/validate-custom-sort-configuration.js')
const getEslintDisabledLines = require('../utils/get-eslint-disabled-lines.js')
const isNodeEslintDisabled = require('../utils/is-node-eslint-disabled.js')
const reportErrors = require('../utils/report-errors.js')
const sortNodesByGroups = require('../utils/sort-nodes-by-groups.js')
const getNodeDecorators = require('../utils/get-node-decorators.js')
const getDecoratorName = require('../utils/get-decorator-name.js')
const createEslintRule = require('../utils/create-eslint-rule.js')
const reportAllErrors = require('../utils/report-all-errors.js')
const shouldPartition = require('../utils/should-partition.js')
const computeGroup = require('../utils/compute-group.js')
const rangeToDiff = require('../utils/range-to-diff.js')
const getSettings = require('../utils/get-settings.js')
const isSortable = require('../utils/is-sortable.js')
const complete = require('../utils/complete.js')
let defaultOptions = {
  fallbackSort: { type: 'unsorted' },
  specialCharacters: 'keep',
  partitionByComment: false,
  sortOnProperties: true,
  sortOnParameters: true,
  sortOnAccessors: true,
  type: 'alphabetical',
  sortOnClasses: true,
  sortOnMethods: true,
  ignoreCase: true,
  customGroups: {},
  locales: 'en-US',
  alphabet: '',
  order: 'asc',
  groups: [],
}
const sortDecorators = createEslintRule.createEslintRule({
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
      Decorator: decorator => {
        if (!options.sortOnParameters) {
          return
        }
        if (
          'decorators' in decorator.parent &&
          decorator.parent.type === 'Identifier' &&
          decorator.parent.parent.type === 'FunctionExpression'
        ) {
          let { decorators } = decorator.parent
          if (decorator !== decorators[0]) {
            return
          }
          sortDecorators$1(context, options, decorators)
        }
      },
      PropertyDefinition: propertyDefinition =>
        options.sortOnProperties
          ? sortDecorators$1(
              context,
              options,
              getNodeDecorators.getNodeDecorators(propertyDefinition),
            )
          : null,
      AccessorProperty: accessorDefinition =>
        options.sortOnAccessors
          ? sortDecorators$1(
              context,
              options,
              getNodeDecorators.getNodeDecorators(accessorDefinition),
            )
          : null,
      MethodDefinition: methodDefinition =>
        options.sortOnMethods
          ? sortDecorators$1(
              context,
              options,
              getNodeDecorators.getNodeDecorators(methodDefinition),
            )
          : null,
      ClassDeclaration: declaration =>
        options.sortOnClasses
          ? sortDecorators$1(
              context,
              options,
              getNodeDecorators.getNodeDecorators(declaration),
            )
          : null,
    }
  },
  meta: {
    schema: [
      {
        properties: {
          ...commonJsonSchemas.commonJsonSchemas,
          sortOnParameters: {
            description:
              'Controls whether sorting should be enabled for method parameter decorators.',
            type: 'boolean',
          },
          sortOnProperties: {
            description:
              'Controls whether sorting should be enabled for class property decorators.',
            type: 'boolean',
          },
          sortOnAccessors: {
            description:
              'Controls whether sorting should be enabled for class accessor decorators.',
            type: 'boolean',
          },
          sortOnMethods: {
            description:
              'Controls whether sorting should be enabled for class method decorators.',
            type: 'boolean',
          },
          sortOnClasses: {
            description:
              'Controls whether sorting should be enabled for class decorators.',
            type: 'boolean',
          },
          partitionByComment: commonJsonSchemas.partitionByCommentJsonSchema,
          customGroups: commonJsonSchemas.deprecatedCustomGroupsJsonSchema,
          groups: commonJsonSchemas.groupsJsonSchema,
        },
        additionalProperties: false,
        type: 'object',
      },
    ],
    docs: {
      url: 'https://perfectionist.dev/rules/sort-decorators',
      description: 'Enforce sorted decorators.',
      recommended: true,
    },
    messages: {
      unexpectedDecoratorsGroupOrder: reportErrors.GROUP_ORDER_ERROR,
      unexpectedDecoratorsOrder: reportErrors.ORDER_ERROR,
    },
    type: 'suggestion',
    fixable: 'code',
  },
  defaultOptions: [defaultOptions],
  name: 'sort-decorators',
})
function sortDecorators$1(context, options, decorators) {
  if (!isSortable.isSortable(decorators)) {
    return
  }
  let { sourceCode, id } = context
  let eslintDisabledLines = getEslintDisabledLines.getEslintDisabledLines({
    ruleName: id,
    sourceCode,
  })
  let formattedMembers = decorators.reduce(
    (accumulator, decorator) => {
      let name = getDecoratorName.getDecoratorName({
        sourceCode,
        decorator,
      })
      let group = computeGroup.computeGroup({
        predefinedGroups: [],
        options,
        name,
      })
      let sortingNode = {
        isEslintDisabled: isNodeEslintDisabled.isNodeEslintDisabled(
          decorator,
          eslintDisabledLines,
        ),
        size: rangeToDiff.rangeToDiff(decorator, sourceCode),
        node: decorator,
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
    return formattedMembers.flatMap(nodes2 =>
      sortNodesByGroups.sortNodesByGroups({
        getOptionsByGroupIndex: () => ({ options }),
        ignoreEslintDisabledNodes,
        groups: options.groups,
        nodes: nodes2,
      }),
    )
  }
  let nodes = formattedMembers.flat()
  reportAllErrors.reportAllErrors({
    availableMessageIds: {
      unexpectedGroupOrder: 'unexpectedDecoratorsGroupOrder',
      unexpectedOrder: 'unexpectedDecoratorsOrder',
    },
    ignoreFirstNodeHighestBlockComment: true,
    sortNodesExcludingEslintDisabled,
    sourceCode,
    options,
    context,
    nodes,
  })
}
module.exports = sortDecorators

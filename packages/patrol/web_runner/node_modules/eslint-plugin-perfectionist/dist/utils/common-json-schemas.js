'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
let typeJsonSchema = {
  enum: ['alphabetical', 'natural', 'line-length', 'custom', 'unsorted'],
  description: 'Specifies the sorting method.',
  type: 'string',
}
let orderJsonSchema = {
  description:
    'Specifies whether to sort items in ascending or descending order.',
  enum: ['asc', 'desc'],
  type: 'string',
}
let alphabetJsonSchema = {
  description:
    "Used only when the `type` option is set to `'custom'`. Specifies the custom alphabet for sorting.",
  type: 'string',
}
let localesJsonSchema = {
  oneOf: [
    {
      type: 'string',
    },
    {
      items: {
        type: 'string',
      },
      type: 'array',
    },
  ],
  description: 'Specifies the sorting locales.',
}
let ignoreCaseJsonSchema = {
  description: 'Controls whether sorting should be case-sensitive or not.',
  type: 'boolean',
}
let specialCharactersJsonSchema = {
  description:
    'Specifies whether to trim, remove, or keep special characters before sorting.',
  enum: ['remove', 'trim', 'keep'],
  type: 'string',
}
function buildCommonJsonSchemas({ additionalFallbackSortProperties } = {}) {
  return {
    fallbackSort: buildFallbackSortJsonSchema({
      additionalProperties: additionalFallbackSortProperties,
    }),
    specialCharacters: specialCharactersJsonSchema,
    ignoreCase: ignoreCaseJsonSchema,
    alphabet: alphabetJsonSchema,
    locales: localesJsonSchema,
    order: orderJsonSchema,
    type: typeJsonSchema,
  }
}
function buildFallbackSortJsonSchema({ additionalProperties } = {}) {
  return {
    properties: {
      order: orderJsonSchema,
      type: typeJsonSchema,
      ...additionalProperties,
    },
    description: 'Fallback sort order.',
    additionalProperties: false,
    minProperties: 1,
    type: 'object',
  }
}
let commonJsonSchemas = buildCommonJsonSchemas()
let newlinesBetweenJsonSchema = {
  oneOf: [
    {
      description: 'Specifies how to handle newlines between groups.',
      enum: ['ignore', 'always', 'never'],
      type: 'string',
    },
    {
      type: 'number',
      minimum: 0,
    },
  ],
}
let commentAboveJsonSchema = {
  description: 'Specifies a comment to enforce above the group.',
  type: 'string',
}
let groupsJsonSchema = {
  items: {
    oneOf: [
      {
        type: 'string',
      },
      {
        items: {
          type: 'string',
        },
        type: 'array',
      },
      {
        properties: {
          newlinesBetween: newlinesBetweenJsonSchema,
          commentAbove: commentAboveJsonSchema,
        },
        additionalProperties: false,
        minProperties: 1,
        type: 'object',
      },
    ],
  },
  description: 'Specifies a list of groups for sorting.',
  type: 'array',
}
let deprecatedCustomGroupsJsonSchema = {
  additionalProperties: {
    oneOf: [
      {
        type: 'string',
      },
      {
        items: {
          type: 'string',
        },
        type: 'array',
      },
    ],
  },
  description: 'Specifies custom groups.',
  type: 'object',
}
let singleRegexJsonSchema = {
  oneOf: [
    {
      properties: {
        pattern: {
          description: 'Regular expression pattern.',
          type: 'string',
        },
        flags: {
          description: 'Regular expression flags.',
          type: 'string',
        },
      },
      additionalProperties: false,
      required: ['pattern'],
      // https://github.com/azat-io/eslint-plugin-perfectionist/pull/490#issuecomment-2720969705
      // Uncomment the code below in the next major version (v5)
      // To uncomment: required: ['pattern'],
      type: 'object',
    },
    {
      type: 'string',
    },
  ],
  description: 'Regular expression.',
}
let regexJsonSchema = {
  oneOf: [
    {
      items: singleRegexJsonSchema,
      type: 'array',
    },
    singleRegexJsonSchema,
  ],
  description: 'Regular expression.',
}
let allowedPartitionByCommentJsonSchemas = [
  {
    type: 'boolean',
  },
  regexJsonSchema,
]
let partitionByCommentJsonSchema = {
  oneOf: [
    ...allowedPartitionByCommentJsonSchemas,
    {
      properties: {
        block: {
          description: 'Enables specific block comments to separate the nodes.',
          oneOf: allowedPartitionByCommentJsonSchemas,
        },
        line: {
          description: 'Enables specific line comments to separate the nodes.',
          oneOf: allowedPartitionByCommentJsonSchemas,
        },
      },
      additionalProperties: false,
      minProperties: 1,
      type: 'object',
    },
  ],
  description:
    'Enables the use of comments to separate the nodes into logical groups.',
}
let partitionByNewLineJsonSchema = {
  description:
    'Enables the use of newlines to separate the nodes into logical groups.',
  type: 'boolean',
}
function buildCustomGroupsArrayJsonSchema({
  additionalFallbackSortProperties,
  singleCustomGroupJsonSchema,
}) {
  return {
    items: {
      oneOf: [
        {
          properties: {
            ...buildCommonCustomGroupJsonSchemas({
              additionalFallbackSortProperties,
            }),
            anyOf: {
              items: {
                properties: {
                  ...singleCustomGroupJsonSchema,
                },
                description: 'Custom group.',
                additionalProperties: false,
                type: 'object',
              },
              type: 'array',
            },
          },
          description: 'Custom group block.',
          additionalProperties: false,
          required: ['groupName'],
          type: 'object',
        },
        {
          properties: {
            ...buildCommonCustomGroupJsonSchemas({
              additionalFallbackSortProperties,
            }),
            ...singleCustomGroupJsonSchema,
          },
          description: 'Custom group.',
          additionalProperties: false,
          required: ['groupName'],
          type: 'object',
        },
      ],
    },
    description: 'Defines custom groups to match specific members.',
    type: 'array',
  }
}
function buildUseConfigurationIfJsonSchema({ additionalProperties } = {}) {
  return {
    description:
      'Specifies filters to match a particular options configuration for a given element to sort.',
    properties: {
      allNamesMatchPattern: regexJsonSchema,
      ...additionalProperties,
    },
    additionalProperties: false,
    type: 'object',
  }
}
function buildCustomGroupModifiersJsonSchema(modifiers) {
  return {
    items: {
      enum: modifiers,
      type: 'string',
    },
    description: 'Modifier filters.',
    type: 'array',
  }
}
function buildCustomGroupSelectorJsonSchema(selectors) {
  return {
    description: 'Selector filter.',
    enum: selectors,
    type: 'string',
  }
}
function buildCommonCustomGroupJsonSchemas({
  additionalFallbackSortProperties,
} = {}) {
  return {
    newlinesInside: {
      oneOf: [
        {
          description:
            'Specifies how to handle newlines between members of the custom group.',
          enum: ['always', 'never'],
          type: 'string',
        },
        {
          type: 'number',
          minimum: 0,
        },
      ],
    },
    fallbackSort: buildFallbackSortJsonSchema({
      additionalProperties: additionalFallbackSortProperties,
    }),
    groupName: {
      description: 'Custom group name.',
      type: 'string',
    },
    order: orderJsonSchema,
    type: typeJsonSchema,
  }
}
exports.buildCommonJsonSchemas = buildCommonJsonSchemas
exports.buildCustomGroupModifiersJsonSchema =
  buildCustomGroupModifiersJsonSchema
exports.buildCustomGroupSelectorJsonSchema = buildCustomGroupSelectorJsonSchema
exports.buildCustomGroupsArrayJsonSchema = buildCustomGroupsArrayJsonSchema
exports.buildUseConfigurationIfJsonSchema = buildUseConfigurationIfJsonSchema
exports.commonJsonSchemas = commonJsonSchemas
exports.deprecatedCustomGroupsJsonSchema = deprecatedCustomGroupsJsonSchema
exports.groupsJsonSchema = groupsJsonSchema
exports.newlinesBetweenJsonSchema = newlinesBetweenJsonSchema
exports.partitionByCommentJsonSchema = partitionByCommentJsonSchema
exports.partitionByNewLineJsonSchema = partitionByNewLineJsonSchema
exports.regexJsonSchema = regexJsonSchema

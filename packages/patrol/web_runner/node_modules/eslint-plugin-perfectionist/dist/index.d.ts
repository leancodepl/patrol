import { Linter } from 'eslint'
import { Rule } from 'eslint'

declare const _default: PluginConfig

declare interface PluginConfig {
  rules: {
    'sort-variable-declarations': Rule.RuleModule
    'sort-intersection-types': Rule.RuleModule
    'sort-heritage-clauses': Rule.RuleModule
    'sort-array-includes': Rule.RuleModule
    'sort-named-imports': Rule.RuleModule
    'sort-named-exports': Rule.RuleModule
    'sort-object-types': Rule.RuleModule
    'sort-union-types': Rule.RuleModule
    'sort-switch-case': Rule.RuleModule
    'sort-interfaces': Rule.RuleModule
    'sort-decorators': Rule.RuleModule
    'sort-jsx-props': Rule.RuleModule
    'sort-modules': Rule.RuleModule
    'sort-classes': Rule.RuleModule
    'sort-imports': Rule.RuleModule
    'sort-exports': Rule.RuleModule
    'sort-objects': Rule.RuleModule
    'sort-enums': Rule.RuleModule
    'sort-sets': Rule.RuleModule
    'sort-maps': Rule.RuleModule
  }
  configs: {
    'recommended-alphabetical-legacy': Linter.LegacyConfig
    'recommended-line-length-legacy': Linter.LegacyConfig
    'recommended-natural-legacy': Linter.LegacyConfig
    'recommended-custom-legacy': Linter.LegacyConfig
    'recommended-alphabetical': Linter.Config
    'recommended-line-length': Linter.Config
    'recommended-natural': Linter.Config
    'recommended-custom': Linter.Config
  }
  meta: {
    version: string
    name: string
  }
}

export {}
export = _default

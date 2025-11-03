import { ESLintUtils } from '@typescript-eslint/utils';
import { DepConstraint } from '../utils/runtime-lint-utils';
export type Options = [
    {
        allow: string[];
        buildTargets: string[];
        depConstraints: DepConstraint[];
        enforceBuildableLibDependency: boolean;
        allowCircularSelfDependency: boolean;
        ignoredCircularDependencies: Array<[string, string]>;
        checkDynamicDependenciesExceptions: string[];
        banTransitiveDependencies: boolean;
        checkNestedExternalImports: boolean;
    }
];
export type MessageIds = 'noRelativeOrAbsoluteImportsAcrossLibraries' | 'noRelativeOrAbsoluteExternals' | 'noSelfCircularDependencies' | 'noCircularDependencies' | 'noImportsOfApps' | 'noImportsOfE2e' | 'noImportOfNonBuildableLibraries' | 'noImportsOfLazyLoadedLibraries' | 'projectWithoutTagsCannotHaveDependencies' | 'bannedExternalImportsViolation' | 'nestedBannedExternalImportsViolation' | 'noTransitiveDependencies' | 'onlyTagsConstraintViolation' | 'emptyOnlyTagsConstraintViolation' | 'notTagsConstraintViolation';
export declare const RULE_NAME = "enforce-module-boundaries";
declare const _default: ESLintUtils.RuleModule<MessageIds, Options, unknown, ESLintUtils.RuleListener>;
export default _default;
//# sourceMappingURL=enforce-module-boundaries.d.ts.map
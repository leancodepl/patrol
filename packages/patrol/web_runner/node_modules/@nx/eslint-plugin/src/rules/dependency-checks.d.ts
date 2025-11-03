import { ESLintUtils } from '@typescript-eslint/utils';
export type Options = [
    {
        buildTargets?: string[];
        checkMissingDependencies?: boolean;
        checkObsoleteDependencies?: boolean;
        checkVersionMismatches?: boolean;
        ignoredDependencies?: string[];
        ignoredFiles?: string[];
        includeTransitiveDependencies?: boolean;
        useLocalPathsForWorkspaceDependencies?: boolean;
        runtimeHelpers?: string[];
    }
];
export type MessageIds = 'missingDependency' | 'obsoleteDependency' | 'versionMismatch' | 'missingDependencySection' | 'invalidCatalogReference';
export declare const RULE_NAME = "dependency-checks";
declare const _default: ESLintUtils.RuleModule<MessageIds, Options, unknown, ESLintUtils.RuleListener>;
export default _default;
//# sourceMappingURL=dependency-checks.d.ts.map
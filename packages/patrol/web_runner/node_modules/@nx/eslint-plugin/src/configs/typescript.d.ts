/**
 * This configuration is intended to be applied to ALL .ts and .tsx files
 * within an Nx workspace.
 *
 * It should therefore NOT contain any rules or plugins which are specific
 * to one ecosystem, such as React, Angular, Node etc.
 */
declare const _default: {
    parser: string;
    parserOptions: {
        ecmaVersion: number;
        sourceType: string;
        tsconfigRootDir: string;
    };
    plugins: string[];
    extends: string[];
    rules: {
        '@typescript-eslint/explicit-member-accessibility': string;
        '@typescript-eslint/explicit-module-boundary-types': string;
        '@typescript-eslint/explicit-function-return-type': string;
        '@typescript-eslint/no-parameter-properties': string;
        /**
         * From https://typescript-eslint.io/blog/announcing-typescript-eslint-v6/#updated-configuration-rules
         *
         * The following rules were added to preserve the linting rules that were
         * previously defined v5 of `@typescript-eslint`. v6 of `@typescript-eslint`
         * changed how configurations are defined.
         *
         * TODO(eslint): re-evalute these deviations from @typescript-eslint/recommended in v20 of Nx
         */
        '@typescript-eslint/no-non-null-assertion': string;
        '@typescript-eslint/adjacent-overload-signatures': string;
        '@typescript-eslint/prefer-namespace-keyword': string;
        'no-empty-function': string;
        '@typescript-eslint/no-empty-function': string;
        '@typescript-eslint/no-inferrable-types': string;
        '@typescript-eslint/no-unused-vars': string;
        '@typescript-eslint/no-empty-interface': string;
        '@typescript-eslint/no-explicit-any': string;
        /**
         * During the migration to use ESLint v9 and typescript-eslint v8 for new workspaces,
         * this rule would have created a lot of noise, so we are disabling it by default for now.
         *
         * TODO(eslint): we should make this part of what we re-evaluate in v20
         */
        '@typescript-eslint/no-require-imports': string;
    };
};
export default _default;
//# sourceMappingURL=typescript.d.ts.map
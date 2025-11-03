"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const eslint_plugin_jsx_a11y_1 = tslib_1.__importDefault(require("eslint-plugin-jsx-a11y"));
const eslint_plugin_react_1 = tslib_1.__importDefault(require("eslint-plugin-react"));
const eslint_plugin_react_hooks_1 = tslib_1.__importDefault(require("eslint-plugin-react-hooks"));
const typescript_eslint_1 = tslib_1.__importDefault(require("typescript-eslint"));
/**
 * This configuration is intended to be applied to ONLY files which contain JSX/TSX
 * code.
 *
 * It should therefore NOT contain any rules or plugins which are generic
 * to all file types within variants of React projects.
 *
 * This configuration is intended to be combined with other configs from this
 * package.
 */
const config = typescript_eslint_1.default.config({
    files: [
        '**/*.ts',
        '**/*.cts',
        '**/*.mts',
        '**/*.tsx',
        '**/*.js',
        '**/*.cjs',
        '**/*.mjs',
        '**/*.jsx',
    ],
    plugins: {
        'react-hooks': eslint_plugin_react_hooks_1.default,
    },
    rules: eslint_plugin_react_hooks_1.default.configs.recommended.rules,
}, {
    files: [
        '**/*.ts',
        '**/*.cts',
        '**/*.mts',
        '**/*.tsx',
        '**/*.js',
        '**/*.cjs',
        '**/*.mjs',
        '**/*.jsx',
    ],
    settings: { react: { version: 'detect' } },
    plugins: {
        'jsx-a11y': eslint_plugin_jsx_a11y_1.default,
        react: eslint_plugin_react_1.default,
    },
    rules: {
        /**
         * React-specific rule configurations
         * https://github.com/yannickcr/eslint-plugin-react
         */
        'react/forbid-foreign-prop-types': ['warn', { allowInPropTypes: true }],
        'react/jsx-no-comment-textnodes': 'warn',
        'react/jsx-no-duplicate-props': 'warn',
        'react/jsx-no-target-blank': 'warn',
        'react/jsx-no-undef': 'error',
        'react/jsx-pascal-case': ['warn', { allowAllCaps: true, ignore: [] }],
        'react/jsx-uses-vars': 'warn',
        'react/no-danger-with-children': 'warn',
        'react/no-direct-mutation-state': 'warn',
        'react/no-is-mounted': 'warn',
        'react/no-typos': 'error',
        'react/jsx-uses-react': 'off',
        'react/react-in-jsx-scope': 'off',
        'react/require-render-return': 'error',
        'react/style-prop-object': 'warn',
        'react/jsx-no-useless-fragment': 'warn',
        /**
         * JSX Accessibility rule configurations
         * https://github.com/evcohen/eslint-plugin-jsx-a11y
         */
        'jsx-a11y/accessible-emoji': 'warn',
        'jsx-a11y/alt-text': 'warn',
        'jsx-a11y/anchor-has-content': 'warn',
        'jsx-a11y/anchor-is-valid': [
            'warn',
            { aspects: ['noHref', 'invalidHref'] },
        ],
        'jsx-a11y/aria-activedescendant-has-tabindex': 'warn',
        'jsx-a11y/aria-props': 'warn',
        'jsx-a11y/aria-proptypes': 'warn',
        'jsx-a11y/aria-role': 'warn',
        'jsx-a11y/aria-unsupported-elements': 'warn',
        'jsx-a11y/heading-has-content': 'warn',
        'jsx-a11y/iframe-has-title': 'warn',
        'jsx-a11y/img-redundant-alt': 'warn',
        'jsx-a11y/no-access-key': 'warn',
        'jsx-a11y/no-distracting-elements': 'warn',
        'jsx-a11y/no-redundant-roles': 'warn',
        'jsx-a11y/role-has-required-aria-props': 'warn',
        'jsx-a11y/role-supports-aria-props': 'warn',
        'jsx-a11y/scope': 'warn',
    },
});
exports.default = config;

const react = require("eslint-plugin-react")
const reactHooks = require("eslint-plugin-react-hooks")
const globals = require("globals")

module.exports = [
    {
        plugins: {
            react,
            "react-hooks": reactHooks,
        },
        languageOptions: {
            parserOptions: {
                ecmaFeatures: {
                    jsx: true,
                },
            },
            globals: {
                ...globals.browser,
            },
        },
        rules: {
            "react/jsx-boolean-value": "error",
            "react/jsx-curly-brace-presence": "warn",
            "react/jsx-fragments": "warn",
            "react/jsx-no-useless-fragment": ["error", { allowExpressions: true }],
            "react/jsx-sort-props": [
                "warn",
                {
                    callbacksLast: true,
                    shorthandFirst: true,
                    shorthandLast: false,
                    ignoreCase: true,
                    noSortAlphabetically: false,
                    reservedFirst: true,
                },
            ],
            "react/self-closing-comp": "error",

            "react-hooks/exhaustive-deps": "error",
            "react-hooks/rules-of-hooks": "error",
        },
    },
]

const imports = require("eslint-plugin-import")
const perfectionist = require("eslint-plugin-perfectionist")
const unusedImports = require("eslint-plugin-unused-imports")

module.exports = [
    {
        plugins: {
            "unused-imports": unusedImports,
            import: imports,
            perfectionist,
        },
        rules: {
            "@typescript-eslint/no-unused-vars": "off",
            "import/first": "error",
            "import/newline-after-import": "error",
            "import/no-anonymous-default-export": "error",
            "import/no-duplicates": "error",
            "import/no-extraneous-dependencies": "error",
            "import/no-named-default": "error",
            "import/no-self-import": "error",
            "import/no-useless-path-segments": [
                "error",
                {
                    noUselessIndex: true,
                },
            ],
            "perfectionist/sort-imports": [
                "error",
                {
                    type: "natural",
                    order: "asc",
                    groups: [
                        "client-server-only",
                        "react",
                        ["builtin", "external"],
                        ["internal-type", "internal"],
                        ["parent", "sibling", "index"],
                        ["type", "parent-type", "sibling-type", "index-type"],
                        "side-effect",
                        "style",
                        "unknown",
                    ],
                    customGroups: {
                        value: {
                            react: ["^react$", "^react-.+"],
                            "client-server-only": ["^client-only$", "^server-only$"],
                        },
                        type: {
                            react: "^react$",
                        },
                    },
                    newlinesBetween: "never",
                    internalPattern: ["^@leancodepl/.+"],
                },
            ],
            "perfectionist/sort-named-imports": [
                "error",
                {
                    type: "natural",
                    order: "asc",
                },
            ],
            "react/jsx-uses-react": "off",
            "react/jsx-uses-vars": "error",
            "unused-imports/no-unused-imports": "warn",
            "unused-imports/no-unused-vars": [
                "warn",
                {
                    vars: "all",
                    varsIgnorePattern: "^_",
                    args: "after-used",
                    argsIgnorePattern: "^_",
                },
            ],
        },
    },
]

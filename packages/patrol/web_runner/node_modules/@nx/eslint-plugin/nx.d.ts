declare const plugin: {
    configs: {};
    rules: {
        "enforce-module-boundaries": import("@typescript-eslint/utils/ts-eslint").RuleModule<import("./src/rules/enforce-module-boundaries").MessageIds, import("./src/rules/enforce-module-boundaries").Options, unknown, import("@typescript-eslint/utils/ts-eslint").RuleListener>;
        "nx-plugin-checks": import("@typescript-eslint/utils/ts-eslint").RuleModule<import("./src/rules/nx-plugin-checks").MessageIds, import("./src/rules/nx-plugin-checks").Options, unknown, import("@typescript-eslint/utils/ts-eslint").RuleListener>;
        "dependency-checks": import("@typescript-eslint/utils/ts-eslint").RuleModule<import("./src/rules/dependency-checks").MessageIds, import("./src/rules/dependency-checks").Options, unknown, import("@typescript-eslint/utils/ts-eslint").RuleListener>;
    };
};
export default plugin;
//# sourceMappingURL=nx.d.ts.map
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getCustomTrasformersFactory = getCustomTrasformersFactory;
const load_ts_transformers_1 = require("../../../utils/typescript/load-ts-transformers");
function getCustomTrasformersFactory(transformers) {
    const { compilerPluginHooks } = (0, load_ts_transformers_1.loadTsTransformers)(transformers);
    return (program) => ({
        before: compilerPluginHooks.beforeHooks.map((hook) => hook(program)),
        after: compilerPluginHooks.afterHooks.map((hook) => hook(program)),
        afterDeclarations: compilerPluginHooks.afterDeclarationsHooks.map((hook) => hook(program)),
    });
}

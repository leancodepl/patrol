"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.tsConfigBaseOptions = void 0;
exports.extractTsConfigBase = extractTsConfigBase;
const json_1 = require("nx/src/generators/utils/json");
exports.tsConfigBaseOptions = {
    rootDir: '.',
    sourceMap: true,
    declaration: false,
    moduleResolution: 'node',
    emitDecoratorMetadata: true,
    experimentalDecorators: true,
    importHelpers: true,
    target: 'es2015',
    module: 'esnext',
    lib: ['es2020', 'dom'],
    skipLibCheck: true,
    skipDefaultLibCheck: true,
    baseUrl: '.',
    paths: {},
};
function extractTsConfigBase(host) {
    if (host.exists('tsconfig.base.json'))
        return;
    const tsconfig = (0, json_1.readJson)(host, 'tsconfig.json');
    const baseCompilerOptions = {};
    if (tsconfig.compilerOptions) {
        for (let compilerOption of Object.keys(exports.tsConfigBaseOptions)) {
            baseCompilerOptions[compilerOption] =
                tsconfig.compilerOptions[compilerOption];
            delete tsconfig.compilerOptions[compilerOption];
        }
    }
    // If we don't set baseDir then builds will fail when more than one projects exist.
    if (typeof baseCompilerOptions.baseUrl === 'undefined') {
        baseCompilerOptions.baseUrl = '.';
    }
    (0, json_1.writeJson)(host, 'tsconfig.base.json', {
        compileOnSave: false,
        compilerOptions: baseCompilerOptions,
        exclude: tsconfig.exclude,
    });
    tsconfig.extends = './tsconfig.base.json';
    delete tsconfig.compileOnSave;
    delete tsconfig.exclude;
    (0, json_1.writeJson)(host, 'tsconfig.json', tsconfig);
    // special case for updating e2e tests.
    if (host.exists('e2e/tsconfig.json')) {
        (0, json_1.updateJson)(host, 'e2e/tsconfig.json', (json) => {
            json.extends = '../tsconfig.base.json';
            return json;
        });
    }
}

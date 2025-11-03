"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.defaultExclude = void 0;
exports.addSwcConfig = addSwcConfig;
exports.addSwcTestConfig = addSwcTestConfig;
const path_1 = require("path");
exports.defaultExclude = [
    'jest.config.ts',
    '.*\\.spec.tsx?$',
    '.*\\.test.tsx?$',
    './src/jest-setup.ts$',
    './**/jest-setup.ts$',
    '.*.js$',
];
const swcOptionsString = (type = 'commonjs', exclude, supportTsx) => `{
  "jsc": {
    "target": "es2017",
    "parser": {
      "syntax": "typescript",
      "decorators": true,
      "dynamicImport": true${supportTsx
    ? `,
      "tsx": true`
    : ''}
    },
    "transform": {
      "decoratorMetadata": true,
      "legacyDecorator": true${supportTsx
    ? `,
      "react": {
        "runtime": "automatic"
      }`
    : ''}
    },
    "keepClassNames": true,
    "externalHelpers": true,
    "loose": true
  },
  "module": {
    "type": "${type}"
  },
  "sourceMaps": true,
  "exclude": ${JSON.stringify(exclude)}
}
`;
function addSwcConfig(tree, projectDir, type = 'commonjs', supportTsx = false, swcName = '.swcrc', additionalExcludes = []) {
    const swcrcPath = (0, path_1.join)(projectDir, swcName);
    if (tree.exists(swcrcPath))
        return;
    tree.write(swcrcPath, swcOptionsString(type, [...exports.defaultExclude, ...additionalExcludes], supportTsx));
}
function addSwcTestConfig(tree, projectDir, type = 'commonjs', supportTsx = false) {
    const swcrcPath = (0, path_1.join)(projectDir, '.spec.swcrc');
    if (tree.exists(swcrcPath))
        return;
    tree.write(swcrcPath, swcOptionsString(type, [], supportTsx));
}

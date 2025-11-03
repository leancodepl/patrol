"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;

var _helperPluginUtils = require("@babel/helper-plugin-utils");

var _parameterVisitor = require("./parameter/parameterVisitor");

var _metadataVisitor = require("./metadata/metadataVisitor");

var _default = (0, _helperPluginUtils.declare)(api => {
  api.assertVersion(7);
  return {
    visitor: {
      Program(programPath) {
        /**
         * We need to traverse the program right here since
         * `@babel/preset-typescript` removes imports at this level.
         *
         * Since we need to convert some typings into **bindings**, used in
         * `Reflect.metadata` calls, we need to process them **before**
         * the typescript preset.
         */
        programPath.traverse({
          ClassDeclaration(path) {
            for (const field of path.get('body').get('body')) {
              if (field.type !== 'ClassMethod' && field.type !== 'ClassProperty') continue;
              (0, _parameterVisitor.parameterVisitor)(path, field);
              (0, _metadataVisitor.metadataVisitor)(path, field);
            }
            /**
             * We need to keep binding in order to let babel know where imports
             * are used as a Value (and not just as a type), so that
             * `babel-transform-typescript` do not strip the import.
             */


            path.parentPath.scope.crawl();
          }

        });
      }

    }
  };
});

exports.default = _default;
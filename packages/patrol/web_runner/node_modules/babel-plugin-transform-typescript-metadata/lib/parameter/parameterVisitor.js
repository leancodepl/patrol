"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.parameterVisitor = parameterVisitor;

var _core = require("@babel/core");

/**
 * Helper function to create a field/class decorator from a parameter decorator.
 * Field/class decorators get three arguments: the class, the name of the method
 * (or 'undefined' in the case of the constructor) and the position index of the
 * parameter in the argument list.
 * Some of this information, the index, is only available at transform time, and
 * has to be stored. The other arguments are part of the decorator signature and
 * will be passed to the decorator anyway. But the decorator has to be called
 * with all three arguments at runtime, so this creates a function wrapper, which
 * takes the target and the key, and adds the index to it.
 *
 * Inject() becomes function(target, key) { return Inject()(target, key, 0) }
 *
 * @param paramIndex the index of the parameter inside the function call
 * @param decoratorExpression the decorator expression, the return object of SomeParameterDecorator()
 * @param isConstructor indicates if the key should be set to 'undefined'
 */
function createParamDecorator(paramIndex, decoratorExpression, isConstructor = false) {
  return _core.types.decorator(_core.types.functionExpression(null, // anonymous function
  [_core.types.identifier('target'), _core.types.identifier('key')], _core.types.blockStatement([_core.types.returnStatement(_core.types.callExpression(decoratorExpression, [_core.types.identifier('target'), _core.types.identifier(isConstructor ? 'undefined' : 'key'), _core.types.numericLiteral(paramIndex)]))])));
}

function parameterVisitor(classPath, path) {
  if (path.type !== 'ClassMethod') return;
  if (path.node.type !== 'ClassMethod') return;
  if (path.node.key.type !== 'Identifier') return;
  const methodPath = path;
  const params = methodPath.get('params') || [];
  params.slice().forEach(function (param) {
    let identifier = param.node.type === 'Identifier' || param.node.type === 'ObjectPattern' ? param.node : param.node.type === 'TSParameterProperty' && param.node.parameter.type === 'Identifier' ? param.node.parameter : null;
    if (identifier == null) return;
    let resultantDecorator;
    (param.node.decorators || []).slice().forEach(function (decorator) {
      if (methodPath.node.kind === 'constructor') {
        resultantDecorator = createParamDecorator(param.key, decorator.expression, true);

        if (!classPath.node.decorators) {
          classPath.node.decorators = [];
        }

        classPath.node.decorators.push(resultantDecorator);
      } else {
        resultantDecorator = createParamDecorator(param.key, decorator.expression, false);

        if (!methodPath.node.decorators) {
          methodPath.node.decorators = [];
        }

        methodPath.node.decorators.push(resultantDecorator);
      }
    });

    if (resultantDecorator) {
      param.node.decorators = null;
    }
  });
}
import { types as t } from '@babel/core';
import { NodePath } from '@babel/traverse';
declare type InferArray<T> = T extends Array<infer A> ? A : never;
declare type Parameter = InferArray<t.ClassMethod['params']> | t.ClassProperty;
export declare function serializeType(classPath: NodePath<t.ClassDeclaration>, param: Parameter): SerializedType;
/**
 * Checks if node (this should be the result of `serializeReference`) member
 * expression or identifier is a reference to self (class name).
 * In this case, we just emit `Object` in order to avoid ReferenceError.
 */
export declare function isClassType(className: string, node: t.Expression): boolean;
declare type SerializedType = t.Identifier | t.UnaryExpression | t.ConditionalExpression;
export {};
//# sourceMappingURL=serializeType.d.ts.map
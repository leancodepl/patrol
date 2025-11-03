"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.afterDeclarations = exports.after = exports.before = void 0;
const before = (options, program) => {
    return () => { }; // Mock transformer factory
};
exports.before = before;
const after = (options, program) => {
    return () => { }; // Mock transformer factory
};
exports.after = after;
const afterDeclarations = (options, program) => {
    return () => { }; // Mock transformer factory
};
exports.afterDeclarations = afterDeclarations;

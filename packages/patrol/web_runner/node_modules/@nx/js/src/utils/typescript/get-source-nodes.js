"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSourceNodes = getSourceNodes;
function getSourceNodes(sourceFile) {
    const nodes = [sourceFile];
    const result = [];
    while (nodes.length > 0) {
        const node = nodes.shift();
        if (node) {
            result.push(node);
            if (node.getChildCount(sourceFile) >= 0) {
                nodes.unshift(...node.getChildren());
            }
        }
    }
    return result;
}

'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function createNodeIndexMap(nodes) {
  let nodeIndexMap = /* @__PURE__ */ new Map()
  for (let [index, node] of nodes.entries()) {
    nodeIndexMap.set(node, index)
  }
  return nodeIndexMap
}
exports.createNodeIndexMap = createNodeIndexMap

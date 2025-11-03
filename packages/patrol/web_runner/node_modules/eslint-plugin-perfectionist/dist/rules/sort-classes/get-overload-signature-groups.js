'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
const isSortable = require('../../utils/is-sortable.js')
function getOverloadSignatureGroups(members) {
  let methods = members
    .filter(
      member =>
        member.type === 'MethodDefinition' ||
        member.type === 'TSAbstractMethodDefinition',
    )
    .filter(member => member.kind === 'method')
  let staticOverloadSignaturesByName = /* @__PURE__ */ new Map()
  let overloadSignaturesByName = /* @__PURE__ */ new Map()
  for (let method of methods) {
    if (method.key.type !== 'Identifier') {
      continue
    }
    let { name } = method.key
    let mapToUse = method.static
      ? staticOverloadSignaturesByName
      : overloadSignaturesByName
    let signatureOverloadsGroup = mapToUse.get(name)
    if (!signatureOverloadsGroup) {
      signatureOverloadsGroup = []
      mapToUse.set(name, signatureOverloadsGroup)
    }
    signatureOverloadsGroup.push(method)
  }
  return [
    ...overloadSignaturesByName.values(),
    ...staticOverloadSignaturesByName.values(),
  ].filter(isSortable.isSortable)
}
exports.getOverloadSignatureGroups = getOverloadSignatureGroups

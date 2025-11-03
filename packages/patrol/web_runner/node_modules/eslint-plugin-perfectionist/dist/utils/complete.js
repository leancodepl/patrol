'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function complete(options = {}, settings = {}, defaults = {}) {
  return { ...defaults, ...settings, ...options }
}
exports.complete = complete

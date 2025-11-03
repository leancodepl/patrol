'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function matches(value, regexOption) {
  if (Array.isArray(regexOption)) {
    return regexOption.some(opt => matches(value, opt))
  }
  if (typeof regexOption === 'string') {
    return new RegExp(regexOption).test(value)
  }
  if ('source' in regexOption) {
    throw new Error(
      'Invalid configuration: please enter your RegExp expressions as strings.\nFor example, write ".*foo" instead of /.*foo/',
    )
  }
  return new RegExp(regexOption.pattern, regexOption.flags).test(value)
}
exports.matches = matches

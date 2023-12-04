enum PatrolError: Error {
  case viewNotExists(_ elementDescription: String)
  case appNotInstalled(_ bundleId: String)
  case methodNotImplemented(_ methodName: String)
  case `internal`(_ message: String)
  case unknown(_ error: Error)
}

extension PatrolError: CustomStringConvertible {
  var description: String {
    switch self {
    case .viewNotExists(let elementDescription):
      return "\(elementDescription) doesn't exist"
    case .appNotInstalled(let bundleId):
      return "app \(format: bundleId) is not installed"
    case .methodNotImplemented(let methodName):
      return "method \(methodName)() is not implemented on iOS"
    case .internal(let message):
      return message
    case .unknown(let err):
      return "\(err)"
    }
  }
}

extension String.StringInterpolation {
  mutating func appendInterpolation(format value: String) {
    appendInterpolation("\"\(value)\"")
  }
}

import Foundation
import XCTest


enum PatrolError: Error {
  case viewNotExists(_ elementDescription: String)
  case appNotInstalled(_ bundleId: String)
  case generic(_ message: String)
}


extension PatrolError: CustomStringConvertible {
  var description: String {
    switch self {
      case .viewNotExists(let elementDescription): return "\(elementDescription) doesn't exist"
      case .appNotInstalled(let bundleId): return "app \(format: bundleId) is not installed"
      case .generic(let message): return message
    }
  }
}

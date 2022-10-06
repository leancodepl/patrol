import Foundation
import XCTest


enum PatrolError: Error {
  case elementNotFound(_ element: XCUIElement)
  case generic(_ message: String)
}


extension PatrolError: CustomStringConvertible {
  var description: String {
    switch self {
      case .elementNotFound(let element): return "PatrolError: element does not exist. Element: \(element)"
      case .generic(let message): return "PatrolError: \(message)"
    }
  }
}

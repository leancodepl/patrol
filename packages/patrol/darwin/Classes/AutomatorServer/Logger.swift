import Foundation

class Logger {
  private let TAG = "PatrolServer"

  private init() {}

  static let shared = Logger()

  func d(_ msg: String) {
    NSLog("\(TAG): DEBUG: \(msg)")
  }

  func i(_ msg: String) {
    NSLog("\(TAG): INFO: \(msg)")
  }

  func e(_ msg: String) {
    NSLog("\(TAG): ERROR: \(msg)")
  }
}

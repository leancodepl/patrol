import Foundation

class Logger {
  private let TAG = "PatrolServer"

  static let shared = Logger()

  private init() {}

  func i(_ msg: String) {
    NSLog("\(TAG): INFO: \(msg)")
  }

  func e(_ msg: String) {
    NSLog("\(TAG): ERROR: \(msg)")
  }
}

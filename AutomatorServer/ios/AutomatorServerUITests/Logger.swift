import Foundation

class Logger {
  private let TAG = "MaestroServer"

  static let shared = Logger()

  private init() {}

  func i(_ msg: String) {
    NSLog("\(TAG): INFO: \(msg)")
  }

  func e(_ msg: String) {
    NSLog("\(TAG): ERROR: \(msg)")
  }
}

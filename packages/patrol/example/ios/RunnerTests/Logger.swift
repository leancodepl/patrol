import Foundation

@objc class Logger : NSObject {
  private let TAG = "PatrolServer"

  @objc static let shared = Logger()

  private override init() {}

  @objc func i(_ msg: String) {
    NSLog("\(TAG): INFO: \(msg)")
  }

  @objc func e(_ msg: String) {
    NSLog("\(TAG): ERROR: \(msg)")
  }
}

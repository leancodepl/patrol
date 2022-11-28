import Foundation

@objc class Logger : NSObject {
  private let TAG = "PatrolServer"

  @objc public static let shared = Logger()

  private override init() {}

  @objc public func i(_ msg: String) {
    NSLog("\(TAG): INFO: \(msg)")
  }

  @objc public func e(_ msg: String) {
    NSLog("\(TAG): ERROR: \(msg)")
  }
}

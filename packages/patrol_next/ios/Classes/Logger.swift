import Foundation

@objc public class Logger : NSObject {
  private let TAG = "PatrolServer"
  
  private override init() {}

  @objc public static let shared = Logger()
  
  @objc public func d(_ msg: String) {
    NSLog("\(TAG): DEBUG: \(msg)")
  }

  @objc public func i(_ msg: String) {
    NSLog("\(TAG): INFO: \(msg)")
  }

  @objc public func e(_ msg: String) {
    NSLog("\(TAG): ERROR: \(msg)")
  }
}

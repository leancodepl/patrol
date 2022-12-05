import Flutter
import UIKit
import eDistantObject

let kChannelName = "pl.leancode.patrol/main"
let kMethodAllTestsFinished = "allTestsFinished"

let kErrorArchiveFailed = "archive_failed"
let kErrorArchiveFailedMsg = "Failed to archive test results"

/// A Flutter plugin that's responsible for communicating the test results back
/// to iOS XCUITest.
public class SwiftPatrolNextPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: kChannelName,
      binaryMessenger: registrar.messenger()
    )
    
    let instance = SwiftPatrolNextPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    NSLog("call on patrolChannel: %@", call.method)
    
    switch call.method {
    case kMethodAllTestsFinished:
      let arguments = (call.arguments ?? [:]) as! [String: Any]
      let results = arguments["results"] as! [String: String]
      
      let testResultsService = EDOClientService<TestResultsService>.rootObject(withPort: UInt16(9091))
      
      guard let encodedResults = try? NSKeyedArchiver.archivedData(
          withRootObject: results,
          requiringSecureCoding: true
      ) else {
        result(FlutterError(code: kErrorArchiveFailed, message: kErrorArchiveFailed, details: nil))
        return
      }

      testResultsService.submitTestResults(encodedResults)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

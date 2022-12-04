import Flutter
import UIKit
import eDistantObject

let kChannelName = "pl.leancode.patrol/main"
let kMethodAllTestsFinished = "allTestsFinished"

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
      
      let patrolObject = EDOClientService<TestResultsService>.rootObject(withPort: UInt16(9091))
      patrolObject.submitTestResults(
        dummyMessage: "This is app under test speaking",
        encodedResults: NSKeyedArchiver.archivedData(withRootObject: results)
      )
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

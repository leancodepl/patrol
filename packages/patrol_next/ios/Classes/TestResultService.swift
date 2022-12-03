import Foundation

@objc
public protocol TestResultsService {
  
  @objc
  func submitTestResults(dummyMessage: String, encodedResults: Data)
}

@objc
public class ActualTestResultsService : NSObject, TestResultsService {
  
  @objc
  public var testResults: Dictionary<String, String>?
  
  @objc
  public func submitTestResults(dummyMessage: String, encodedResults: Data) {
    NSLog("Test results submitted, message: %@", dummyMessage)
    
    let dict = NSKeyedUnarchiver.unarchiveObject(with: encodedResults) as! Dictionary<String, String>
    for (key, value) in dict {
      NSLog("key %@, value: %@", key, value)
    }
    
    testResults = dict
  }
}

import Foundation

@objc
public protocol TestResultsService {
  
  @objc
  func submitTestResults(_ encodedResults: Data)
}

@objc
public class ActualTestResultsService : NSObject, TestResultsService {
  
  @objc
  public var testResults: Dictionary<String, String>?
  
  @objc
  public func submitTestResults(_ encodedResults: Data) {
    let dict = NSKeyedUnarchiver.unarchiveObject(with: encodedResults) as! Dictionary<String, String>
    for (key, value) in dict {
      NSLog("key %@, value: %@", key, value)
    }
    
    testResults = dict
  }
}

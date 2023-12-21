import XCTest
import patrol

typealias Selector = patrol.Selector

final class RunnerTests: XCTestCase {
  func testSample() {
    // This test is here to serve as a sample for more tests in the future
    XCTAssertEqual(2 + 2, 4)
  }
    
  func testSelectorToNSPredicate_text() {
    var selector = patrol.Selector()
    selector.text = "Log in"
    
    let predicate = selector.toNSPredicate()
    
    NSLog(predicate.predicateFormat)
    XCTAssertEqual(predicate.predicateFormat, """
     label == "Log in" OR \
     title == "Log in"
     """)
  }
  
  func testSelectorToNSPredicate_textStartsWith() {
    var selector = patrol.Selector()
    selector.textStartsWith = "Log in"
    
    let predicate = selector.toNSPredicate()
    
    NSLog(predicate.predicateFormat)
    XCTAssertEqual(predicate.predicateFormat, """
    label BEGINSWITH "Log in" OR \
    title BEGINSWITH "Log in"
    """)
  }
  
  func testSelectorToNSPredicate_textContains() {
    var selector = patrol.Selector()
    selector.textContains = "Log in"
    
    let predicate = selector.toNSPredicate()
    
    NSLog(predicate.predicateFormat)
    XCTAssertEqual(predicate.predicateFormat, """
    label CONTAINS "Log in" OR \
    title CONTAINS "Log in"
    """)
  }
  
  func testSelectorToNSPredicate_resourceId() {
    var selector = patrol.Selector()
    selector.resourceId = "log_in"
    
    let predicate = selector.toNSPredicate()
    
    NSLog(predicate.predicateFormat)
    XCTAssertEqual(predicate.predicateFormat, """
    identifier == "log_in"
    """)
  }
  
  func testSelectorToNSPredicate_complex_1() {
    var selector = patrol.Selector()
    selector.textContains = "text_contains"
    selector.resourceId = "resource_id"
    
    let predicate = selector.toNSPredicate()
    
    NSLog(predicate.predicateFormat)
    XCTAssertEqual(predicate.predicateFormat, """
    (label CONTAINS "text_contains" OR \
    title CONTAINS "text_contains") AND \
    identifier == "resource_id"
    """)
  }
  
  func testSelectorToNSPredicate_complex_2() {
    var selector = patrol.Selector()
    selector.textContains = "text_contains"
    selector.resourceId = "resource_id"
    
    let predicate = selector.toNSPredicate()
    
    NSLog(predicate.predicateFormat)
    XCTAssertEqual(predicate.predicateFormat, """
    (label CONTAINS "text_contains" OR \
    title CONTAINS "text_contains") AND \
    identifier == "resource_id"
    """)
  }
}

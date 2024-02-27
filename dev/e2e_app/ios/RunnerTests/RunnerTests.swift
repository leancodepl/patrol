import XCTest
import patrol

typealias Selector = patrol.Selector
typealias IOSSelector = patrol.IOSSelector

final class RunnerTests: XCTestCase {
  func testSample() {
    // This test is here to serve as a sample for more tests in the future
    XCTAssertEqual(2 + 2, 4)
  }

  func testSelectorToNSPredicate_text() {
    var selector = createEmptySelector()
    selector.text = "Log in"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      label == "Log in" OR \
      title == "Log in"
      """)
  }

  func testSelectorToNSPredicate_textStartsWith() {
    var selector = createEmptySelector()
    selector.textStartsWith = "Log in"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      label BEGINSWITH "Log in" OR \
      title BEGINSWITH "Log in"
      """)
  }

  func testSelectorToNSPredicate_textContains() {
    var selector = createEmptySelector()
    selector.textContains = "Log in"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      label CONTAINS "Log in" OR \
      title CONTAINS "Log in"
      """)
  }

  func testSelectorToNSPredicate_resourceId() {
    var selector = createEmptySelector()
    selector.resourceId = "log_in"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      identifier == "log_in"
      """)
  }

  func testSelectorToNSPredicate_complex_1() {
    var selector = createEmptySelector()
    selector.textContains = "text_contains"
    selector.resourceId = "resource_id"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      (label CONTAINS "text_contains" OR \
      title CONTAINS "text_contains") AND \
      identifier == "resource_id"
      """)
  }

  func testSelectorToNSPredicate_complex_2() {
    var selector = createEmptySelector()
    selector.textContains = "text_contains"
    selector.resourceId = "resource_id"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      (label CONTAINS "text_contains" OR \
      title CONTAINS "text_contains") AND \
      identifier == "resource_id"
      """)
  }

  func testIOSSelectorToNSPredicate_text() {
    var selector = createEmptyIOSSelector()
    selector.elementType = IOSElementType.radioButton

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      elementType == 11
      """)
  }

  func testIOSSelectorToNSPredicate_hasFocus() {
    var selector = createEmptyIOSSelector()
      selector.hasFocus = false

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      hasFocus == NO
      """)
  }

  func testIOSSelectorToNSPredicate_label() {
    var selector = createEmptyIOSSelector()
    selector.labelContains = "Log in"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      label CONTAINS "Log in"
      """)
  }

  func testIOSSelectorToNSPredicate_complex_1() {
    var selector = createEmptyIOSSelector()
    selector.labelContains = "text_contains"
    selector.identifier = "identifier_id"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      label CONTAINS "text_contains" AND \
      identifier == "identifier_id"
      """)
  }

  func testIOSSelectorToNSPredicate_complex_2() {
    var selector = createEmptyIOSSelector()
    selector.labelContains = "text_contains"
    selector.titleStartsWith = "title"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      label CONTAINS "text_contains" AND \
      title BEGINS "title"
      """)
  }
}

private func createEmptySelector(text: String? = nil) -> patrol.Selector {
  // Temporary fix. We will remove the Selector class later
  let jsonString = "{}"

  let jsonData = jsonString.data(using: .utf8)!
  let decoder = JSONDecoder()

  return try! decoder.decode(patrol.Selector.self, from: jsonData)
}

private func createEmptyIOSSelector(text: String? = nil) -> patrol.IOSSelector {
  let jsonString = "{}"

  let jsonData = jsonString.data(using: .utf8)!
  let decoder = JSONDecoder()

  return try! decoder.decode(patrol.IOSSelector.self, from: jsonData)
}

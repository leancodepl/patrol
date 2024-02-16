import XCTest
import patrol

typealias IOSSelector = patrol.IOSSelector

final class RunnerTests: XCTestCase {
  func testSample() {
    // This test is here to serve as a sample for more tests in the future
    XCTAssertEqual(2 + 2, 4)
  }

  func testSelectorToNSPredicate_text() {
    var selector = createEmptySelector()
    selector.elementType = "radioButton"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      elementType == 11
      """)
  }

  func testSelectorToNSPredicate_hasFocus() {
    var selector = createEmptySelector()
      selector.hasFocus = false

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      hasFocus == NO
      """)
  }

  func testSelectorToNSPredicate_label() {
    var selector = createEmptySelector()
    selector.labelContains = "Log in"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      label CONTAINS "Log in"
      """)
  }

  func testSelectorToNSPredicate_complex_1() {
    var selector = createEmptySelector()
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

  func testSelectorToNSPredicate_complex_2() {
    var selector = createEmptySelector()
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

private func createEmptySelector(text: String? = nil) -> patrol.IOSSelector {
  let jsonString = "{}"

  let jsonData = jsonString.data(using: .utf8)!
  let decoder = JSONDecoder()

  return try! decoder.decode(patrol.IOSSelector.self, from: jsonData)
}

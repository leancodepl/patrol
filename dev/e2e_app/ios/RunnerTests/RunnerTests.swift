import XCTest
import patrol

final class RunnerTests: XCTestCase {
  func testSample() {
    XCTAssertEqual(2 + 2, 4)
  }

  func testIOSSelectorToNSPredicate_text() {
    var selector = createEmptyIOSSelector()
    selector.text = "Log in"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      label == "Log in" OR \
      title == "Log in" OR \
      value == "Log in" OR \
      placeholderValue == "Log in"
      """)
  }

  func testIOSSelectorToNSPredicate_textStartsWith() {
    var selector = createEmptyIOSSelector()
    selector.textStartsWith = "Log in"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      label BEGINSWITH "Log in" OR \
      title BEGINSWITH "Log in" OR \
      value BEGINSWITH "Log in" OR \
      placeholderValue BEGINSWITH "Log in"
      """)
  }

  func testIOSSelectorToNSPredicate_textContains() {
    var selector = createEmptyIOSSelector()
    selector.textContains = "Log in"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      label CONTAINS "Log in" OR \
      title CONTAINS "Log in" OR \
      value CONTAINS "Log in" OR \
      placeholderValue CONTAINS "Log in"
      """)
  }

  func testIOSSelectorToNSPredicate_identifier() {
    var selector = createEmptyIOSSelector()
    selector.identifier = "log_in"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      identifier == "log_in"
      """)
  }

  func testIOSSelectorToNSPredicate_label() {
    var selector = createEmptyIOSSelector()
    selector.label = "Log in"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      label == "Log in"
      """)
  }

  func testIOSSelectorToNSPredicate_labelStartsWith() {
    var selector = createEmptyIOSSelector()
    selector.labelStartsWith = "Log"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      label BEGINSWITH "Log"
      """)
  }

  func testIOSSelectorToNSPredicate_title() {
    var selector = createEmptyIOSSelector()
    selector.title = "Log in"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      title == "Log in"
      """)
  }

  func testIOSSelectorToNSPredicate_titleContains() {
    var selector = createEmptyIOSSelector()
    selector.titleContains = "Log"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      title CONTAINS "Log"
      """)
  }

  func testIOSSelectorToNSPredicate_placeholderValue() {
    var selector = createEmptyIOSSelector()
    selector.placeholderValue = "Enter username"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      placeholderValue == "Enter username"
      """)
  }

  func testIOSSelectorToNSPredicate_value() {
    var selector = createEmptyIOSSelector()
    selector.value = "some_value"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      value == "some_value"
      """)
  }

  func testIOSSelectorToNSPredicate_isEnabled() {
    var selector = createEmptyIOSSelector()
    selector.isEnabled = true

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      isEnabled == 1
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
      hasFocus == 0
      """)
  }

  func testIOSSelectorToNSPredicate_complex_textContainsAndIdentifier() {
    var selector = createEmptyIOSSelector()
    selector.textContains = "text_contains"
    selector.identifier = "resource_id"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      (label CONTAINS "text_contains" OR \
      title CONTAINS "text_contains" OR \
      value CONTAINS "text_contains" OR \
      placeholderValue CONTAINS "text_contains") AND \
      identifier == "resource_id"
      """)
  }

  func testIOSSelectorToNSPredicate_complex_labelAndTitle() {
    var selector = createEmptyIOSSelector()
    selector.label = "Welcome"
    selector.titleContains = "back"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      label == "Welcome" AND \
      title CONTAINS "back"
      """)
  }

  func testIOSSelectorToNSPredicate_complex_multipleProperties() {
    var selector = createEmptyIOSSelector()
    selector.textContains = "search"
    selector.isEnabled = true
    selector.identifier = "search_field"

    let predicate = selector.toNSPredicate()

    NSLog(predicate.predicateFormat)
    XCTAssertEqual(
      predicate.predicateFormat,
      """
      (label CONTAINS "search" OR \
      title CONTAINS "search" OR \
      value CONTAINS "search" OR \
      placeholderValue CONTAINS "search") AND \
      identifier == "search_field" AND \
      isEnabled == 1
      """)
  }
}

private func createEmptyIOSSelector() -> patrol.IOSSelector {
  let jsonString = "{}"

  let jsonData = jsonString.data(using: .utf8)!
  let decoder = JSONDecoder()

  return try! decoder.decode(patrol.IOSSelector.self, from: jsonData)
}

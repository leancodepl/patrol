import XCTest
import patrol

final class RunnerTests: XCTestCase {
  func testCreateMethodNameFromPatrolGeneratedGroup_example1() {
    let input = "example_test simple test"
    let expectedOutput = "exampleTest___simpleTest"
    let result = PatrolUtils.createMethodName(fromPatrolGeneratedGroup: input)
    XCTAssertEqual(result, expectedOutput)
  }

  func testCreateMethodNameFromPatrolGeneratedGroup_example2() {
    let input = "example.example_test group name test name"
    let expectedOutput = "example_exampleTest___groupNameTestName"

    let result = PatrolUtils.createMethodName(fromPatrolGeneratedGroup: input)
    XCTAssertEqual(result, expectedOutput)
  }

  func testCreateMethodNameFromPatrolGeneratedGroup_example3() {
    let input = "flows.login.sign_in logs into the app"
    let expectedOutput = "flows_login_signIn___logsIntoTheApp"
    let result = PatrolUtils.createMethodName(fromPatrolGeneratedGroup: input)
    XCTAssertEqual(result, expectedOutput)
  }

  func testCreateMethodNameFromPatrolGeneratedGroup_example4() {
    // Malformed edge case
    let input = "single"
    let expectedOutput = "single___"
    let result = PatrolUtils.createMethodName(fromPatrolGeneratedGroup: input)
    XCTAssertEqual(result, expectedOutput)
  }

  func testCreateMethodNameFromPatrolGeneratedGroup_example5() {
    // Malformed edge case
    let input = ""
    let expectedOutput = "___"
    let result = PatrolUtils.createMethodName(fromPatrolGeneratedGroup: input)
    XCTAssertEqual(result, expectedOutput)
  }

  func testCreateMethodNameFromPatrolGeneratedGroup_example6() {
    let input = "example_test at the beginning"
    let expectedOutput = "exampleTest___atTheBeginning"  // FIXME: This is temporary
    let result = PatrolUtils.createMethodName(fromPatrolGeneratedGroup: input)
    XCTAssertEqual(result, expectedOutput)
  }

  func testConvertFirstPart_example1() {
    let input = "example_test"
    let expectedOutput = "exampleTest"

    let result = PatrolUtils.convertFirstPart(input)
    XCTAssertEqual(result, expectedOutput)
  }

  func testConvertFirstPart_example2() {
    let input = "example.example_test"
    let expectedOutput = "example_exampleTest"

    let result = PatrolUtils.convertFirstPart(input)
    XCTAssertEqual(result, expectedOutput)
  }

  func testConvertFirstPart_example3() {
    let input = "flows.login.sign_in"
    let expectedOutput = "flows_login_signIn"
    let result = PatrolUtils.convertFirstPart(input)
    XCTAssertEqual(result, expectedOutput)
  }

  func testConvertSecondPart_example1() {
    let input = "completes main flow"
    let expectedOutput = "completesMainFlow"

    let result = PatrolUtils.convertSecondPart(input)
    XCTAssertEqual(result, expectedOutput)
  }

  func testConvertSecondPart_example2() {
    let input = "first group secondTest completes_fast!!!"
    let expectedOutput = "firstGroupSecondTestCompletes_fast"

    let result = PatrolUtils.convertSecondPart(input)
    XCTAssertEqual(result, expectedOutput)
  }
}

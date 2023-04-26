// TODO: Run these tests on CI

import XCTest
import patrol

final class RunnerTests: XCTestCase {
    func testCreateMethodNameFromPatrolGeneratedGroup_ExampleWithDotAndUnderscore() {
        let input = "example.example_test"
        let expectedOutput = "example_exampleTest"

        let result = PatrolUtils.createMethodName(fromPatrolGeneratedGroup: input)
        XCTAssertEqual(result, expectedOutput)
    }

    func testCreateMethodNameFromPatrolGeneratedGroup_ExampleWithUnderscoreOnly() {
        let input = "example_test"
        let expectedOutput = "exampleTest"
        let result = PatrolUtils.createMethodName(fromPatrolGeneratedGroup: input)
        XCTAssertEqual(result, expectedOutput)
    }

    func testCreateMethodNameFromPatrolGeneratedGroup_ExampleWithMultipleDotsAndUnderscores() {
        let input = "flows.login.sign_in"
        let expectedOutput = "flows_login_signIn"
        let result = PatrolUtils.createMethodName(fromPatrolGeneratedGroup: input)
        XCTAssertEqual(result, expectedOutput)
    }

    func testCreateMethodNameFromPatrolGeneratedGroup_ExampleWithSingleComponent() {
        let input = "single"
        let expectedOutput = "single"
        let result = PatrolUtils.createMethodName(fromPatrolGeneratedGroup: input)
        XCTAssertEqual(result, expectedOutput)
    }

    func testCreateMethodNameFromPatrolGeneratedGroup_ExampleWithEmptyString() {
        let input = ""
        let expectedOutput = ""
        let result = PatrolUtils.createMethodName(fromPatrolGeneratedGroup: input)
        XCTAssertEqual(result, expectedOutput)
    }
}

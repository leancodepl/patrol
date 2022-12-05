@import Foundation;

NS_ASSUME_NONNULL_BEGIN

typedef void (^PatrolIntegrationTestResults)(SEL nativeTestSelector, BOOL success, NSString *_Nullable failureMessage);

/**
 * Adapted from https://github.com/flutter/flutter/blob/master/packages/integration_test/ios/Classes/FLTIntegrationTestRunner.m
 */
@interface PatrolIntegrationTestRunner : NSObject

/**
 * Any screenshots captured by the plugin.
 */
@property (copy, readonly) NSDictionary<NSString *, UIImage *> *capturedScreenshotsByName;

/**
 * Starts dart tests and waits for results.
 *
 * @param testResult Will be called once per every completed dart test.
 */
- (void)iterateOverTestResults:(NSDictionary<NSString *, NSString *> *)testResults withSelector:(NS_NOESCAPE PatrolIntegrationTestResults)testResult;

/**
 * An appropriate XCTest method name based on the dart test name.
 *
 * Example: dart test "verify widget-ABC123" becomes "testVerifyWidgetABC123"
 */
+ (NSString *)testCaseNameFromDartTestName:(NSString *)dartTestName;

@end

NS_ASSUME_NONNULL_END

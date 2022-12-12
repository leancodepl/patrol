@import Foundation;
@import ObjectiveC.runtime;

NS_ASSUME_NONNULL_BEGIN

typedef void (^PatrolIntegrationTestResults)(SEL nativeTestSelector, BOOL success, NSString *_Nullable failureMessage);

/**
 * Adapted from
 * https://github.com/flutter/flutter/blob/master/packages/integration_test/ios/Classes/FLTIntegrationTestRunner.m
 */
@interface PatrolIntegrationTestRunner : NSObject

/**
 * Any screenshots captured by the plugin.
 */
@property(copy, readonly) NSDictionary<NSString *, UIImage *> *capturedScreenshotsByName;

/**
 * Starts dart tests and waits for results.
 *
 * @param testResult Will be called once per every completed dart test.
 */
- (void)iterateOverTestResults:(NSDictionary<NSString *, NSString *> *)testResults
                  withSelector:(NS_NOESCAPE PatrolIntegrationTestResults)testResult;

/**
 * An appropriate XCTest method name based on the dart test name.
 *
 * Example: dart test "verify widget-ABC123" becomes "testVerifyWidgetABC123"
 */
+ (NSString *)testCaseNameFromDartTestName:(NSString *)dartTestName;

@end

/// Adapted from:
/// https://github.com/flutter/flutter/blob/master/packages/integration_test/ios/Classes/IntegrationTestIosTest.h
#define PATROL_INTEGRATION_TEST_IOS_RUNNER(__test_class)                                                           \
  @interface RunnerTests : XCTestCase                                                                              \
  @end                                                                                                             \
                                                                                                                   \
  @implementation RunnerTests                                                                                      \
                                                                                                                   \
  +(NSArray<NSInvocation *> *)testInvocations {                                                                    \
    /* Start native automation gRPC server */                                                                      \
    PatrolServer *server = [[PatrolServer alloc] init];                                                            \
    [server startWithCompletionHandler:^(NSError * err) {                                                          \
      NSLog(@"Server loop done, error: %@", err);                                                                  \
    }];                                                                                                            \
                                                                                                                   \
    XCUIApplication *app = [[XCUIApplication alloc] init];                                                         \
    [app launch];                                                                                                  \
                                                                                                                   \
    /* Spin the runloop waiting for test results */                                                                \
    while (!server.dartTestResults) {                                                                              \
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                           \
    }                                                                                                              \
                                                                                                                   \
    PatrolIntegrationTestRunner *testRunner = [[PatrolIntegrationTestRunner alloc] init];                          \
    NSMutableArray<NSInvocation *> *testInvocations = [[NSMutableArray alloc] init];                               \
                                                                                                                   \
    /* Dynamically create test case methods from Dart results */                                                   \
    [testRunner iterateOverTestResults:server.dartTestResults                                                      \
                          withSelector:^(SEL testSelector, BOOL success, NSString * failureMessage) {              \
                            IMP assertImplementation = imp_implementationWithBlock(^(id _self) {                   \
                              XCTAssertTrue(success, @"%@", failureMessage);                                       \
                            });                                                                                    \
                            class_addMethod(self, testSelector, assertImplementation, "v@:");                      \
                            NSMethodSignature *signature = [self instanceMethodSignatureForSelector:testSelector]; \
                            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];     \
                            invocation.selector = testSelector;                                                    \
                            [testInvocations addObject:invocation];                                                \
                          }];                                                                                      \
                                                                                                                   \
    /* Add captured screenshots */                                                                                 \
    NSDictionary<NSString *, UIImage *> *capturedScreenshotsByName = testRunner.capturedScreenshotsByName;         \
    if (capturedScreenshotsByName.count > 0) {                                                                     \
      IMP screenshotImplementation = imp_implementationWithBlock(^(id _self) {                                     \
        [capturedScreenshotsByName                                                                                 \
            enumerateKeysAndObjectsUsingBlock:^(NSString * name, UIImage * screenshot, BOOL * stop) {              \
              XCTAttachment *attachment = [XCTAttachment attachmentWithImage:screenshot];                          \
              attachment.lifetime = XCTAttachmentLifetimeKeepAlways;                                               \
              if (name != nil) {                                                                                   \
                attachment.name = name;                                                                            \
              }                                                                                                    \
              [_self addAttachment:attachment];                                                                    \
            }];                                                                                                    \
      });                                                                                                          \
      SEL attachmentSelector = NSSelectorFromString(@"screenshotPlaceholder");                                     \
      class_addMethod(self, attachmentSelector, screenshotImplementation, "v@:");                                  \
      NSMethodSignature *attachmentSignature = [self instanceMethodSignatureForSelector:attachmentSelector];       \
      NSInvocation *attachmentInvocation = [NSInvocation invocationWithMethodSignature:attachmentSignature];       \
      attachmentInvocation.selector = attachmentSelector;                                                          \
      [testInvocations addObject:attachmentInvocation];                                                            \
    }                                                                                                              \
                                                                                                                   \
    return testInvocations;                                                                                        \
  }                                                                                                                \
                                                                                                                   \
  @end

NS_ASSUME_NONNULL_END

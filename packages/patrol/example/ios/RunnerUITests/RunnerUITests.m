@import XCTest;
@import patrol;
@import ObjectiveC.runtime;

NS_ASSUME_NONNULL_BEGIN

typedef void (^PatrolIntegrationTestResults)(SEL nativeTestSelector, BOOL success, NSString *_Nullable failureMessage);

/**
 * Adapted from
 * https://github.com/flutter/flutter/blob/master/packages/integration_test/ios/Classes/FLTIntegrationTestRunner.m
 */
@interface PatrolIntegrationTestRunner : NSObject
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
+ (NSString *)createMethodNameFromPatrolGeneratedGroup:(NSString *)dartTestGroup;

@end

@interface RunnerUITests : XCTestCase
@end

@implementation RunnerUITests
+ (NSArray<NSInvocation *> *)testInvocations {
  // Start native automation gRPC server
  PatrolServer *server = [[PatrolServer alloc] init];
  [server startWithCompletionHandler:^(NSError *err) {
    NSLog(@"Server loop done, error: %@", err);
  }];

  // Create a client for PatrolAppService, which lets us list and run Dart tests
  __block PatrolAppServiceClient *appServiceClient = [[PatrolAppServiceClient alloc] init];

  // Allow the Local Network permission required by Dart Observatory
  XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
  XCUIElementQuery *systemAlerts = springboard.alerts;
  if (systemAlerts.buttons[@"Allow"].exists) {
    [systemAlerts.buttons[@"Allow"] tap];
  }

  // Run the app for the first time to gather Dart tests
  __block XCUIApplication *app = [[XCUIApplication alloc] init];
  [app activate];

  // Spin the runloop waiting until the app reports that it is ready to report
  // Dart tests
  while (!server.appReady) {
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
  }

  __block NSArray<NSString *> *dartTestFiles = NULL;
  [appServiceClient
      listDartTestsWithCompletionHandler:^(NSArray<NSString *> *_Nullable dartTests, NSError *_Nullable err) {
        if (err != NULL) {
          NSLog(@"listDartTests(): failed, err: %@", err);
        }

        dartTestFiles = dartTests;
        [app terminate];
      }];

  // Wait for Dart tests
  while (!dartTestFiles) {
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
  }

  
  NSMutableArray<NSInvocation *> *invocations = [[NSMutableArray alloc] init];

  // Once Dart tests are available, we:
  //  Step 1. Dynamically add test case methods to this class. The bodies of the methods request execution of an individual Dart test file.
  //  Step 2. Create invocations to the generated methods and return them
  for (NSString *dartTestFile in dartTestFiles) {
    // Step 1
    IMP runDartTestImplementation = imp_implementationWithBlock(^(id _self) {
      XCUIApplication *app = [[XCUIApplication alloc] init];
      [app activate];

      [appServiceClient runDartTestWithName:dartTestFile
                          completionHandler:^(RunDartTestResponse *_Nullable response, NSError *_Nullable err) {
                            XCTAssertTrue(response.passed, @"%@", response.details);
                          }];
    });
    NSString *selectorStr = [PatrolIntegrationTestRunner createMethodNameFromPatrolGeneratedGroup:dartTestFile];
    SEL selector = NSSelectorFromString(selectorStr);
    
    const char *s = "v@:"; // Method signature. v for void, @ for self, : for the selector
    class_addMethod(self, selector, runDartTestImplementation, s);
    
    // Step 2
    
    NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocations addObject:invocation];
  }

  return invocations;
}

@end

NS_ASSUME_NONNULL_END

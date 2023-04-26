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
+ (NSString *)testCaseNameFromDartTestName:(NSString *)dartTestName;

@end

@interface RunnerUITests : XCTestCase
@end
                                                                                                                 
@implementation RunnerUITests
+(NSArray<NSInvocation *> *)testInvocations {
  // Start native automation gRPC server
  PatrolServer *server = [[PatrolServer alloc] init];
  [server startWithCompletionHandler:^(NSError * err) {
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
  XCUIApplication *app = [[XCUIApplication alloc] init];
  [app activate];
                                                                                                                 
  // Spin the runloop waiting until the app reports that it is ready to report Dart tests
  while (!server.appReady) {
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
  }
    
    __block NSArray<NSString*>* dartTestFiles = NULL;
    [appServiceClient listDartTestsWithCompletionHandler:^(NSArray<NSString *> * _Nullable dartTests, NSError * _Nullable err) {
        if (err != NULL) {
            NSLog(@"listDartTests(): failed, err: %@", err);
        }
        
        dartTestFiles = dartTests;
    }];
    
  // Wait for Dart tests
    while (!dartTestFiles) {
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }
    
                                                                                                                 
  PatrolIntegrationTestRunner *testRunner = [[PatrolIntegrationTestRunner alloc] init];
  NSMutableArray<NSInvocation *> *invocations = [[NSMutableArray alloc] init];
    
    for (NSString *dartTestFile in dartTestFiles) {
        IMP runDartTestImplementation = imp_implementationWithBlock(^(id _self) {
            [appServiceClient runDartTestWithName:dartTestFile
                                completionHandler:^(RunDartTestResponse * _Nullable response, NSError * _Nullable err) {
                XCTAssertTrue(response.passed, @"%@", response.details);
            }];
        });
        
        class_addMethod(self, <#SEL  _Nonnull name#>, <#IMP  _Nonnull imp#>, <#const char * _Nullable types#>)
    }
                                                                                                                 
  /* Dynamically create test case methods from Dart results */
  [testRunner iterateOverTestResults:server.dartTestResults
                        withSelector:^(SEL testSelector, BOOL success, NSString * failureMessage) {
                          IMP assertImplementation = imp_implementationWithBlock(^(id _self) {
                            XCTAssertTrue(success, @"%@", failureMessage);
                          });
                          class_addMethod(self, testSelector, assertImplementation, "v@:");
                          NSMethodSignature *signature = [self instanceMethodSignatureForSelector:testSelector];
                          NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                          invocation.selector = testSelector;
                          [invocations addObject:invocation];
                        }];
                                                                                                                 
  return invocations;
}
                                                                                                                 
@end

NS_ASSUME_NONNULL_END

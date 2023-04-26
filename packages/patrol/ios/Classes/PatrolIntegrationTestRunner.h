@import Foundation;
@import ObjectiveC.runtime;

// For every Flutter dart test, dynamically generate an Objective-C method mirroring the test results
// so it is reported as a native XCTest run result.
// If the Flutter dart tests have captured screenshots, add them to the XCTest bundle.
#define INTEGRATION_TEST_IOS_RUNNER(__test_class)                                                                      \
  NS_ASSUME_NONNULL_BEGIN                                                                                              \
  @interface __test_class : XCTestCase                                                                                 \
  @end                                                                                                                 \
                                                                                                                       \
  @implementation __test_class                                                                                         \
  +(NSArray<NSInvocation *> *)testInvocations {                                                                        \
    /* Start native automation gRPC server */                                                                          \
    PatrolServer *server = [[PatrolServer alloc] init];                                                                \
    [server startWithCompletionHandler:^(NSError * err) {                                                              \
      NSLog(@"Server loop done, error: %@", err);                                                                      \
    }];                                                                                                                \
                                                                                                                       \
    /* Create a client for PatrolAppService, which lets us list and run Dart tests */                                  \
    __block PatrolAppServiceClient *appServiceClient = [[PatrolAppServiceClient alloc] init];                          \
                                                                                                                       \
    /* Allow the Local Network permission required by Dart Observatory */                                              \
    XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];        \
    XCUIElementQuery *systemAlerts = springboard.alerts;                                                               \
    if (systemAlerts.buttons[@"Allow"].exists) {                                                                       \
      [systemAlerts.buttons[@"Allow"] tap];                                                                            \
    }                                                                                                                  \
                                                                                                                       \
    /* Run the app for the first time to gather Dart tests */                                                          \
    __block XCUIApplication *app = [[XCUIApplication alloc] init];                                                     \
    [app activate];                                                                                                    \
                                                                                                                       \
    /* Spin the runloop waiting until the app reports that it is ready to report Dart tests */                         \
    while (!server.appReady) {                                                                                         \
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                               \
    }                                                                                                                  \
                                                                                                                       \
    __block NSArray<NSString *> *dartTestFiles = NULL;                                                                 \
    [appServiceClient                                                                                                  \
        listDartTestsWithCompletionHandler:^(NSArray<NSString *> *_Nullable dartTests, NSError *_Nullable err) {       \
          if (err != NULL) {                                                                                           \
            NSLog(@"listDartTests(): failed, err: %@", err);                                                           \
          }                                                                                                            \
                                                                                                                       \
          dartTestFiles = dartTests;                                                                                   \
          [app terminate];                                                                                             \
        }];                                                                                                            \
                                                                                                                       \
    /* Wait for Dart tests */                                                                                          \
    while (!dartTestFiles) {                                                                                           \
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                               \
    }                                                                                                                  \
                                                                                                                       \
    NSMutableArray<NSInvocation *> *invocations = [[NSMutableArray alloc] init];                                       \
                                                                                                                       \
    /**                                                                                                                \
     * Once Dart tests are available, we:                                                                              \
     *  Step 1. Dynamically add test case methods to this class. The body of these methods request execution of an     \
     * individual Dart test file. Step 2. Create invocations to the generated methods and return them                  \
     */                                                                                                                \
                                                                                                                       \
    for (NSString * dartTestFile in dartTestFiles) {                                                                   \
      /* Step 1 */                                                                                                     \
      IMP runDartTestImplementation = imp_implementationWithBlock(^(id _self) {                                        \
        XCUIApplication *app = [[XCUIApplication alloc] init];                                                         \
        [app activate];                                                                                                \
                                                                                                                       \
        [appServiceClient runDartTestWithName:dartTestFile                                                             \
                            completionHandler:^(RunDartTestResponse *_Nullable response, NSError *_Nullable err) {     \
                              XCTAssertTrue(response.passed, @"%@", response.details);                                 \
                            }];                                                                                        \
      });                                                                                                              \
      NSString *selectorStr = [PatrolUtils createMethodNameFromPatrolGeneratedGroup:dartTestFile];                     \
      SEL selector = NSSelectorFromString(selectorStr);                                                                \
                                                                                                                       \
      const char *s = "v@:"; /* Method signature. v for void, @ for self, : for the selector */                        \
      class_addMethod(self, selector, runDartTestImplementation, s);                                                   \
                                                                                                                       \
      /* Step 2 */                                                                                                     \
                                                                                                                       \
      NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];                               \
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];                               \
      [invocations addObject:invocation];                                                                              \
    }                                                                                                                  \
                                                                                                                       \
    return invocations;                                                                                                \
  }                                                                                                                    \
                                                                                                                       \
  @end\
NS_ASSUME_NONNULL_END\

// This file is a one giant macro to make the setup as easy as possible for the developer.
// To edit it:
//  1. Remove the trailing backslashes: $ sed 's/\\$//' ios/Classes/PatrolIntegrationTestRunner.h
//  2. Paste its contents into the RunnerUITests.m in the RunnerUITests target
//  3. Make the changes, make sure it works
//  4. Re-add trailing backslashes: $ sed 's/$/\\/' ios/Classes/PatrolIntegrationTestRunner.h
//  5. Copy the contents from RunnerUITests.m back here
//  6. Go back to using a macro in RunnerTests.m

// For every Flutter dart test, dynamically generate an Objective-C method mirroring the test results
// so it is reported as a native XCTest run result.
#define PATROL_INTEGRATION_TEST_IOS_RUNNER(__test_class)                                                            \
  @interface __test_class : XCTestCase                                                                              \
  @end                                                                                                              \
                                                                                                                    \
  @implementation __test_class                                                                                      \
                                                                                                                    \
  +(NSArray<NSInvocation *> *)testInvocations {                                                                     \
    /* Start native automation server */                                                                            \
    PatrolServer *server = [[PatrolServer alloc] init];                                                             \
                                                                                                                    \
    NSError *_Nullable __autoreleasing *_Nullable err = NULL;                                                       \
    [server startAndReturnError:err];                                                                               \
    if (err != NULL) {                                                                                              \
      NSLog(@"patrolServer.start(): failed, err: %@", err);                                                         \
    }                                                                                                               \
                                                                                                                    \
    /* Create a client for PatrolAppService, which lets us list and run Dart tests */                               \
    __block ObjCPatrolAppServiceClient *appServiceClient = [[ObjCPatrolAppServiceClient alloc] init];               \
                                                                                                                    \
    /* Allow the Local Network permission required by Dart Observatory */                                           \
    XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];     \
    XCUIElementQuery *systemAlerts = springboard.alerts;                                                            \
    if (systemAlerts.buttons[@"Allow"].exists) {                                                                    \
      [systemAlerts.buttons[@"Allow"] tap];                                                                         \
    }                                                                                                               \
                                                                                                                    \
    /* Run the app for the first time to gather Dart tests */                                                       \
    [[[XCUIApplication alloc] init] launch];                                                                        \
                                                                                                                    \
    /* Spin the runloop waiting until the app reports that it is ready to report Dart tests */                      \
    while (!server.appReady) {                                                                                      \
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                            \
    }                                                                                                               \
                                                                                                                    \
    __block NSArray<NSString *> *dartTests = NULL;                                                                  \
    [appServiceClient listDartTestsWithCompletion:^(NSArray<NSString *> *_Nullable tests, NSError *_Nullable err) { \
      if (err != NULL) {                                                                                            \
        NSLog(@"listDartTests(): failed, err: %@", err);                                                            \
      }                                                                                                             \
                                                                                                                    \
      dartTests = tests;                                                                                            \
    }];                                                                                                             \
                                                                                                                    \
    /* Spin the runloop waiting until the app reports the Dart tests it contains */                                 \
    while (!dartTests) {                                                                                            \
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                            \
    }                                                                                                               \
                                                                                                                    \
    NSLog(@"Got %lu Dart tests: %@", dartTests.count, dartTests);                                                   \
                                                                                                                    \
    NSMutableArray<NSInvocation *> *invocations = [[NSMutableArray alloc] init];                                    \
                                                                                                                    \
    /**                                                                                                             \
     * Once Dart tests are available, we:                                                                           \
     *                                                                                                              \
     *  Step 1. Dynamically add test case methods that request execution of an individual Dart test file.           \
     *                                                                                                              \
     *  Step 2. Create invocations to the generated methods and return them                                         \
     */                                                                                                             \
                                                                                                                    \
    for (NSString * dartTest in dartTests) {                                                                        \
      /* Step 1 - dynamically create test cases */                                                                  \
                                                                                                                    \
      IMP implementation = imp_implementationWithBlock(^(id _self) {                                                \
        [[[XCUIApplication alloc] init] launch];                                                                    \
                                                                                                                    \
        __block ObjCRunDartTestResponse *response = NULL;                                                           \
        [appServiceClient runDartTestWithName:dartTest                                                              \
                                   completion:^(ObjCRunDartTestResponse *_Nullable r, NSError *_Nullable err) {     \
                                     if (err != NULL) {                                                             \
                                       NSLog(@"runDartTestWithName(%@): failed, err: %@", dartTest, err);           \
                                     }                                                                              \
                                                                                                                    \
                                     response = r;                                                                  \
                                   }];                                                                              \
                                                                                                                    \
        /* Wait until Dart test finishes */                                                                         \
        while (!response) {                                                                                         \
          [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                        \
        }                                                                                                           \
                                                                                                                    \
        XCTAssertTrue(response.passed, @"%@", response.details);                                                    \
      });                                                                                                           \
      NSString *selectorName = [PatrolUtils createMethodNameFromPatrolGeneratedGroup:dartTest];                     \
      SEL selector = NSSelectorFromString(selectorName);                                                            \
      class_addMethod(self, selector, implementation, "v@:");                                                       \
                                                                                                                    \
      /* Step 2 – create invocations to the dynamically created methods */                                        \
      NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];                            \
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];                            \
      invocation.selector = selector;                                                                               \
                                                                                                                    \
      NSLog(@"RunnerUITests.testInvocations(): selectorName = %@, signature: %@", selectorName, signature);         \
                                                                                                                    \
      [invocations addObject:invocation];                                                                           \
    }                                                                                                               \
                                                                                                                    \
    return invocations;                                                                                             \
  }                                                                                                                 \
                                                                                                                    \
  @end\

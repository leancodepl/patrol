// This file is a one giant macro to make the setup as easy as possible for the developer.
// To edit it:
//  1. Remove the trailing backslashes: $ sed 's/\\$//' PatrolIntegrationTestMacosRunner.h
//  2. Paste its contents into the RunnerUITests.m in the RunnerUITests target
//  3. Make the changes, make sure it works
//  4. Re-add trailing backslashes: $ sed 's/$/\\/' PatrolIntegrationTestMacosRunner.h
//  5. Copy the contents from RunnerUITests.m back here
//  6. Go back to using a macro in RunnerUITests.m

// For every Flutter dart test, dynamically generate an Objective-C method mirroring the test results
// so it is reported as a native XCTest run result.
#define PATROL_INTEGRATION_TEST_MACOS_RUNNER(__test_class)                                                            \
  @interface __test_class : XCTestCase                                                                                \
  @end                                                                                                                \
                                                                                                                      \
  @implementation __test_class                                                                                        \
                                                                                                                      \
  +(NSArray<NSInvocation *> *)testInvocations {                                                                       \
    /* Start native automation gRPC server */                                                                         \
    PatrolServer *server = [[PatrolServer alloc] init];                                                               \
    NSError *_Nullable __autoreleasing *_Nullable err = NULL;                                                         \
    [server startAndReturnError:err];                                                                                 \
    if (err != NULL) {                                                                                                \
      NSLog(@"patrolServer.start(): failed, err: %@", err);                                                           \
    }                                                                                                                 \
                                                                                                                      \
    NSLog(@"Create PatrolAppServiceClient");                                                                          \
                                                                                                                      \
    /* Create a client for PatrolAppService, which lets us list and run Dart tests */                                 \
    __block ObjCPatrolAppServiceClient *appServiceClient = [[ObjCPatrolAppServiceClient alloc] init];                 \
                                                                                                                      \
    NSLog(@"Run the app for the first time");                                                                         \
                                                                                                                      \
    /* Run the app for the first time to gather Dart tests */                                                         \
    [[[XCUIApplication alloc] init] launch];                                                                          \
                                                                                                                      \
    NSLog(@"Waiting until the app reports that it is ready");                                                         \
                                                                                                                      \
    /* Spin the runloop waiting until the app reports that it is ready to report Dart tests */                        \
    while (!server.appReady) {                                                                                        \
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                              \
    }                                                                                                                 \
                                                                                                                      \
    NSLog(@"listDartTests");                                                                                          \
                                                                                                                      \
    __block NSArray<NSString *> *dartTests = NULL;                                                                    \
    [appServiceClient listDartTestsWithCompletion:^(NSArray<NSString *> *_Nullable tests, NSError *_Nullable err) {   \
      if (err != NULL) {                                                                                              \
        NSLog(@"listDartTests(): failed, err: %@", err);                                                              \
      }                                                                                                               \
                                                                                                                      \
      dartTests = tests;                                                                                              \
    }];                                                                                                               \
                                                                                                                      \
    NSLog(@"Spin the runloop waiting");                                                                               \
                                                                                                                      \
    /* Spin the runloop waiting until the app reports the Dart tests it contains */                                   \
    while (!dartTests) {                                                                                              \
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];                              \
    }                                                                                                                 \
                                                                                                                      \
    NSLog(@"Got %lu Dart tests: %@", dartTests.count, dartTests);                                                     \
                                                                                                                      \
    NSMutableArray<NSInvocation *> *invocations = [[NSMutableArray alloc] init];                                      \
                                                                                                                      \
    /**                                                                                                               \
     * Once Dart tests are available, we:                                                                             \
     *                                                                                                                \
     *  Step 1. Dynamically add test case methods that request execution of an individual Dart test file.             \
     *                                                                                                                \
     *  Step 2. Create invocations to the generated methods and return them                                           \
     */                                                                                                               \
                                                                                                                      \
    for (NSString * dartTest in dartTests) {                                                                          \
      /* Step 1 - dynamically create test cases */                                                                    \
                                                                                                                      \
      IMP implementation = imp_implementationWithBlock(^(id _self) {                                                  \
        [[[XCUIApplication alloc] init] launch];                                                                      \
                                                                                                                      \
        __block ObjCRunDartTestResponse *response = NULL;                                                             \
        __block NSError *error;                                                                                       \
        [appServiceClient runDartTestWithName:dartTest                                                                \
                                   completion:^(ObjCRunDartTestResponse *_Nullable r, NSError *_Nullable err) {       \
                                     NSString *status;                                                                \
                                     if (err != NULL) {                                                               \
                                       error = err;                                                                   \
                                       status = @"CRASHED";                                                           \
                                     } else {                                                                         \
                                       response = r;                                                                  \
                                       status = response.passed ? @"PASSED" : @"FAILED";                              \
                                     }                                                                                \
                                     NSLog(@"runDartTest(\"%@\"): call finished, test result: %@", dartTest, status); \
                                   }];                                                                                \
                                                                                                                      \
        /* Wait until Dart test finishes (either fails or passes) or crashes */                                       \
        while (!response && !error) {                                                                                 \
          [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                          \
        }                                                                                                             \
        BOOL passed = response ? response.passed : NO;                                                                \
        NSString *details = response ? response.details : @"(no details - app likely crashed)";                       \
        XCTAssertTrue(passed, @"%@", details);                                                                        \
      });                                                                                                             \
      SEL selector = NSSelectorFromString(dartTest);                                                                  \
      class_addMethod(self, selector, implementation, "v@:");                                                         \
                                                                                                                      \
      /* Step 2 – create invocations to the dynamically created methods */                                          \
      NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];                              \
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];                              \
      invocation.selector = selector;                                                                                 \
                                                                                                                      \
      NSLog(@"RunnerUITests.testInvocations(): selectorName = %@, signature: %@", dartTest, signature);               \
                                                                                                                      \
      [invocations addObject:invocation];                                                                             \
    }                                                                                                                 \
                                                                                                                      \
    return invocations;                                                                                               \
  }                                                                                                                   \
                                                                                                                      \
  @end\

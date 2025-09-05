// This file is a one giant macro to make the setup as easy as possible for the developer.
// To edit it:
//  1. Remove the trailing backslashes: $ sed 's/\\$//' PatrolIntegrationTestIosRunner.h
//  2. Paste its contents into the RunnerUITests.m in the RunnerUITests target
//  3. Make the changes, make sure it works
//  4. Re-add trailing backslashes: $ sed 's/$/\\/' PatrolIntegrationTestIosRunner.h
//  5. Copy the contents from RunnerUITests.m back here
//  6. Go back to using a macro in RunnerUITests.m

// For every Flutter dart test, dynamically generate an Objective-C method mirroring the test results
// so it is reported as a native XCTest run result.
#ifdef UNINSTALL_APP
#define PATROL_INTEGRATION_TEST_IOS_RUNNER(__test_class)                                                        \
  @interface __test_class : XCTestCase                                                                          \
  @property(class, strong, nonatomic) NSDictionary *selectedTest;                                               \
  @end                                                                                                          \
                                                                                                                \
  @implementation __test_class                                                                                  \
                                                                                                                \
  static NSDictionary *_selectedTest = nil;                                                                     \
                                                                                                                \
  +(NSDictionary *)selectedTest {                                                                               \
    return _selectedTest;                                                                                       \
  }                                                                                                             \
                                                                                                                \
  +(void)setSelectedTest : (NSDictionary *)newSelectedTest {                                                    \
    if (newSelectedTest != _selectedTest) {                                                                     \
      _selectedTest = [newSelectedTest copy];                                                                   \
    }                                                                                                           \
  }                                                                                                             \
                                                                                                                \
  +(BOOL)instancesRespondToSelector : (SEL)aSelector {                                                          \
    NSString *name = NSStringFromSelector(aSelector);                                                           \
    BOOL skip = NO;                                                                                             \
    NSDictionary *testInfo = @{@"name" : name, @"skip" : @(skip)};                                              \
    [self setSelectedTest:testInfo];                                                                            \
                                                                                                                \
    [self defaultTestSuite]; /* calls testInvocations */                                                        \
    BOOL result = [super instancesRespondToSelector:aSelector];                                                 \
    return true;                                                                                                \
  }                                                                                                             \
                                                                                                                \
  +(void)uninstallApp {                                                                                         \
    XCUIApplication *app = [[XCUIApplication alloc] init];                                                      \
    NSString *appName = app.label;                                                                              \
    NSLog(@"Uninstalling app: %@", appName);                                                                    \
                                                                                                                \
    [app terminate];                                                                                            \
                                                                                                                \
    XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"]; \
                                                                                                                \
    XCUIElement *icon = springboard.icons[appName];                                                             \
    if (!icon.exists) {                                                                                         \
      NSLog(@"App icon not found on Springboard: %@", appName);                                                 \
      return;                                                                                                   \
    }                                                                                                           \
                                                                                                                \
    CGRect iconFrame = icon.frame;                                                                              \
    CGRect springboardFrame = springboard.frame;                                                                \
                                                                                                                \
    [icon pressForDuration:1.3];                                                                                \
                                                                                                                \
    if (@available(iOS 13.0, *)) {                                                                              \
      XCUIElement *removeAppButton = springboard.buttons[@"Remove App"];                                        \
      if (!removeAppButton.exists) {                                                                            \
        NSLog(@"'Remove App' button not found");                                                                \
        return;                                                                                                 \
      }                                                                                                         \
                                                                                                                \
      [removeAppButton tap];                                                                                    \
                                                                                                                \
      XCUIElement *deleteAppAlert = springboard.alerts.buttons[@"Delete App"];                                  \
      if (deleteAppAlert.exists) {                                                                              \
        [deleteAppAlert tap];                                                                                   \
        while (deleteAppAlert.exists) {                                                                         \
          [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];                    \
        }                                                                                                       \
      }                                                                                                         \
                                                                                                                \
      XCUIElement *deleteAlert = springboard.alerts.buttons[@"Delete"];                                         \
      if (deleteAlert.exists) {                                                                                 \
        [deleteAlert tap];                                                                                      \
        while (deleteAlert.exists) {                                                                            \
          [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];                    \
        }                                                                                                       \
      }                                                                                                         \
    } else {                                                                                                    \
      CGVector deleteButtonVector = CGVectorMake((iconFrame.origin.x + 3) / springboardFrame.size.width,        \
                                                 (iconFrame.origin.y + 3) / springboardFrame.size.height);      \
      XCUICoordinate *deleteButtonCoordinate = [springboard coordinateWithNormalizedOffset:deleteButtonVector]; \
      [deleteButtonCoordinate tap];                                                                             \
                                                                                                                \
      XCUIElement *deleteButton = springboard.alerts.buttons[@"Delete"];                                        \
      if (deleteButton.exists) {                                                                                \
        [deleteButton tap];                                                                                     \
        while (deleteButton.exists) {                                                                           \
          [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];                    \
        }                                                                                                       \
      }                                                                                                         \
    }                                                                                                           \
                                                                                                                \
    NSLog(@"App uninstallation completed");                                                                     \
  }                                                                                                             \
                                                                                                                \
  +(NSArray<NSInvocation *> *)testInvocations {                                                                 \
    NSLog(@"Running tests with app uninstall");                                                                 \
    /* Start native automation server */                                                                        \
    PatrolServer *server = [[PatrolServer alloc] init];                                                         \
                                                                                                                \
    NSError *_Nullable __autoreleasing *_Nullable err = NULL;                                                   \
    [server startAndReturnError:err];                                                                           \
    if (err != NULL) {                                                                                          \
      NSLog(@"patrolServer.start(): failed, err: %@", err);                                                     \
    }                                                                                                           \
                                                                                                                \
    /* Create a client for PatrolAppService, which lets us list and run Dart tests */                           \
    __block ObjCPatrolAppServiceClient *appServiceClient = [[ObjCPatrolAppServiceClient alloc] init];           \
                                                                                                                \
    /* Allow the Local Network permission required by Dart Observatory */                                       \
    XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"]; \
    XCUIElementQuery *systemAlerts = springboard.alerts;                                                        \
    if (systemAlerts.buttons[@"Allow"].exists) {                                                                \
      [systemAlerts.buttons[@"Allow"] tap];                                                                     \
    }                                                                                                           \
                                                                                                                \
    __block NSArray<NSDictionary *> *dartTests = NULL;                                                          \
    if ([self selectedTest] != nil) {                                                                           \
      NSLog(@"selectedTest: %@", [self selectedTest]);                                                          \
      dartTests = [NSArray arrayWithObject:[self selectedTest]];                                                \
    } else {                                                                                                    \
      /* Run the app for the first time to gather Dart tests */                                                 \
      [[[XCUIApplication alloc] init] launch];                                                                  \
      /* Spin the runloop waiting until the app reports that it is ready to report Dart tests */                \
      while (!server.appReady) {                                                                                \
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                      \
      }                                                                                                         \
      [appServiceClient                                                                                         \
          listDartTestsWithCompletion:^(NSArray<NSDictionary *> *_Nullable tests, NSError *_Nullable err) {     \
            if (err != NULL) {                                                                                  \
              NSLog(@"listDartTests(): failed, err: %@", err);                                                  \
            }                                                                                                   \
                                                                                                                \
            dartTests = tests;                                                                                  \
          }];                                                                                                   \
                                                                                                                \
      /* Spin the runloop waiting until the app reports the Dart tests it contains */                           \
      while (!dartTests) {                                                                                      \
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                      \
      }                                                                                                         \
                                                                                                                \
      NSLog(@"Got %lu Dart tests: %@", dartTests.count, dartTests);                                             \
    }                                                                                                           \
                                                                                                                \
    NSMutableArray<NSInvocation *> *invocations = [[NSMutableArray alloc] init];                                \
                                                                                                                \
    /**                                                                                                         \
     * Once Dart tests are available, we:                                                                       \
     *                                                                                                          \
     *  Step 1. Dynamically add test case methods that request execution of an individual Dart test file.       \
     *                                                                                                          \
     *  Step 2. Create invocations to the generated methods and return them                                     \
     */                                                                                                         \
                                                                                                                \
    for (NSDictionary * dartTest in dartTests) {                                                                \
      /* Step 1 - dynamically create test cases */                                                              \
      NSString *dartTestName = dartTest[@"name"];                                                               \
      BOOL skip = [dartTest[@"skip"] boolValue];                                                                \
                                                                                                                \
      IMP implementation = imp_implementationWithBlock(^(id _self) {                                            \
        NSLog(@"Test '%@' starting - uninstalling app", dartTestName);                                          \
        [self uninstallApp];                                                                                    \
        NSLog(@"app uninstallation completed, launching fresh app instance");                                   \
        [[[XCUIApplication alloc] init] launch];                                                                \
        if (skip) {                                                                                             \
          XCTSkip(@"Skip that test \"%@\"", dartTestName);                                                      \
        }                                                                                                       \
                                                                                                                \
        __block ObjCRunDartTestResponse *response = NULL;                                                       \
        __block NSError *error;                                                                                 \
        [appServiceClient                                                                                       \
            runDartTestWithName:dartTestName                                                                    \
                     completion:^(ObjCRunDartTestResponse *_Nullable r, NSError *_Nullable err) {               \
                       NSString *status;                                                                        \
                       if (err != NULL) {                                                                       \
                         error = err;                                                                           \
                         status = @"CRASHED";                                                                   \
                       } else {                                                                                 \
                         response = r;                                                                          \
                         status = response.passed ? @"PASSED" : @"FAILED";                                      \
                       }                                                                                        \
                       NSLog(@"runDartTest(\"%@\"): call finished, test result: %@", dartTestName, status);     \
                     }];                                                                                        \
                                                                                                                \
        /* Wait until Dart test finishes (either fails or passes) or crashes */                                 \
        while (!response && !error) {                                                                           \
          [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                    \
        }                                                                                                       \
        BOOL passed = response ? response.passed : NO;                                                          \
        NSString *details = response ? response.details : @"(no details - app likely crashed)";                 \
        XCTAssertTrue(passed, @"%@", details);                                                                  \
      });                                                                                                       \
      SEL selector = NSSelectorFromString(dartTestName);                                                        \
      class_addMethod(self, selector, implementation, "v@:");                                                   \
                                                                                                                \
      /* Step 2 – create invocations to the dynamically created methods */                                      \
      NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];                        \
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];                        \
      invocation.selector = selector;                                                                           \
                                                                                                                \
      NSLog(@"RunnerUITests.testInvocations(): selectorName = %@, signature: %@", dartTestName, signature);     \
                                                                                                                \
      [invocations addObject:invocation];                                                                       \
    }                                                                                                           \
                                                                                                                \
    return invocations;                                                                                         \
  }                                                                                                             \
                                                                                                                \
  @end
#else
#define PATROL_INTEGRATION_TEST_IOS_RUNNER(__test_class)                                                        \
  @interface __test_class : XCTestCase                                                                          \
  @property(class, strong, nonatomic) NSDictionary *selectedTest;                                               \
  @end                                                                                                          \
                                                                                                                \
  @implementation __test_class                                                                                  \
                                                                                                                \
  static NSDictionary *_selectedTest = nil;                                                                     \
                                                                                                                \
  +(NSDictionary *)selectedTest {                                                                               \
    return _selectedTest;                                                                                       \
  }                                                                                                             \
                                                                                                                \
  +(void)setSelectedTest : (NSDictionary *)newSelectedTest {                                                    \
    if (newSelectedTest != _selectedTest) {                                                                     \
      _selectedTest = [newSelectedTest copy];                                                                   \
    }                                                                                                           \
  }                                                                                                             \
                                                                                                                \
  +(BOOL)instancesRespondToSelector : (SEL)aSelector {                                                          \
    NSString *name = NSStringFromSelector(aSelector);                                                           \
    BOOL skip = NO;                                                                                             \
    NSDictionary *testInfo = @{@"name" : name, @"skip" : @(skip)};                                              \
    [self setSelectedTest:testInfo];                                                                            \
                                                                                                                \
    [self defaultTestSuite]; /* calls testInvocations */                                                        \
    BOOL result = [super instancesRespondToSelector:aSelector];                                                 \
    return true;                                                                                                \
  }                                                                                                             \
                                                                                                                \
  +(NSArray<NSInvocation *> *)testInvocations {                                                                 \
    NSLog(@"Running tests without uninstalling the app");                                                       \
    /* Start native automation server */                                                                        \
    PatrolServer *server = [[PatrolServer alloc] init];                                                         \
                                                                                                                \
    NSError *_Nullable __autoreleasing *_Nullable err = NULL;                                                   \
    [server startAndReturnError:err];                                                                           \
    if (err != NULL) {                                                                                          \
      NSLog(@"patrolServer.start(): failed, err: %@", err);                                                     \
    }                                                                                                           \
                                                                                                                \
    /* Create a client for PatrolAppService, which lets us list and run Dart tests */                           \
    __block ObjCPatrolAppServiceClient *appServiceClient = [[ObjCPatrolAppServiceClient alloc] init];           \
                                                                                                                \
    /* Allow the Local Network permission required by Dart Observatory */                                       \
    XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"]; \
    XCUIElementQuery *systemAlerts = springboard.alerts;                                                        \
    if (systemAlerts.buttons[@"Allow"].exists) {                                                                \
      [systemAlerts.buttons[@"Allow"] tap];                                                                     \
    }                                                                                                           \
                                                                                                                \
    __block NSArray<NSDictionary *> *dartTests = NULL;                                                          \
    if ([self selectedTest] != nil) {                                                                           \
      NSLog(@"selectedTest: %@", [self selectedTest]);                                                          \
      dartTests = [NSArray arrayWithObject:[self selectedTest]];                                                \
    } else {                                                                                                    \
      /* Run the app for the first time to gather Dart tests */                                                 \
      [[[XCUIApplication alloc] init] launch];                                                                  \
      /* Spin the runloop waiting until the app reports that it is ready to report Dart tests */                \
      while (!server.appReady) {                                                                                \
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                      \
      }                                                                                                         \
      [appServiceClient                                                                                         \
          listDartTestsWithCompletion:^(NSArray<NSDictionary *> *_Nullable tests, NSError *_Nullable err) {     \
            if (err != NULL) {                                                                                  \
              NSLog(@"listDartTests(): failed, err: %@", err);                                                  \
            }                                                                                                   \
                                                                                                                \
            dartTests = tests;                                                                                  \
          }];                                                                                                   \
                                                                                                                \
      /* Spin the runloop waiting until the app reports the Dart tests it contains */                           \
      while (!dartTests) {                                                                                      \
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                      \
      }                                                                                                         \
                                                                                                                \
      NSLog(@"Got %lu Dart tests: %@", dartTests.count, dartTests);                                             \
    }                                                                                                           \
                                                                                                                \
    NSMutableArray<NSInvocation *> *invocations = [[NSMutableArray alloc] init];                                \
                                                                                                                \
    /**                                                                                                         \
     * Once Dart tests are available, we:                                                                       \
     *                                                                                                          \
     *  Step 1. Dynamically add test case methods that request execution of an individual Dart test file.       \
     *                                                                                                          \
     *  Step 2. Create invocations to the generated methods and return them                                     \
     */                                                                                                         \
                                                                                                                \
    for (NSDictionary * dartTest in dartTests) {                                                                \
      /* Step 1 - dynamically create test cases */                                                              \
      NSString *dartTestName = dartTest[@"name"];                                                               \
      BOOL skip = [dartTest[@"skip"] boolValue];                                                                \
                                                                                                                \
      IMP implementation = imp_implementationWithBlock(^(id _self) {                                            \
        [[[XCUIApplication alloc] init] launch];                                                                \
        if (skip) {                                                                                             \
          XCTSkip(@"Skip that test \"%@\"", dartTestName);                                                      \
        }                                                                                                       \
                                                                                                                \
        __block ObjCRunDartTestResponse *response = NULL;                                                       \
        __block NSError *error;                                                                                 \
        [appServiceClient                                                                                       \
            runDartTestWithName:dartTestName                                                                    \
                     completion:^(ObjCRunDartTestResponse *_Nullable r, NSError *_Nullable err) {               \
                       NSString *status;                                                                        \
                       if (err != NULL) {                                                                       \
                         error = err;                                                                           \
                         status = @"CRASHED";                                                                   \
                       } else {                                                                                 \
                         response = r;                                                                          \
                         status = response.passed ? @"PASSED" : @"FAILED";                                      \
                       }                                                                                        \
                       NSLog(@"runDartTest(\"%@\"): call finished, test result: %@", dartTestName, status);     \
                     }];                                                                                        \
                                                                                                                \
        /* Wait until Dart test finishes (either fails or passes) or crashes */                                 \
        while (!response && !error) {                                                                           \
          [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                    \
        }                                                                                                       \
        BOOL passed = response ? response.passed : NO;                                                          \
        NSString *details = response ? response.details : @"(no details - app likely crashed)";                 \
        XCTAssertTrue(passed, @"%@", details);                                                                  \
      });                                                                                                       \
      SEL selector = NSSelectorFromString(dartTestName);                                                        \
      class_addMethod(self, selector, implementation, "v@:");                                                   \
                                                                                                                \
      /* Step 2 – create invocations to the dynamically created methods */                                      \
      NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];                        \
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];                        \
      invocation.selector = selector;                                                                           \
                                                                                                                \
      NSLog(@"RunnerUITests.testInvocations(): selectorName = %@, signature: %@", dartTestName, signature);     \
                                                                                                                \
      [invocations addObject:invocation];                                                                       \
    }                                                                                                           \
                                                                                                                \
    return invocations;                                                                                         \
  }                                                                                                             \
                                                                                                                \
  @end
#endif

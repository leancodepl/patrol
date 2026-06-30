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
#define PATROL_INTEGRATION_TEST_IOS_RUNNER(__test_class)                                                        \
  @interface __test_class : XCTestCase                                                                          \
  @property(class, strong, nonatomic, readonly) NSArray *selectedTests;                                         \
  @end                                                                                                          \
                                                                                                                \
  @implementation __test_class                                                                                  \
                                                                                                                \
  static NSMutableArray<NSDictionary *> *_selectedTests = nil;                                                  \
                                                                                                                \
  +(NSArray *)selectedTests {                                                                                   \
    return _selectedTests;                                                                                      \
  }                                                                                                             \
                                                                                                                \
  /* Accumulate the tests selected via -only-testing. XCTest probes one selector                                \
     at a time, so we append (deduplicating by name) instead of overwriting, to                                 \
     support more than one test per run (e.g. a BrowserStack shard). */                                         \
  +(void)addSelectedTest : (NSDictionary *)newSelectedTest {                                                    \
    if (_selectedTests == nil) {                                                                                \
      _selectedTests = [[NSMutableArray alloc] init];                                                           \
    }                                                                                                           \
    for (NSDictionary *existing in _selectedTests) {                                                            \
      if ([existing[@"name"] isEqualToString:newSelectedTest[@"name"]]) {                                       \
        return;                                                                                                 \
      }                                                                                                         \
    }                                                                                                           \
    [_selectedTests addObject:[newSelectedTest copy]];                                                          \
  }                                                                                                             \
                                                                                                                \
  +(BOOL)instancesRespondToSelector : (SEL)aSelector {                                                          \
    NSString *name = NSStringFromSelector(aSelector);                                                           \
    /* Only dart test identifiers reach us as -only-testing targets; they are                                   \
       dotted group paths (e.g. "my_feature.my_test"). XCTest also probes this                                  \
       class for many unrelated selectors (setUp, internal methods, ...), so we                                 \
       must ignore those - otherwise they would be accumulated and "run" as                                     \
       bogus dart tests. */                                                                                     \
    if ([name containsString:@"."]) {                                                                           \
      NSDictionary *testInfo = @{@"name" : name, @"skip" : @(NO)};                                              \
      [self addSelectedTest:testInfo];                                                                          \
      [self defaultTestSuite]; /* calls testInvocations to register the method */                               \
    }                                                                                                           \
    [super instancesRespondToSelector:aSelector];                                                               \
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
    /* Go to home screen (springboard) by pressing home button */                                               \
    [[XCUIDevice sharedDevice] pressButton:XCUIDeviceButtonHome];                                               \
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                          \
                                                                                                                \
    /* Search for app icon on current screen and subsequent screens */                                          \
    BOOL appFound = NO;                                                                                         \
    int maxScreens = 10; /* Maximum number of screens to check */                                               \
    int currentScreen = 0;                                                                                      \
                                                                                                                \
    while (!appFound && currentScreen < maxScreens) {                                                           \
      NSLog(@"Checking screen %d for app: %@", currentScreen + 1, appName);                                     \
                                                                                                                \
      /* Look for app icon on current screen */                                                                 \
      XCUIElement *icon = springboard.icons[appName];                                                           \
                                                                                                                \
      if (icon.exists && icon.isHittable) {                                                                     \
        NSLog(@"App icon found on screen %d: %@", currentScreen + 1, appName);                                  \
        appFound = YES;                                                                                         \
                                                                                                                \
        /* Long press on the app icon to bring up context menu */                                               \
        NSLog(@"Long pressing on app icon: %@", appName);                                                       \
        [icon pressForDuration:1.3];                                                                            \
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];                      \
                                                                                                                \
        /* Perform uninstall based on localized strings */                                                      \
        NSString *removeAppText = [ObjCLocalization getLocalizedStringWithKey:@"remove_app"];                   \
        XCUIElement *removeAppButton = springboard.buttons[removeAppText];                                      \
        if (!removeAppButton.exists) {                                                                          \
          NSLog(@"'%@' button not found", removeAppText);                                                       \
          return;                                                                                               \
        }                                                                                                       \
                                                                                                                \
        [removeAppButton tap];                                                                                  \
                                                                                                                \
        NSString *deleteAppText = [ObjCLocalization getLocalizedStringWithKey:@"delete_app"];                   \
        XCUIElement *deleteAppButton = springboard.alerts.buttons[deleteAppText];                               \
        if (deleteAppButton.exists) {                                                                           \
          [deleteAppButton tap];                                                                                \
          while (deleteAppButton.exists) {                                                                      \
            [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];                  \
          }                                                                                                     \
        }                                                                                                       \
                                                                                                                \
        NSString *deleteText = [ObjCLocalization getLocalizedStringWithKey:@"delete"];                          \
        XCUIElement *deleteButton = springboard.alerts.buttons[deleteText];                                     \
        if (deleteButton.exists) {                                                                              \
          [deleteButton tap];                                                                                   \
          while (deleteButton.exists) {                                                                         \
            [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];                  \
          }                                                                                                     \
        }                                                                                                       \
                                                                                                                \
        NSLog(@"App uninstallation completed");                                                                 \
        return;                                                                                                 \
      }                                                                                                         \
                                                                                                                \
      currentScreen++;                                                                                          \
                                                                                                                \
      /* If app not found on current screen, swipe right to next screen */                                      \
      if (currentScreen < maxScreens) {                                                                         \
        NSLog(@"App not found on screen %d, swiping right to next screen", currentScreen);                      \
        XCUICoordinate *startCoordinate = [springboard coordinateWithNormalizedOffset:CGVectorMake(0.8, 0.5)];  \
        XCUICoordinate *endCoordinate = [springboard coordinateWithNormalizedOffset:CGVectorMake(0.2, 0.5)];    \
        [startCoordinate pressForDuration:0.0                                                                   \
                     thenDragToCoordinate:endCoordinate                                                         \
                             withVelocity:XCUIGestureVelocityFast                                               \
                      thenHoldForDuration:0.0];                                                                 \
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                      \
      }                                                                                                         \
    }                                                                                                           \
                                                                                                                \
    if (!appFound) {                                                                                            \
      NSLog(@"App icon not found on any home screen: %@", appName);                                             \
    }                                                                                                           \
  }                                                                                                             \
  +(void)resetPermissions {                                                                                     \
    NSLog(@"Clearing permissions");                                                                             \
    XCUIApplication *app = [[XCUIApplication alloc] init];                                                      \
    if (@available(iOS 13.4, *)) {                                                                              \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceLocation];                                  \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceContacts];                                  \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceCalendar];                                  \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceReminders];                                 \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourcePhotos];                                    \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceBluetooth];                                 \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceMicrophone];                                \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceCamera];                                    \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceHomeKit];                                   \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceMediaLibrary];                              \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceKeyboardNetwork];                           \
    }                                                                                                           \
    if (@available(iOS 14.0, *)) {                                                                              \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceHealth];                                    \
    }                                                                                                           \
    if (@available(iOS 15.0, *)) {                                                                              \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceUserTracking];                              \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceFocus];                                     \
    }                                                                                                           \
    if (@available(iOS 15.4, *)) {                                                                              \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceLocalNetwork];                              \
    }                                                                                                           \
  }                                                                                                             \
                                                                                                                \
  +(NSArray<NSInvocation *> *)testInvocations {                                                                 \
    /* Start the native automation server and app-service client once and reuse                                 \
       them. XCTest calls +testInvocations once per -only-testing selector (via                                 \
       +instancesRespondToSelector:), so allocating a fresh PatrolServer each                                   \
       time would re-bind the same port and break the app-service connection                                    \
       when more than one test is selected (e.g. a BrowserStack shard with                                      \
       several tests). */                                                                                       \
    static PatrolServer *server = nil;                                                                          \
    static ObjCPatrolAppServiceClient *appServiceClientSingleton = nil;                                         \
    if (server == nil) {                                                                                        \
      server = [[PatrolServer alloc] init];                                                                     \
                                                                                                                \
      NSError *_Nullable __autoreleasing *_Nullable err = NULL;                                                 \
      [server startAndReturnError:err];                                                                         \
      if (err != NULL) {                                                                                        \
        NSLog(@"patrolServer.start(): failed, err: %@", err);                                                   \
      }                                                                                                         \
                                                                                                                \
      /* Create a client for PatrolAppService, which lets us list and run Dart tests */                         \
      appServiceClientSingleton = [[ObjCPatrolAppServiceClient alloc] init];                                    \
    }                                                                                                           \
    __block ObjCPatrolAppServiceClient *appServiceClient = appServiceClientSingleton;                           \
                                                                                                                \
    /* Allow the Local Network permission required by Dart Observatory */                                       \
    XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"]; \
    XCUIElementQuery *systemAlerts = springboard.alerts;                                                        \
    if (systemAlerts.buttons[@"Allow"].exists) {                                                                \
      [systemAlerts.buttons[@"Allow"] tap];                                                                     \
    }                                                                                                           \
                                                                                                                \
    /* Always launch the app and list its Dart tests. This serves two purposes:                                 \
       (1) it yields the full Dart test names (group name + test name) that the                                 \
       app matches in runDartTest - the -only-testing selector only carries the                                 \
       dotted group name; (2) it starts the app's PatrolAppService and warms up                                 \
       the app, so the per-test methods below don't race its startup (which would                               \
       otherwise cause "connection refused"). The result is cached so we list                                   \
       only once even though XCTest calls +testInvocations once per selector. */                                \
    static NSArray<NSDictionary *> *allDartTests = nil;                                                         \
    if (allDartTests == nil) {                                                                                  \
      [[[XCUIApplication alloc] init] launch];                                                                  \
      while (!server.appReady) {                                                                                \
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                      \
      }                                                                                                         \
      __block NSArray<NSDictionary *> *listedTests = NULL;                                                      \
      [appServiceClient                                                                                         \
          listDartTestsWithCompletion:^(NSArray<NSDictionary *> *_Nullable tests, NSError *_Nullable err) {     \
            if (err != NULL) {                                                                                  \
              NSLog(@"listDartTests(): failed, err: %@", err);                                                  \
            }                                                                                                   \
                                                                                                                \
            listedTests = tests;                                                                                \
          }];                                                                                                   \
      while (!listedTests) {                                                                                    \
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                      \
      }                                                                                                         \
      allDartTests = listedTests;                                                                               \
      NSLog(@"Got %lu Dart tests: %@", allDartTests.count, allDartTests);                                       \
    }                                                                                                           \
                                                                                                                \
    /* Build the tests to run. Each entry carries the XCTest "selector" (what                                   \
       -only-testing matches against) and the "name" passed to runDartTest. When                                \
       tests are selected via -only-testing (e.g. a BrowserStack shard), map each                               \
       selected group name to the full Dart test name(s) sharing that group. */                                 \
    NSMutableArray<NSDictionary *> *dartTests = [[NSMutableArray alloc] init];                                  \
    if ([self selectedTests] != nil && [self selectedTests].count > 0) {                                        \
      NSLog(@"selectedTests: %@", [self selectedTests]);                                                        \
      for (NSDictionary *selected in [self selectedTests]) {                                                    \
        NSString *selectorName = selected[@"name"];                                                             \
        NSString *prefix = [selectorName stringByAppendingString:@" "];                                         \
        BOOL matched = NO;                                                                                      \
        for (NSDictionary *fullTest in allDartTests) {                                                          \
          NSString *fullName = fullTest[@"name"];                                                               \
          if ([fullName isEqualToString:selectorName] || [fullName hasPrefix:prefix]) {                         \
            [dartTests addObject:@{                                                                             \
              @"selector" : selectorName,                                                                       \
              @"name" : fullName,                                                                               \
              @"skip" : fullTest[@"skip"] ?: @(NO)                                                              \
            }];                                                                                                 \
            matched = YES;                                                                                      \
          }                                                                                                     \
        }                                                                                                       \
        if (!matched) {                                                                                         \
          /* The -only-testing target has no matching Dart test - e.g. it is                                    \
             excluded on this platform (excludeEnvByTags) but a shard mapping                                   \
             derived from the test file list still references it. Register a                                    \
             skipped placeholder so XCTest can build a valid invocation instead                                 \
             of crashing the whole shard on a nil method signature. */                                          \
          NSLog(@"selected test \"%@\" has no matching Dart test; skipping it", selectorName);                  \
          [dartTests addObject:@{                                                                               \
            @"selector" : selectorName,                                                                         \
            @"name" : selectorName,                                                                             \
            @"skip" : @(YES)                                                                                    \
          }];                                                                                                   \
        }                                                                                                       \
      }                                                                                                         \
    } else {                                                                                                    \
      for (NSDictionary *fullTest in allDartTests) {                                                            \
        [dartTests addObject:@{                                                                                 \
          @"selector" : fullTest[@"name"],                                                                      \
          @"name" : fullTest[@"name"],                                                                          \
          @"skip" : fullTest[@"skip"] ?: @(NO)                                                                  \
        }];                                                                                                     \
      }                                                                                                         \
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
    for (NSUInteger i = 0; i < dartTests.count; i++) {                                                          \
      NSDictionary *dartTest = dartTests[i];                                                                    \
      /* Step 1 - dynamically create test cases */                                                              \
      NSString *dartTestName = dartTest[@"name"];                                                               \
      BOOL skip = [dartTest[@"skip"] boolValue];                                                                \
                                                                                                                \
      IMP implementation = imp_implementationWithBlock(^(id _self) {                                            \
        NSLog(@"RunnerUITests running Dart test: %@", dartTestName);                                            \
                                                                                                                \
        if (CLEAR_PERMISSIONS && i > 0) {                                                                       \
          [self resetPermissions];                                                                              \
          NSLog(@"App permissions cleared");                                                                    \
        }                                                                                                       \
                                                                                                                \
        if (FULL_ISOLATION && i > 0) {                                                                          \
          NSLog(@"Uninstalling app");                                                                           \
          [self uninstallApp];                                                                                  \
          NSLog(@"App uninstallation completed, launching fresh app instance");                                 \
        }                                                                                                       \
                                                                                                                \
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
      SEL selector = NSSelectorFromString(dartTest[@"selector"]);                                               \
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

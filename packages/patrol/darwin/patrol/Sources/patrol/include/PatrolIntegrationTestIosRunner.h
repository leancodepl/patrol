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
#define PATROL_INTEGRATION_TEST_IOS_RUNNER(__test_class)                                                            \
  @interface __test_class : XCTestCase                                                                              \
  @property(class, strong, nonatomic, readonly) NSArray<NSString *> *selectedTestNames;                              \
  @end                                                                                                              \
                                                                                                                    \
  @implementation __test_class                                                                                      \
                                                                                                                    \
  static NSMutableOrderedSet<NSString *> *_selectedTestNames = nil;                                                 \
                                                                                                                    \
  +(NSArray<NSString *> *)selectedTestNames {                                                                       \
    return _selectedTestNames.array;                                                                                \
  }                                                                                                                 \
                                                                                                                    \
  /* Accumulate the tests selected via -only-testing. XCTest probes one selector                                    \
     at a time, so we append instead of overwriting, to                                                             \
     support more than one test per run. */                                                 \
  +(void)addSelectedTestName : (NSString *)name {                                                                   \
    if (_selectedTestNames == nil) {                                                                                \
      _selectedTestNames = [[NSMutableOrderedSet alloc] init];                                                      \
    }                                                                                                               \
    [_selectedTestNames addObject:name];                                                                            \
  }                                                                                                                 \
                                                                                                                    \
  +(NSString *)patrolSelectorForDartTestName : (NSString *)dartTestName {                                           \
    return [dartTestName stringByReplacingOccurrencesOfString:@" " withString:@"+"];                                 \
  }                                                                                                                 \
                                                                                                                    \
  +(BOOL)isPatrolDevelopMode {                                                                                      \
    return [[NSProcessInfo processInfo].environment[@"PATROL_DEVELOP"] isEqualToString:@"1"];                       \
  }                                                                                                                 \
  +(void)launchPatrolAppWithServer : (PatrolServer *)server {                                                       \
    XCUIApplication *app = [[XCUIApplication alloc] init];                                                         \
    app.launchArguments = @[                                                                                        \
      [NSString stringWithFormat:@"--PATROL_TEST_SERVER_PORT=%d", server.boundTestPort],                            \
      [NSString stringWithFormat:@"--PATROL_APP_SERVER_PORT=%d", server.boundAppPort],                                \
    ];                                                                                                              \
    [app launch];                                                                                                   \
  }                                                                                                                 \
                                                                                                                    \
  +(BOOL)instancesRespondToSelector : (SEL)aSelector {                                                              \
    NSString *name = NSStringFromSelector(aSelector);                                                               \
    /* Patrol Dart test selectors contain spaces, or + after Marathon sanitization. */                              \
    if ([name containsString:@" "] || [name containsString:@"+"]) {                                                \
      [self addSelectedTestName:name];                                                                              \
      [self defaultTestSuite]; /* calls testInvocations to register the method */                                   \
    }                                                                                                               \
    [super instancesRespondToSelector:aSelector];                                                                   \
    return true;                                                                                                    \
  }                                                                                                                 \
                                                                                                                    \
  +(void)uninstallApp {                                                                                             \
    XCUIApplication *app = [[XCUIApplication alloc] init];                                                          \
    NSString *appName = app.label;                                                                                  \
    NSLog(@"Uninstalling app: %@", appName);                                                                        \
                                                                                                                    \
    [app terminate];                                                                                                \
                                                                                                                    \
    XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];     \
                                                                                                                    \
    /* Go to home screen (springboard) by pressing home button */                                                   \
    [[XCUIDevice sharedDevice] pressButton:XCUIDeviceButtonHome];                                                   \
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                              \
                                                                                                                    \
    /* Search for app icon on current screen and subsequent screens */                                              \
    BOOL appFound = NO;                                                                                             \
    int maxScreens = 10; /* Maximum number of screens to check */                                                   \
    int currentScreen = 0;                                                                                          \
                                                                                                                    \
    while (!appFound && currentScreen < maxScreens) {                                                               \
      NSLog(@"Checking screen %d for app: %@", currentScreen + 1, appName);                                         \
                                                                                                                    \
      /* Look for app icon on current screen */                                                                     \
      XCUIElement *icon = springboard.icons[appName];                                                               \
                                                                                                                    \
      if (icon.exists && icon.isHittable) {                                                                         \
        NSLog(@"App icon found on screen %d: %@", currentScreen + 1, appName);                                      \
        appFound = YES;                                                                                             \
                                                                                                                    \
        /* Long press on the app icon to bring up context menu */                                                   \
        NSLog(@"Long pressing on app icon: %@", appName);                                                           \
        [icon pressForDuration:1.3];                                                                                \
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];                          \
                                                                                                                    \
        /* Perform uninstall based on localized strings */                                                          \
        NSString *removeAppText = [ObjCLocalization getLocalizedStringWithKey:@"remove_app"];                       \
        XCUIElement *removeAppButton = springboard.buttons[removeAppText];                                          \
        if (!removeAppButton.exists) {                                                                              \
          NSLog(@"'%@' button not found", removeAppText);                                                           \
          return;                                                                                                   \
        }                                                                                                           \
                                                                                                                    \
        [removeAppButton tap];                                                                                      \
                                                                                                                    \
        NSString *deleteAppText = [ObjCLocalization getLocalizedStringWithKey:@"delete_app"];                       \
        XCUIElement *deleteAppButton = springboard.alerts.buttons[deleteAppText];                                   \
        if (deleteAppButton.exists) {                                                                               \
          [deleteAppButton tap];                                                                                    \
          while (deleteAppButton.exists) {                                                                          \
            [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];                      \
          }                                                                                                         \
        }                                                                                                           \
                                                                                                                    \
        NSString *deleteText = [ObjCLocalization getLocalizedStringWithKey:@"delete"];                              \
        XCUIElement *deleteButton = springboard.alerts.buttons[deleteText];                                         \
        if (deleteButton.exists) {                                                                                  \
          [deleteButton tap];                                                                                       \
          while (deleteButton.exists) {                                                                             \
            [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];                      \
          }                                                                                                         \
        }                                                                                                           \
                                                                                                                    \
        NSLog(@"App uninstallation completed");                                                                     \
        return;                                                                                                     \
      }                                                                                                             \
                                                                                                                    \
      currentScreen++;                                                                                              \
                                                                                                                    \
      /* If app not found on current screen, swipe right to next screen */                                          \
      if (currentScreen < maxScreens) {                                                                             \
        NSLog(@"App not found on screen %d, swiping right to next screen", currentScreen);                          \
        XCUICoordinate *startCoordinate = [springboard coordinateWithNormalizedOffset:CGVectorMake(0.8, 0.5)];      \
        XCUICoordinate *endCoordinate = [springboard coordinateWithNormalizedOffset:CGVectorMake(0.2, 0.5)];        \
        [startCoordinate pressForDuration:0.0                                                                       \
                     thenDragToCoordinate:endCoordinate                                                             \
                             withVelocity:XCUIGestureVelocityFast                                                   \
                      thenHoldForDuration:0.0];                                                                     \
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                          \
      }                                                                                                             \
    }                                                                                                               \
                                                                                                                    \
    if (!appFound) {                                                                                                \
      NSLog(@"App icon not found on any home screen: %@", appName);                                                 \
    }                                                                                                               \
  }                                                                                                                 \
  +(void)resetPermissions {                                                                                         \
    NSLog(@"Clearing permissions");                                                                                 \
    XCUIApplication *app = [[XCUIApplication alloc] init];                                                          \
    if (@available(iOS 13.4, *)) {                                                                                  \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceLocation];                                      \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceContacts];                                      \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceCalendar];                                      \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceReminders];                                     \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourcePhotos];                                        \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceBluetooth];                                     \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceMicrophone];                                    \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceCamera];                                        \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceHomeKit];                                       \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceMediaLibrary];                                  \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceKeyboardNetwork];                               \
    }                                                                                                               \
    if (@available(iOS 14.0, *)) {                                                                                  \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceHealth];                                        \
    }                                                                                                               \
    if (@available(iOS 15.0, *)) {                                                                                  \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceUserTracking];                                  \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceFocus];                                         \
    }                                                                                                               \
    if (@available(iOS 15.4, *)) {                                                                                  \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceLocalNetwork];                                  \
    }                                                                                                               \
  }                                                                                                                 \
                                                                                                                    \
  +(NSArray<NSInvocation *> *)patrolDevelopTestInvocations {                                                        \
    static dispatch_once_t onceToken;                                                                               \
    dispatch_once(&onceToken, ^{                                                                                    \
      IMP implementation = imp_implementationWithBlock(^(id _self) {                                                \
        NSLog(@"Patrol develop session: starting native automation server");                                        \
        PatrolServer *server = [[PatrolServer alloc] init];                                                         \
        NSError *err = nil;                                                                                         \
        [server startAndReturnError:&err];                                                                          \
        if (err != nil) {                                                                                           \
          NSLog(@"patrolServer.start(): failed, err: %@", err);                                                     \
        }                                                                                                           \
        XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"]; \
        if (springboard.alerts.buttons[@"Allow"].exists) {                                                          \
          [springboard.alerts.buttons[@"Allow"] tap];                                                               \
        }                                                                                                           \
        [__test_class launchPatrolAppWithServer:server];                                                            \
        NSLog(@"Patrol develop session: keeping XCTest alive for hot restart");                                     \
        while (true) {                                                                                              \
          [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                        \
        }                                                                                                           \
      });                                                                                                           \
      class_addMethod(self, @selector(testPatrolDevelopSession), implementation, "v@:");                            \
    });                                                                                                             \
    SEL selector = @selector(testPatrolDevelopSession);                                                             \
    NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];                              \
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];                              \
    invocation.selector = selector;                                                                                 \
    return @[ invocation ];                                                                                         \
  }                                                                                                                 \
                                                                                                                    \
  +(NSArray<NSInvocation *> *)testInvocations {                                                                     \
    if ([self isPatrolDevelopMode]) {                                                                               \
      return [self patrolDevelopTestInvocations];                                                                   \
    }                                                                                                               \
                                                                                                                    \
    static PatrolServer *server = nil;                                                                              \
    static ObjCPatrolAppServiceClient *appServiceClientSingleton = nil;                                             \
    if (server == nil) {                                                                                            \
      server = [[PatrolServer alloc] init];                                                                         \
                                                                                                                    \
      NSError *err = nil;                                                                                           \
      [server startAndReturnError:&err];                                                                            \
      if (err != nil) {                                                                                             \
        NSLog(@"patrolServer.start(): failed, err: %@", err);                                                       \
      }                                                                                                             \
                                                                                                                    \
      appServiceClientSingleton = [[ObjCPatrolAppServiceClient alloc] initWithPort:server.boundAppPort];             \
    }                                                                                                               \
    __block ObjCPatrolAppServiceClient *appServiceClient = appServiceClientSingleton;                               \
                                                                                                                    \
    /* Allow the Local Network permission required by Dart Observatory */                                           \
    XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];     \
    XCUIElementQuery *systemAlerts = springboard.alerts;                                                            \
    if (systemAlerts.buttons[@"Allow"].exists) {                                                                    \
      [systemAlerts.buttons[@"Allow"] tap];                                                                         \
    }                                                                                                               \
                                                                                                                    \
    static NSArray<NSDictionary *> *allDartTests = nil;                                                              \
    if (allDartTests == nil) {                                                                                      \
      [__test_class launchPatrolAppWithServer:server];                                                              \
      while (!server.appReady) {                                                                                    \
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                          \
      }                                                                                                             \
      __block NSArray<NSDictionary *> *listedTests = NULL;                                                          \
      [appServiceClient                                                                                             \
          listDartTestsWithCompletion:^(NSArray<NSDictionary *> *_Nullable tests, NSError *_Nullable err) {         \
            if (err != NULL) {                                                                                      \
              NSLog(@"listDartTests(): failed, err: %@", err);                                                      \
            }                                                                                                       \
            listedTests = tests;                                                                                    \
          }];                                                                                                       \
      while (!listedTests) {                                                                                        \
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                          \
      }                                                                                                             \
      allDartTests = listedTests;                                                                                   \
      NSLog(@"Got %lu Dart tests: %@", allDartTests.count, allDartTests);                                           \
    }                                                                                                               \
                                                                                                                    \
    NSMutableArray<NSDictionary *> *dartTests = [[NSMutableArray alloc] init];                                        \
    if ([self selectedTestNames].count > 0) {                                                                       \
      NSLog(@"selectedTestNames: %@", [self selectedTestNames]);                                                    \
      for (NSString *selectorName in [self selectedTestNames]) {                                                    \
        BOOL matched = NO;                                                                                          \
        for (NSDictionary *fullTest in allDartTests) {                                                              \
          NSString *fullName = fullTest[@"name"];                                                                   \
          NSString *fullSelector = [self patrolSelectorForDartTestName:fullName];                                   \
          if ([fullSelector isEqualToString:selectorName] || [fullName isEqualToString:selectorName]) {             \
            [dartTests addObject:@{                                                                                 \
              @"selector" : fullSelector,                                                                           \
              @"name" : fullName,                                                                                   \
              @"skip" : fullTest[@"skip"] ?: @(NO)                                                                  \
            }];                                                                                                     \
            matched = YES;                                                                                          \
          }                                                                                                         \
        }                                                                                                           \
        if (!matched) {                                                                                             \
          NSLog(@"selected test \"%@\" has no matching Dart test; skipping it", selectorName);                      \
          [dartTests addObject:@{                                                                                   \
            @"selector" : selectorName,                                                                             \
            @"name" : selectorName,                                                                                 \
            @"skip" : @(YES)                                                                                        \
          }];                                                                                                       \
        }                                                                                                           \
      }                                                                                                             \
    } else {                                                                                                        \
      for (NSDictionary *fullTest in allDartTests) {                                                                \
        [dartTests addObject:@{                                                                                     \
          @"selector" : [self patrolSelectorForDartTestName:fullTest[@"name"]],                                     \
          @"name" : fullTest[@"name"],                                                                              \
          @"skip" : fullTest[@"skip"] ?: @(NO)                                                                      \
        }];                                                                                                         \
      }                                                                                                             \
    }                                                                                                               \
                                                                                                                    \
    NSMutableArray<NSInvocation *> *invocations = [[NSMutableArray alloc] init];                                    \
                                                                                                                    \
    for (NSUInteger i = 0; i < dartTests.count; i++) {                                                              \
      NSDictionary *dartTest = dartTests[i];                                                                        \
      NSString *dartTestName = dartTest[@"name"];                                                                   \
      NSString *selectorName = dartTest[@"selector"];                                                               \
      BOOL skip = [dartTest[@"skip"] boolValue];                                                                    \
                                                                                                                    \
      IMP implementation = imp_implementationWithBlock(^(id _self) {                                            \
        NSLog(@"RunnerUITests running Dart test: %@", dartTestName);                                                \
                                                                                                                    \
        if (CLEAR_PERMISSIONS && i > 0) {                                                                           \
          [self resetPermissions];                                                                                  \
          NSLog(@"App permissions cleared");                                                                        \
        }                                                                                                           \
                                                                                                                    \
        if (FULL_ISOLATION && i > 0) {                                                                              \
          NSLog(@"Uninstalling app");                                                                               \
          [self uninstallApp];                                                                                      \
          NSLog(@"App uninstallation completed, launching fresh app instance");                                     \
        }                                                                                                           \
                                                                                                                    \
        [__test_class launchPatrolAppWithServer:server];                                                              \
        if (skip) {                                                                                                 \
          XCTSkip(@"Skip that test \"%@\"", dartTestName);                                                          \
        }                                                                                                           \
                                                                                                                    \
        __block ObjCRunDartTestResponse *response = NULL;                                                           \
        __block NSError *error;                                                                                     \
        [appServiceClient                                                                                           \
            runDartTestWithName:dartTestName                                                                        \
                     completion:^(ObjCRunDartTestResponse *_Nullable r, NSError *_Nullable err) {                   \
                       NSString *status;                                                                            \
                       if (err != NULL) {                                                                           \
                         error = err;                                                                               \
                         status = @"CRASHED";                                                                       \
                       } else {                                                                                     \
                         response = r;                                                                              \
                         status = response.passed ? @"PASSED" : @"FAILED";                                          \
                       }                                                                                            \
                       NSLog(@"runDartTest(\"%@\"): call finished, test result: %@", dartTestName, status);         \
                     }];                                                                                            \
                                                                                                                    \
        while (!response && !error) {                                                                               \
          [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                        \
        }                                                                                                           \
        BOOL passed = response ? response.passed : NO;                                                              \
        NSString *details = response ? response.details : @"(no details - app likely crashed)";                     \
        XCTAssertTrue(passed, @"%@", details);                                                                      \
      });                                                                                                           \
      SEL selector = NSSelectorFromString(selectorName);                                                            \
      class_addMethod(self, selector, implementation, "v@:");                                                       \
                                                                                                                    \
      NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];                            \
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];                            \
      invocation.selector = selector;                                                                               \
                                                                                                                    \
      NSLog(@"RunnerUITests.testInvocations(): selectorName = %@, dartTestName = %@, signature: %@",                \
            selectorName, dartTestName, signature);                                                                 \
                                                                                                                    \
      [invocations addObject:invocation];                                                                           \
    }                                                                                                               \
                                                                                                                    \
    return invocations;                                                                                             \
  }                                                                                                                 \
                                                                                                                    \
  @end

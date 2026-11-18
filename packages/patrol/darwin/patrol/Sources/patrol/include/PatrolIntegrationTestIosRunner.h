// This file is a one giant macro to make the setup as easy as possible for the developer.
// To edit it:
//  1. Remove the trailing backslashes: $ sed 's/\\$//' PatrolIntegrationTestIosRunner.h
//  2. Paste its contents into the RunnerUITests.m in the RunnerUITests target
//  3. Make the changes, make sure it works
//  4. Re-add trailing backslashes: $ sed 's/$/\\/' PatrolIntegrationTestIosRunner.h
//  5. Copy the contents from RunnerUITests.m back here
//  6. Go back to using a macro in RunnerUITests.m

// One runner for both test discovery modes. With build-time discovery, the
// generated PatrolGeneratedTests.inc (#included right after this macro) declares
// one subclass per Dart test file with real test_ methods, and this class runs
// none. Without it, this class asks the app for its Dart tests at runtime and
// registers one dynamic method per test, reported as a native XCTest result.
#define PATROL_INTEGRATION_TEST_IOS_RUNNER(__test_class)                                                            \
  @interface __test_class : XCTestCase                                                                              \
  @property(class, strong, nonatomic, readonly) NSArray<NSString *> *selectedTestNames;                             \
  @end                                                                                                              \
                                                                                                                    \
  @implementation __test_class                                                                                      \
                                                                                                                    \
  static NSMutableOrderedSet<NSString *> *_selectedTestNames = nil;                                                 \
  static PatrolServer *_patrolServer = nil;                                                                         \
  static ObjCPatrolAppServiceClient *_patrolAppServiceClient = nil;                                                 \
  static int _patrolGeneratedTestIndex = 0;                                                                         \
                                                                                                                    \
  +(NSArray<NSString *> *)selectedTestNames {                                                                       \
    return _selectedTestNames.array;                                                                                \
  }                                                                                                                 \
                                                                                                                    \
  /* Accumulate the tests selected via -only-testing. XCTest probes one selector                                    \
     at a time, so we append instead of overwriting, to                                                             \
     support more than one test per run. */                                                                         \
  +(void)addSelectedTestName : (NSString *)name {                                                                   \
    if (_selectedTestNames == nil) {                                                                                \
      _selectedTestNames = [[NSMutableOrderedSet alloc] init];                                                      \
    }                                                                                                               \
    [_selectedTestNames addObject:name];                                                                            \
  }                                                                                                                 \
                                                                                                                    \
  +(NSString *)patrolSelectorForDartTestName : (NSString *)dartTestName {                                           \
    NSString *escaped = [dartTestName stringByReplacingOccurrencesOfString:@"+" withString:@"__PLUS__"];            \
    return [escaped stringByReplacingOccurrencesOfString:@" " withString:@"+"];                                     \
  }                                                                                                                 \
                                                                                                                    \
  +(BOOL)isPatrolDevelopMode {                                                                                      \
    return [[NSProcessInfo processInfo].environment[@"PATROL_DEVELOP"] isEqualToString:@"1"];                       \
  }                                                                                                                 \
                                                                                                                    \
  /* True when build-time discovery generated test classes (PatrolGeneratedTests.inc)                               \
     that subclass this one. They then own the tests, and this class runs none. */                                  \
  +(BOOL)patrolHasGeneratedTests {                                                                                  \
    static BOOL hasGeneratedTests = NO;                                                                             \
    static dispatch_once_t onceToken;                                                                               \
    dispatch_once(&onceToken, ^{                                                                                    \
      unsigned int classCount = 0;                                                                                  \
      Class *classes = objc_copyClassList(&classCount);                                                             \
      for (unsigned int i = 0; i < classCount; i++) {                                                               \
        if (class_getSuperclass(classes[i]) == [__test_class class]) {                                              \
          hasGeneratedTests = YES;                                                                                  \
          break;                                                                                                    \
        }                                                                                                           \
      }                                                                                                             \
      free(classes);                                                                                                \
    });                                                                                                             \
    return hasGeneratedTests;                                                                                       \
  }                                                                                                                 \
                                                                                                                    \
  +(BOOL)patrolStartServerIfNeeded {                                                                                \
    if (_patrolServer != nil) {                                                                                     \
      return YES;                                                                                                   \
    }                                                                                                               \
    PatrolServer *server = [[PatrolServer alloc] init];                                                             \
    NSError *err = nil;                                                                                             \
    [server startAndReturnError:&err];                                                                              \
    if (err != nil) {                                                                                               \
      NSLog(@"patrolServer.start(): failed, err: %@", err);                                                         \
      XCTFail(@"patrolServer.start() failed: %@", err);                                                             \
      return NO;                                                                                                    \
    }                                                                                                               \
    _patrolServer = server;                                                                                         \
    _patrolAppServiceClient = [[ObjCPatrolAppServiceClient alloc] initWithPort:server.boundAppPort];                \
    return YES;                                                                                                     \
  }                                                                                                                 \
                                                                                                                    \
  /* Allow the Local Network permission required by Dart Observatory */                                             \
  +(void)patrolAllowLocalNetwork {                                                                                  \
    XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];     \
    if (springboard.alerts.buttons[@"Allow"].exists) {                                                              \
      [springboard.alerts.buttons[@"Allow"] tap];                                                                   \
    }                                                                                                               \
  }                                                                                                                 \
                                                                                                                    \
  +(void)launchPatrolAppWithServer : (PatrolServer *)server {                                                       \
    server.appReady = NO;                                                                                           \
    XCUIApplication *app = [[XCUIApplication alloc] init];                                                          \
    NSMutableDictionary<NSString *, NSString *> *environment =                                                      \
        [app.launchEnvironment mutableCopy] ?: [NSMutableDictionary dictionary];                                    \
    environment[@"PATROL_TEST_SERVER_PORT"] = [NSString stringWithFormat:@"%ld", (long)server.boundTestPort];       \
    environment[@"PATROL_APP_SERVER_PORT"] = [NSString stringWithFormat:@"%ld", (long)server.boundAppPort];         \
    environment[@"PATROL_HOST_SERVER_PORT"] = NSProcessInfo.processInfo.environment[@"PATROL_HOST_PORT"];           \
    app.launchEnvironment = environment;                                                                            \
    [app launch];                                                                                                   \
  }                                                                                                                 \
  +(BOOL)waitForPatrolAppReadyWithServer : (PatrolServer *)server timeout : (NSTimeInterval)timeout {               \
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:timeout];                                               \
    while (!server.appReady && deadline.timeIntervalSinceNow > 0) {                                                 \
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                            \
    }                                                                                                               \
    return server.appReady;                                                                                         \
  }                                                                                                                 \
                                                                                                                    \
  +(BOOL)instancesRespondToSelector : (SEL)aSelector {                                                              \
    if (self != [__test_class class] || (![self isPatrolDevelopMode] && [self patrolHasGeneratedTests])) {          \
      return [super instancesRespondToSelector:aSelector];                                                          \
    }                                                                                                               \
    NSString *name = NSStringFromSelector(aSelector);                                                               \
    /* Accumulate Marathon/dart selectors (spaces, '+', or escaped '+'). */                                         \
    if ([name containsString:@" "] || [name containsString:@"+"] || [name containsString:@"__PLUS__"]) {            \
      [self addSelectedTestName:name];                                                                              \
    }                                                                                                               \
    /* Always register dynamic methods - including develop keep-alive. */                                           \
    [self defaultTestSuite];                                                                                        \
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
        if (![__test_class patrolStartServerIfNeeded]) {                                                            \
          return;                                                                                                   \
        }                                                                                                           \
        [__test_class patrolAllowLocalNetwork];                                                                     \
        [__test_class launchPatrolAppWithServer:_patrolServer];                                                     \
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
    /* A class generated by build-time discovery: XCTest finds its test_ methods. */                                \
    if (self != [__test_class class]) {                                                                             \
      return [self isPatrolDevelopMode] ? @[] : [super testInvocations];                                            \
    }                                                                                                               \
                                                                                                                    \
    if ([self isPatrolDevelopMode]) {                                                                               \
      return [self patrolDevelopTestInvocations];                                                                   \
    }                                                                                                               \
                                                                                                                    \
    if ([self patrolHasGeneratedTests]) {                                                                           \
      return @[];                                                                                                   \
    }                                                                                                               \
                                                                                                                    \
    /* Runtime discovery: launch the app once and ask it for its Dart tests. */                                     \
    if (![self patrolStartServerIfNeeded]) {                                                                        \
      return @[];                                                                                                   \
    }                                                                                                               \
    PatrolServer *server = _patrolServer;                                                                           \
    __block ObjCPatrolAppServiceClient *appServiceClient = _patrolAppServiceClient;                                 \
                                                                                                                    \
    [self patrolAllowLocalNetwork];                                                                                 \
                                                                                                                    \
    static NSArray<NSDictionary *> *allDartTests = nil;                                                             \
    if (allDartTests == nil) {                                                                                      \
      [__test_class launchPatrolAppWithServer:server];                                                              \
      if (![__test_class waitForPatrolAppReadyWithServer:server timeout:60.0]) {                                    \
        XCTFail(@"Patrol app did not become ready on port %ld", (long)server.boundAppPort);                         \
        return @[];                                                                                                 \
      }                                                                                                             \
      __block NSArray<NSDictionary *> *listedTests = NULL;                                                          \
      __block NSError *listError = nil;                                                                             \
      __block BOOL listCompleted = NO;                                                                              \
      [appServiceClient                                                                                             \
          listDartTestsWithCompletion:^(NSArray<NSDictionary *> *_Nullable tests, NSError *_Nullable err) {         \
            if (err != NULL) {                                                                                      \
              NSLog(@"listDartTests(): failed, err: %@", err);                                                      \
              listError = err;                                                                                      \
            }                                                                                                       \
            listedTests = tests;                                                                                    \
            listCompleted = YES;                                                                                    \
          }];                                                                                                       \
      while (!listCompleted) {                                                                                      \
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                          \
      }                                                                                                             \
      if (listError != nil || listedTests == nil) {                                                                 \
        XCTFail(@"listDartTests() failed: %@", listError);                                                          \
        return @[];                                                                                                 \
      }                                                                                                             \
      allDartTests = listedTests;                                                                                   \
      NSLog(@"Got %lu Dart tests: %@", allDartTests.count, allDartTests);                                           \
    }                                                                                                               \
                                                                                                                    \
    NSMutableArray<NSDictionary *> *dartTests = [[NSMutableArray alloc] init];                                      \
    if ([self selectedTestNames].count > 0) {                                                                       \
      NSLog(@"selectedTestNames: %@", [self selectedTestNames]);                                                    \
      for (NSString * selectorName in [self selectedTestNames]) {                                                   \
        BOOL matched = NO;                                                                                          \
        for (NSDictionary * fullTest in allDartTests) {                                                             \
          NSString *fullName = fullTest[@"name"];                                                                   \
          NSString *fullSelector = [self patrolSelectorForDartTestName:fullName];                                   \
          if ([fullSelector isEqualToString:selectorName] || [fullName isEqualToString:selectorName]) {             \
            [dartTests                                                                                              \
                addObject:@{@"selector" : fullSelector, @"name" : fullName, @"skip" : fullTest[@"skip"] ?: @(NO)}]; \
            matched = YES;                                                                                          \
          }                                                                                                         \
        }                                                                                                           \
        if (!matched) {                                                                                             \
          NSLog(@"selected test \"%@\" has no matching Dart test; skipping it", selectorName);                      \
          [dartTests addObject:@{@"selector" : selectorName, @"name" : selectorName, @"skip" : @(YES)}];            \
        }                                                                                                           \
      }                                                                                                             \
    } else {                                                                                                        \
      for (NSDictionary * fullTest in allDartTests) {                                                               \
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
      IMP implementation = imp_implementationWithBlock(^(id _self) {                                                \
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
        if (skip) {                                                                                                 \
          XCTSkip(@"Skip that test \"%@\"", dartTestName);                                                          \
        }                                                                                                           \
                                                                                                                    \
        [__test_class launchPatrolAppWithServer:server];                                                            \
        BOOL appReady = [__test_class waitForPatrolAppReadyWithServer:server timeout:60.0];                         \
        XCTAssertTrue(appReady, @"Patrol app did not become ready on port %ld", (long)server.boundAppPort);         \
        if (!appReady) {                                                                                            \
          return;                                                                                                   \
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
        if (response && response.skipped) {                                                                         \
          XCTSkip(@"%@", details);                                                                                  \
        }                                                                                                           \
        XCTAssertTrue(passed, @"%@", details);                                                                      \
      });                                                                                                           \
      SEL selector = NSSelectorFromString(selectorName);                                                            \
      class_addMethod(self, selector, implementation, "v@:");                                                       \
                                                                                                                    \
      NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];                            \
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];                            \
      invocation.selector = selector;                                                                               \
                                                                                                                    \
      NSLog(@"RunnerUITests.testInvocations(): selectorName = %@, dartTestName = %@, signature: %@", selectorName,  \
            dartTestName, signature);                                                                               \
                                                                                                                    \
      [invocations addObject:invocation];                                                                           \
    }                                                                                                               \
                                                                                                                    \
    return invocations;                                                                                             \
  }                                                                                                                 \
                                                                                                                    \
  /* Called by the test_ methods generated by build-time discovery. */                                              \
  -(void)patrolExecuteDartTest : (NSString *)dartTestName skip : (BOOL)skip {                                       \
    NSLog(@"RunnerUITests running Dart test: %@", dartTestName);                                                    \
    if (![__test_class patrolStartServerIfNeeded]) {                                                                \
      return;                                                                                                       \
    }                                                                                                               \
    if (_patrolGeneratedTestIndex == 0) {                                                                           \
      [__test_class patrolAllowLocalNetwork];                                                                       \
    }                                                                                                               \
    if (CLEAR_PERMISSIONS && _patrolGeneratedTestIndex > 0) {                                                       \
      [__test_class resetPermissions];                                                                              \
      NSLog(@"App permissions cleared");                                                                            \
    }                                                                                                               \
    if (FULL_ISOLATION && _patrolGeneratedTestIndex > 0) {                                                          \
      NSLog(@"Uninstalling app");                                                                                   \
      [__test_class uninstallApp];                                                                                  \
      NSLog(@"App uninstallation completed, launching fresh app instance");                                         \
    }                                                                                                               \
    _patrolGeneratedTestIndex++;                                                                                    \
                                                                                                                    \
    [__test_class launchPatrolAppWithServer:_patrolServer];                                                         \
    if (skip) {                                                                                                     \
      XCTSkip(@"Skip that test \"%@\"", dartTestName);                                                              \
    }                                                                                                               \
                                                                                                                    \
    if (![__test_class waitForPatrolAppReadyWithServer:_patrolServer timeout:180.0]) {                              \
      XCTFail(@"App did not report PatrolAppService readiness on port %ld", (long)_patrolServer.boundAppPort);      \
      return;                                                                                                       \
    }                                                                                                               \
                                                                                                                    \
    __block ObjCRunDartTestResponse *response = NULL;                                                               \
    __block NSError *error;                                                                                         \
    [_patrolAppServiceClient runDartTestWithName:dartTestName                                                       \
                                      completion:^(ObjCRunDartTestResponse *_Nullable r, NSError *_Nullable e) {    \
                                        if (e != NULL) {                                                            \
                                          error = e;                                                                \
                                        } else {                                                                    \
                                          response = r;                                                             \
                                        }                                                                           \
                                      }];                                                                           \
                                                                                                                    \
    while (!response && !error) {                                                                                   \
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                            \
    }                                                                                                               \
    BOOL passed = response ? response.passed : NO;                                                                  \
    NSString *details = response ? response.details : @"(no details - app likely crashed)";                         \
    if (response && response.skipped) {                                                                             \
      XCTSkip(@"%@", details);                                                                                      \
    }                                                                                                               \
    XCTAssertTrue(passed, @"%@", details);                                                                          \
  }                                                                                                                 \
                                                                                                                    \
  @end

// Deprecated: the runner above handles build-time discovery too. Kept so that
// RunnerUITests.m files set up for build-time discovery in Patrol 4.x still compile.
#define PATROL_INTEGRATION_TEST_IOS_RUNNER_STATIC_BASE(__test_class) PATROL_INTEGRATION_TEST_IOS_RUNNER(__test_class)

// This file is a one giant macro to make the setup as easy as possible for the developer.
// To edit it:
//  1. Remove the trailing backslashes: $ sed 's/\\$//' PatrolIntegrationTestIosRunner.h
//  2. Paste its contents into the RunnerUITests.m in the RunnerUITests target
//  3. Make the changes, make sure it works
//  4. Re-add trailing backslashes: $ sed 's/$/\\/' PatrolIntegrationTestIosRunner.h
//  5. Copy the contents from RunnerUITests.m back here
//  6. Go back to using a macro in RunnerUITests.m

#import <objc/runtime.h>

// XCTest waits until an app is idle before it reads or acts on its elements.
// While Springboard deletes an app, its icons animate and Springboard never
// becomes idle, so every query waits for XCTest's app state timeout (a minute
// or more). Appium's WebDriverAgent and Maestro turn this wait off by replacing
// the private -[XCUIApplicationProcess waitForQuiescenceIncludingAnimationsIdle:]
// (and its newer variant with isPreEvent:). Patrol does the same, but only while
// it deletes the app.

static inline BOOL *PatrolSkipsQuiescenceWait(void) {
  static BOOL skips = NO;
  return &skips;
}

static inline void PatrolReplaceQuiescenceWait(void) {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class processClass = NSClassFromString(@"XCUIApplicationProcess");
    if (processClass == nil) {
      NSLog(@"Patrol: XCUIApplicationProcess not found, cannot skip waiting for idle apps");
      return;
    }

    SEL legacy = NSSelectorFromString(@"waitForQuiescenceIncludingAnimationsIdle:");
    Method legacyMethod = class_getInstanceMethod(processClass, legacy);
    if (legacyMethod != NULL) {
      void (*original)(id, SEL, BOOL) = (void (*)(id, SEL, BOOL))method_getImplementation(legacyMethod);
      method_setImplementation(legacyMethod, imp_implementationWithBlock(^(id process, BOOL animationsIdle) {
                                 if (*PatrolSkipsQuiescenceWait()) {
                                   return;
                                 }
                                 original(process, legacy, animationsIdle);
                               }));
    }

    SEL preEvent = NSSelectorFromString(@"waitForQuiescenceIncludingAnimationsIdle:isPreEvent:");
    Method preEventMethod = class_getInstanceMethod(processClass, preEvent);
    if (preEventMethod != NULL) {
      void (*original)(id, SEL, BOOL, BOOL) =
          (void (*)(id, SEL, BOOL, BOOL))method_getImplementation(preEventMethod);
      method_setImplementation(preEventMethod,
                               imp_implementationWithBlock(^(id process, BOOL animationsIdle, BOOL isPreEvent) {
                                 if (*PatrolSkipsQuiescenceWait()) {
                                   return;
                                 }
                                 original(process, preEvent, animationsIdle, isPreEvent);
                               }));
    }

    if (legacyMethod == NULL && preEventMethod == NULL) {
      NSLog(@"Patrol: this XCTest has no quiescence wait to skip");
    }
  });
}

// Runs [block] without waiting for apps to become idle.
static inline void PatrolWithoutQuiescenceWait(void (^block)(void)) {
  PatrolReplaceQuiescenceWait();
  BOOL previous = *PatrolSkipsQuiescenceWait();
  *PatrolSkipsQuiescenceWait() = YES;
  @try {
    block();
  } @finally {
    *PatrolSkipsQuiescenceWait() = previous;
  }
}

// Class methods shared by the iOS runners. They delete the app under test through Springboard.
// On the iOS Simulator, the next launch of the app installs it again.
#define PATROL_SPRINGBOARD_UNINSTALL_METHODS                                                                           \
  +(BOOL)uninstallApp {                                                                                                \
    XCUIApplication *app = [[XCUIApplication alloc] init];                                                             \
    NSString *appName = app.label;                                                                                     \
    NSLog(@"Uninstalling app: %@", appName);                                                                           \
                                                                                                                       \
    [app terminate];                                                                                                   \
                                                                                                                       \
    XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];        \
                                                                                                                       \
    /* Go to home screen (springboard) by pressing home button */                                                      \
    [[XCUIDevice sharedDevice] pressButton:XCUIDeviceButtonHome];                                                      \
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                                 \
                                                                                                                       \
    /* Search for app icon on current screen and subsequent screens */                                                 \
    int maxScreens = 10; /* Maximum number of screens to check */                                                      \
    for (int currentScreen = 0; currentScreen < maxScreens; currentScreen++) {                                         \
      NSLog(@"Checking screen %d for app: %@", currentScreen + 1, appName);                                            \
                                                                                                                       \
      XCUIElement *icon = springboard.icons[appName];                                                                  \
      if (icon.exists && icon.isHittable) {                                                                            \
        NSLog(@"App icon found on screen %d: %@", currentScreen + 1, appName);                                         \
                                                                                                                       \
        /* From the long press on, Springboard animates and does not become idle, so XCTest would wait                 \
           a minute for it after every step. Wait for each element instead. */                                         \
        __block BOOL deleted = NO;                                                                                     \
        PatrolWithoutQuiescenceWait(^{                                                                                 \
          [icon pressForDuration:1.3];                                                                                 \
          deleted = [self deleteAppIcon:icon named:appName inSpringboard:springboard];                                 \
        });                                                                                                            \
        return deleted;                                                                                                \
      }                                                                                                                \
                                                                                                                       \
      /* If app not found on current screen, swipe right to next screen */                                             \
      if (currentScreen + 1 < maxScreens) {                                                                            \
        NSLog(@"App not found on screen %d, swiping right to next screen", currentScreen + 1);                         \
        XCUICoordinate *startCoordinate = [springboard coordinateWithNormalizedOffset:CGVectorMake(0.8, 0.5)];         \
        XCUICoordinate *endCoordinate = [springboard coordinateWithNormalizedOffset:CGVectorMake(0.2, 0.5)];           \
        [startCoordinate pressForDuration:0.0                                                                          \
                     thenDragToCoordinate:endCoordinate                                                                \
                             withVelocity:XCUIGestureVelocityFast                                                      \
                      thenHoldForDuration:0.0];                                                                        \
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                             \
      }                                                                                                                \
    }                                                                                                                  \
                                                                                                                       \
    NSLog(@"App icon not found on any home screen: %@", appName);                                                      \
    return NO;                                                                                                         \
  }                                                                                                                    \
                                                                                                                       \
  /* Confirms the deletion from the icon's context menu and waits until the icon is gone. */                           \
  +(BOOL)deleteAppIcon : (XCUIElement *)icon                                                                           \
                  named : (NSString *)appName                                                                          \
          inSpringboard : (XCUIApplication *)springboard {                                                             \
    NSString *removeAppText = [ObjCLocalization getLocalizedStringWithKey:@"remove_app"];                              \
    XCUIElement *removeAppButton = springboard.buttons[removeAppText];                                                 \
    if (![removeAppButton waitForExistenceWithTimeout:5.0]) {                                                          \
      NSLog(@"'%@' button not found", removeAppText);                                                                  \
      return NO;                                                                                                       \
    }                                                                                                                  \
    [removeAppButton tap];                                                                                             \
                                                                                                                       \
    /* Depending on the iOS version, one or both of these alerts ask to confirm. */                                    \
    for (NSString *key in @[ @"delete_app", @"delete" ]) {                                                             \
      NSString *text = [ObjCLocalization getLocalizedStringWithKey:key];                                               \
      XCUIElement *button = springboard.alerts.buttons[text];                                                          \
      if (![button waitForExistenceWithTimeout:2.0]) {                                                                 \
        continue;                                                                                                      \
      }                                                                                                                \
      [button tap];                                                                                                    \
      if (![self waitUntilGone:button timeout:5.0]) {                                                                  \
        NSLog(@"'%@' alert did not close", text);                                                                      \
        return NO;                                                                                                     \
      }                                                                                                                \
    }                                                                                                                  \
                                                                                                                       \
    if (![self waitUntilGone:icon timeout:10.0]) {                                                                     \
      NSLog(@"App icon is still on the home screen after deleting it: %@", appName);                                   \
      return NO;                                                                                                       \
    }                                                                                                                  \
    NSLog(@"App uninstallation completed");                                                                            \
    return YES;                                                                                                        \
  }                                                                                                                    \
                                                                                                                       \
  +(BOOL)waitUntilGone : (XCUIElement *)element timeout : (NSTimeInterval)timeout {                                    \
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:timeout];                                                  \
    while (element.exists) {                                                                                           \
      if (deadline.timeIntervalSinceNow <= 0) {                                                                        \
        return NO;                                                                                                     \
      }                                                                                                                \
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];                               \
    }                                                                                                                  \
    return YES;                                                                                                        \
  }

// For every Flutter dart test, dynamically generate an Objective-C method mirroring the test results
// so it is reported as a native XCTest run result.
#define PATROL_INTEGRATION_TEST_IOS_RUNNER(__test_class)                                                            \
  @interface __test_class : XCTestCase                                                                              \
  @property(class, strong, nonatomic, readonly) NSArray<NSString *> *selectedTestNames;                             \
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
  +(void)launchPatrolAppWithServer : (PatrolServer *)server {                                                       \
    [self launchPatrolAppWithServer:server launchURL:nil];                                                          \
  }                                                                                                                 \
  +(void)launchPatrolAppWithServer : (PatrolServer *)server launchURL : (NSString *)launchURL {                     \
    server.appReady = NO;                                                                                           \
    XCUIApplication *app = [[XCUIApplication alloc] init];                                                          \
    NSMutableDictionary<NSString *, NSString *> *environment =                                                      \
        [app.launchEnvironment mutableCopy] ?: [NSMutableDictionary dictionary];                                    \
    environment[@"PATROL_TEST_SERVER_PORT"] = [NSString stringWithFormat:@"%ld", (long)server.boundTestPort];       \
    environment[@"PATROL_APP_SERVER_PORT"] = [NSString stringWithFormat:@"%ld", (long)server.boundAppPort];         \
    app.launchEnvironment = environment;                                                                            \
    if (launchURL == nil) {                                                                                         \
      [app launch];                                                                                                 \
    } else {                                                                                                        \
      NSURL *url = [NSURL URLWithString:launchURL];                                                                 \
      XCTAssertNotNil(url, @"Invalid phase launch URL: %@", launchURL);                                             \
      if (url == nil) {                                                                                             \
        return;                                                                                                     \
      }                                                                                                             \
      /* iOS 16.4+: openURL cold-starts through the link. Older iOS must launch  \
         first, then openURL — first paint is a normal start, not the deep link. */ \
      if (@available(iOS 16.4, *)) {                                                                                \
        [app openURL:url];                                                                                          \
      } else {                                                                                                      \
        [app launch];                                                                                               \
        [[XCUIDevice sharedDevice].system openURL:url];                                                             \
      }                                                                                                             \
    }                                                                                                               \
  }                                                                                                                 \
  +(BOOL)waitForPatrolAppReadyWithServer : (PatrolServer *)server {                                                 \
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:60.0];                                                  \
    while (!server.appReady && deadline.timeIntervalSinceNow > 0) {                                                 \
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                            \
    }                                                                                                               \
    return server.appReady;                                                                                         \
  }                                                                                                                 \
                                                                                                                    \
  +(BOOL)instancesRespondToSelector : (SEL)aSelector {                                                              \
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
  PATROL_SPRINGBOARD_UNINSTALL_METHODS                                                                              \
                                                                                                                    \
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
          XCTFail(@"patrolServer.start() failed: %@", err);                                                         \
          return;                                                                                                   \
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
        server = nil;                                                                                               \
        appServiceClientSingleton = nil;                                                                            \
        XCTFail(@"patrolServer.start() failed: %@", err);                                                           \
        return @[];                                                                                                 \
      }                                                                                                             \
                                                                                                                    \
      appServiceClientSingleton = [[ObjCPatrolAppServiceClient alloc] initWithPort:server.boundAppPort];            \
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
    static NSArray<NSDictionary *> *allDartTests = nil;                                                             \
    if (allDartTests == nil) {                                                                                      \
      [__test_class launchPatrolAppWithServer:server];                                                              \
      if (![__test_class waitForPatrolAppReadyWithServer:server]) {                                                 \
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
        BOOL appReady = [__test_class waitForPatrolAppReadyWithServer:server];                                      \
        XCTAssertTrue(appReady, @"Patrol app did not become ready on port %ld", (long)server.boundAppPort);         \
        if (!appReady) {                                                                                            \
          return;                                                                                                   \
        }                                                                                                           \
                                                                                                                    \
        __block ObjCRunDartTestResponse *response = NULL;                                                           \
        __block NSError *error = nil;                                                                               \
        NSNumber *phaseIndex = nil;                                                                                 \
        while (true) {                                                                                              \
          response = NULL;                                                                                          \
          error = nil;                                                                                              \
          [appServiceClient                                                                                         \
              runDartTestWithName:dartTestName                                                                      \
                       phaseIndex:phaseIndex                                                                        \
                       completion:^(ObjCRunDartTestResponse *_Nullable r, NSError *_Nullable err) {                 \
                         if (err != NULL) {                                                                         \
                           error = err;                                                                             \
                         } else {                                                                                   \
                           response = r;                                                                            \
                         }                                                                                          \
                         NSString *status = err != NULL ? @"CRASHED" : response.result.uppercaseString;             \
                         NSLog(@"runDartTest(\"%@\"): call finished, test result: %@", dartTestName, status);       \
                       }];                                                                                          \
                                                                                                                    \
          while (!response && !error) {                                                                             \
            [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                      \
          }                                                                                                         \
          if (error != nil || response == nil || ![response.result isEqualToString:@"continuation"]) {              \
            break;                                                                                                  \
          }                                                                                                         \
                                                                                                                    \
          phaseIndex = response.nextPhaseIndex;                                                                     \
          if (phaseIndex == nil) {                                                                                  \
            XCTFail(@"A phased Patrol test returned continuation without a next phase");                            \
            return;                                                                                                 \
          }                                                                                                         \
          if (response.nextPhaseKeepsProcess) {                                                                     \
            /* The next phase attaches to the running app. The engine survives on iOS, */                           \
            /* so the same app service runs it. */                                                                  \
            continue;                                                                                               \
          }                                                                                                         \
          NSString *launchURL = response.nextPhaseLaunchUrl;                                                        \
          if (response.nextPhaseCleanInstall) {                                                                     \
            if (!TARGET_OS_SIMULATOR) {                                                                             \
              XCTFail(@"PatrolAppLaunch.cleanInstall() is supported only on the iOS Simulator");                    \
              return;                                                                                               \
            }                                                                                                       \
            /* Terminates the app after it reads the app name from it. */                                           \
            if (![self uninstallApp]) {                                                                             \
              XCTFail(@"Could not uninstall the app before phase %@", phaseIndex);                                  \
              return;                                                                                               \
            }                                                                                                       \
          } else {                                                                                                  \
            XCUIApplication *app = [[XCUIApplication alloc] init];                                                  \
            [app terminate];                                                                                        \
          }                                                                                                         \
          [__test_class launchPatrolAppWithServer:server launchURL:launchURL];                                      \
          appReady = [__test_class waitForPatrolAppReadyWithServer:server];                                         \
          XCTAssertTrue(appReady, @"Patrol app did not become ready on port %ld", (long)server.boundAppPort);       \
          if (!appReady) {                                                                                          \
            return;                                                                                                 \
          }                                                                                                         \
        }                                                                                                           \
        BOOL passed = response != nil && [response.result isEqualToString:@"success"];                              \
        NSString *details = response ? response.details : @"(no details - app likely crashed)";                     \
        if (response && [response.result isEqualToString:@"skipped"]) {                                             \
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
  @end

// Static-codegen variant: build-time `patrol build ios` generates real XCTest
// methods (a #included .inc) that call patrolExecuteDartTest:. BEGIN opens the
// class and shared infra; END closes it. No +testInvocations - XCTest discovers
// the generated `test_` methods natively (Xcode navigator, -only-testing).
#define PATROL_INTEGRATION_TEST_IOS_RUNNER_STATIC_BEGIN(__test_class)                                                  \
  @interface __test_class : XCTestCase                                                                                 \
  @end                                                                                                                 \
                                                                                                                       \
  @implementation __test_class                                                                                         \
                                                                                                                       \
  static PatrolServer *_patrolStaticServer = nil;                                                                      \
  static ObjCPatrolAppServiceClient *_patrolStaticClient = nil;                                                        \
  static int _patrolStaticTestIndex = 0;                                                                               \
                                                                                                                       \
  /* XCTest calls +setUp once per class, and the generated per-file classes all                                        \
   * share one server and one port. */                                                                                 \
  +(void)setUp {                                                                                                       \
    [super setUp];                                                                                                     \
    static dispatch_once_t patrolServerOnce;                                                                           \
    dispatch_once(&patrolServerOnce, ^{                                                                                \
      _patrolStaticServer = [[PatrolServer alloc] init];                                                               \
      NSError *err = nil;                                                                                              \
      [_patrolStaticServer startAndReturnError:&err];                                                                  \
      if (err != nil) {                                                                                                \
        NSLog(@"patrolServer.start(): failed, err: %@", err);                                                          \
      }                                                                                                                \
      _patrolStaticClient = [[ObjCPatrolAppServiceClient alloc] initWithPort:_patrolStaticServer.boundAppPort];        \
                                                                                                                       \
      XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];      \
      if (springboard.alerts.buttons[@"Allow"].exists) {                                                               \
        [springboard.alerts.buttons[@"Allow"] tap];                                                                    \
      }                                                                                                                \
    });                                                                                                                \
  }                                                                                                                    \
                                                                                                                       \
  +(void)launchPatrolApp {                                                                                             \
    [self launchPatrolAppWithURL:nil];                                                                                 \
  }                                                                                                                    \
  +(void)launchPatrolAppWithURL : (NSString *)launchURL {                                                              \
    _patrolStaticServer.appReady = NO;                                                                                 \
    XCUIApplication *app = [[XCUIApplication alloc] init];                                                             \
    NSMutableDictionary<NSString *, NSString *> *environment =                                                         \
        [app.launchEnvironment mutableCopy] ?: [NSMutableDictionary dictionary];                                       \
    environment[@"PATROL_TEST_SERVER_PORT"] =                                                                          \
        [NSString stringWithFormat:@"%ld", (long)_patrolStaticServer.boundTestPort];                                   \
    environment[@"PATROL_APP_SERVER_PORT"] =                                                                           \
        [NSString stringWithFormat:@"%ld", (long)_patrolStaticServer.boundAppPort];                                    \
    app.launchEnvironment = environment;                                                                               \
    if (launchURL == nil) {                                                                                            \
      [app launch];                                                                                                    \
    } else {                                                                                                           \
      NSURL *url = [NSURL URLWithString:launchURL];                                                                    \
      XCTAssertNotNil(url, @"Invalid phase launch URL: %@", launchURL);                                                \
      if (url == nil) {                                                                                                \
        return;                                                                                                        \
      }                                                                                                                \
      /* iOS 16.4+: openURL cold-starts through the link. Older iOS must launch       \
         first, then openURL — first paint is a normal start, not the deep link. */    \
      if (@available(iOS 16.4, *)) {                                                                                   \
        [app openURL:url];                                                                                             \
      } else {                                                                                                         \
        [app launch];                                                                                                  \
        [[XCUIDevice sharedDevice].system openURL:url];                                                                \
      }                                                                                                                \
    }                                                                                                                  \
  }                                                                                                                    \
                                                                                                                       \
  +(void)resetPermissions {                                                                                            \
    NSLog(@"Clearing permissions");                                                                                    \
    XCUIApplication *app = [[XCUIApplication alloc] init];                                                             \
    if (@available(iOS 13.4, *)) {                                                                                     \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceLocation];                                         \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceContacts];                                         \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceCalendar];                                         \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceReminders];                                        \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourcePhotos];                                           \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceBluetooth];                                        \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceMicrophone];                                       \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceCamera];                                           \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceHomeKit];                                          \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceMediaLibrary];                                     \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceKeyboardNetwork];                                  \
    }                                                                                                                  \
    if (@available(iOS 14.0, *)) {                                                                                     \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceHealth];                                           \
    }                                                                                                                  \
    if (@available(iOS 15.0, *)) {                                                                                     \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceUserTracking];                                     \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceFocus];                                            \
    }                                                                                                                  \
    if (@available(iOS 15.4, *)) {                                                                                     \
      [app resetAuthorizationStatusForResource:XCUIProtectedResourceLocalNetwork];                                     \
    }                                                                                                                  \
  }                                                                                                                    \
                                                                                                                       \
  PATROL_SPRINGBOARD_UNINSTALL_METHODS                                                                                 \
                                                                                                                       \
  -(void)patrolExecuteDartTest : (NSString *)dartTestName skip : (BOOL)skip {                                          \
    NSLog(@"RunnerUITests running Dart test: %@", dartTestName);                                                       \
    if (CLEAR_PERMISSIONS && _patrolStaticTestIndex > 0) {                                                             \
      [[self class] resetPermissions];                                                                                 \
      NSLog(@"App permissions cleared");                                                                               \
    }                                                                                                                  \
    if (FULL_ISOLATION && _patrolStaticTestIndex > 0) {                                                                \
      NSLog(@"Uninstalling app");                                                                                      \
      [[self class] uninstallApp];                                                                                     \
      NSLog(@"App uninstallation completed, launching fresh app instance");                                            \
    }                                                                                                                  \
    _patrolStaticTestIndex++;                                                                                          \
                                                                                                                       \
    [[self class] launchPatrolApp];                                                                                    \
    if (skip) {                                                                                                        \
      XCTSkip(@"Skip that test \"%@\"", dartTestName);                                                                 \
    }                                                                                                                  \
                                                                                                                       \
    NSDate *_patrolReadyDeadline = [NSDate dateWithTimeIntervalSinceNow:180.0];                                        \
    while (!_patrolStaticServer.appReady) {                                                                            \
      if ([[NSDate date] compare:_patrolReadyDeadline] == NSOrderedDescending) {                                       \
        XCTFail(@"App did not report PatrolAppService readiness on port %ld", (long)_patrolStaticServer.boundAppPort); \
        return;                                                                                                        \
      }                                                                                                                \
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                               \
    }                                                                                                                  \
                                                                                                                       \
    __block ObjCRunDartTestResponse *response = NULL;                                                                  \
    __block NSError *error = nil;                                                                                      \
    NSNumber *phaseIndex = nil;                                                                                        \
    while (true) {                                                                                                     \
      response = NULL;                                                                                                 \
      error = nil;                                                                                                     \
      [_patrolStaticClient runDartTestWithName:dartTestName                                                            \
                                    phaseIndex:phaseIndex                                                              \
                                    completion:^(ObjCRunDartTestResponse *_Nullable r, NSError *_Nullable e) {         \
                                      if (e != NULL) {                                                                 \
                                        error = e;                                                                     \
                                      } else {                                                                         \
                                        response = r;                                                                  \
                                      }                                                                                \
                                    }];                                                                                \
                                                                                                                       \
      while (!response && !error) {                                                                                    \
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                             \
      }                                                                                                                \
      if (error != nil || response == nil || ![response.result isEqualToString:@"continuation"]) {                     \
        break;                                                                                                         \
      }                                                                                                                \
                                                                                                                       \
      phaseIndex = response.nextPhaseIndex;                                                                            \
      if (phaseIndex == nil) {                                                                                         \
        XCTFail(@"A phased Patrol test returned continuation without a next phase");                                   \
        return;                                                                                                        \
      }                                                                                                                \
      if (response.nextPhaseKeepsProcess) {                                                                            \
        /* The next phase attaches to the running app. The engine survives on iOS, */                                  \
        /* so the same app service runs it. */                                                                         \
        continue;                                                                                                      \
      }                                                                                                                \
      NSString *launchURL = response.nextPhaseLaunchUrl;                                                               \
      if (response.nextPhaseCleanInstall) {                                                                            \
        if (!TARGET_OS_SIMULATOR) {                                                                                    \
          XCTFail(@"PatrolAppLaunch.cleanInstall() is supported only on the iOS Simulator");                           \
          return;                                                                                                      \
        }                                                                                                              \
        /* Terminates the app after it reads the app name from it. */                                                  \
        if (![[self class] uninstallApp]) {                                                                            \
          XCTFail(@"Could not uninstall the app before phase %@", phaseIndex);                                         \
          return;                                                                                                      \
        }                                                                                                              \
      } else {                                                                                                         \
        XCUIApplication *app = [[XCUIApplication alloc] init];                                                         \
        [app terminate];                                                                                               \
      }                                                                                                                \
      [[self class] launchPatrolAppWithURL:launchURL];                                                                 \
                                                                                                                       \
      NSDate *phaseReadyDeadline = [NSDate dateWithTimeIntervalSinceNow:180.0];                                        \
      while (!_patrolStaticServer.appReady) {                                                                          \
        if ([[NSDate date] compare:phaseReadyDeadline] == NSOrderedDescending) {                                       \
          XCTFail(@"App did not report PatrolAppService readiness on port %ld",                                        \
                  (long)_patrolStaticServer.boundAppPort);                                                             \
          return;                                                                                                      \
        }                                                                                                              \
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                             \
      }                                                                                                                \
    }                                                                                                                  \
    BOOL passed = response != nil && [response.result isEqualToString:@"success"];                                     \
    NSString *details = response ? response.details : @"(no details - app likely crashed)";                            \
    if (response && [response.result isEqualToString:@"skipped"]) {                                                    \
      XCTSkip(@"%@", details);                                                                                         \
    }                                                                                                                  \
    XCTAssertTrue(passed, @"%@", details);                                                                             \
  }

#define PATROL_INTEGRATION_TEST_IOS_RUNNER_STATIC_END @end

// Base class for the generated per-file test classes: shared infrastructure, no
// tests of its own. The generated `.inc` is included AFTER it and declares one
// XCTestCase subclass per Dart test file, so reports group by file.
#define PATROL_INTEGRATION_TEST_IOS_RUNNER_STATIC_BASE(__test_class) \
  PATROL_INTEGRATION_TEST_IOS_RUNNER_STATIC_BEGIN(__test_class)      \
  PATROL_INTEGRATION_TEST_IOS_RUNNER_STATIC_END

#import <Foundation/Foundation.h>

#if PATROL_ENABLED

#import <XCTest/XCTest.h>
#import <objc/runtime.h>

#import "PatrolIntegrationTestCase.h"

#if __has_include(<patrol/patrol-Swift.h>)
// CocoaPods: the Swift sources are part of this module.
#import <patrol/patrol-Swift.h>
#else
// SwiftPM: ObjC declarations of the PatrolImpl @objc types.
#import "patrol.h"
#endif

static NSMutableOrderedSet<NSString *> *_selectedTestNames = nil;
static PatrolServer *_patrolServer = nil;
static ObjCPatrolAppServiceClient *_patrolAppServiceClient = nil;
static int _patrolGeneratedTestIndex = 0;
static NSError *_patrolServerStartError = nil;

#if TARGET_OS_IOS
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

// Returns whether XCTest has a quiescence wait that Patrol could replace.
static inline BOOL PatrolReplaceQuiescenceWait(void) {
  static BOOL replaced = NO;
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
      void (*original)(id, SEL, BOOL, BOOL) = (void (*)(id, SEL, BOOL, BOOL))method_getImplementation(preEventMethod);
      method_setImplementation(preEventMethod,
                               imp_implementationWithBlock(^(id process, BOOL animationsIdle, BOOL isPreEvent) {
                                 if (*PatrolSkipsQuiescenceWait()) {
                                   return;
                                 }
                                 original(process, preEvent, animationsIdle, isPreEvent);
                               }));
    }

    replaced = legacyMethod != NULL || preEventMethod != NULL;
    if (!replaced) {
      NSLog(@"Patrol: this XCTest has no quiescence wait to skip");
    }
  });
  return replaced;
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
#endif

@implementation PatrolIntegrationTestCase

+ (BOOL)patrolFullIsolation {
  return NO;
}

+ (BOOL)patrolClearPermissions {
  return NO;
}

+ (BOOL)patrolScreenshotOnFailure {
  return NO;
}

+ (BOOL)isPatrolDevelopMode {
  return [[NSProcessInfo processInfo].environment[@"PATROL_DEVELOP"] isEqualToString:@"1"];
}

/// The user's runner class (`RunnerUITests`): the direct subclass of this one.
+ (BOOL)isPatrolRunnerClass {
  return class_getSuperclass(self) == [PatrolIntegrationTestCase class];
}

+ (NSArray<NSString *> *)selectedTestNames {
  return _selectedTestNames.array ?: @[];
}

+ (void)addSelectedTestName:(NSString *)name {
  if (_selectedTestNames == nil) {
    _selectedTestNames = [[NSMutableOrderedSet alloc] init];
  }
  [_selectedTestNames addObject:name];
}

+ (NSString *)patrolSelectorForDartTestName:(NSString *)dartTestName {
  NSString *escaped = [dartTestName stringByReplacingOccurrencesOfString:@"+" withString:@"__PLUS__"];
  return [escaped stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

/// True when build-time discovery generated subclasses of the runner class.
+ (BOOL)patrolHasGeneratedTests {
  static BOOL hasGeneratedTests = NO;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class base = [PatrolIntegrationTestCase class];
    unsigned int classCount = 0;
    Class *classes = objc_copyClassList(&classCount);
    for (unsigned int i = 0; i < classCount; i++) {
      Class superclass = class_getSuperclass(classes[i]);
      if (superclass != nil && superclass != base && class_getSuperclass(superclass) == base) {
        hasGeneratedTests = YES;
        break;
      }
    }
    free(classes);
  });
  return hasGeneratedTests;
}

+ (BOOL)patrolStartServerIfNeeded {
  if (_patrolServer != nil) {
    return YES;
  }
  PatrolServer *server = [[PatrolServer alloc] init];
  NSError *err = nil;
  [server startAndReturnError:&err];
  if (err != nil) {
    NSLog(@"patrolServer.start(): failed, err: %@", err);
    _patrolServerStartError = err;
    return NO;
  }
  _patrolServer = server;
  _patrolAppServiceClient = [[ObjCPatrolAppServiceClient alloc] initWithPort:server.boundAppPort];
  return YES;
}

+ (void)patrolAllowLocalNetwork {
#if TARGET_OS_IOS
  XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
  if (springboard.alerts.buttons[@"Allow"].exists) {
    [springboard.alerts.buttons[@"Allow"] tap];
  }
#endif
}

+ (void)launchPatrolAppWithServer:(PatrolServer *)server {
  server.appReady = NO;
  XCUIApplication *app = [[XCUIApplication alloc] init];
  NSMutableDictionary<NSString *, NSString *> *environment =
      [app.launchEnvironment mutableCopy] ?: [NSMutableDictionary dictionary];
  environment[@"PATROL_TEST_SERVER_PORT"] = [NSString stringWithFormat:@"%ld", (long)server.boundTestPort];
  environment[@"PATROL_APP_SERVER_PORT"] = [NSString stringWithFormat:@"%ld", (long)server.boundAppPort];
  environment[@"PATROL_HOST_SERVER_PORT"] = NSProcessInfo.processInfo.environment[@"PATROL_HOST_PORT"];
  app.launchEnvironment = environment;
  [app launch];
}

+ (BOOL)waitForPatrolAppReadyWithServer:(PatrolServer *)server timeout:(NSTimeInterval)timeout {
  NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:timeout];
  while (!server.appReady && deadline.timeIntervalSinceNow > 0) {
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
  }
  return server.appReady;
}

+ (BOOL)instancesRespondToSelector:(SEL)aSelector {
  if (![self isPatrolRunnerClass] || (![self isPatrolDevelopMode] && [self patrolHasGeneratedTests])) {
    return [super instancesRespondToSelector:aSelector];
  }
  NSString *name = NSStringFromSelector(aSelector);
  // Accumulate Marathon/dart selectors (spaces, '+', or escaped '+').
  if ([name containsString:@" "] || [name containsString:@"+"] || [name containsString:@"__PLUS__"]) {
    [self addSelectedTestName:name];
  }
  // Always register dynamic methods, including the develop keep-alive.
  [self defaultTestSuite];
  [super instancesRespondToSelector:aSelector];
  return YES;
}

#if TARGET_OS_IOS
// Attaches a screenshot of the current screen to [testCase] when Patrol takes screenshots on failure.
+ (void)attachFailureScreenshotTo:(XCTestCase *)testCase {
  if ([self patrolScreenshotOnFailure]) {
    [PatrolScreenshotBuffer attachCurrentScreenNamed:@"patrol_failure" to:testCase];
  }
}

// When the deletion fails, attaches a screenshot to [testCase] that shows what blocked it.
+ (BOOL)uninstallAppReportingFailureTo:(XCTestCase *)testCase {
  // XCTest reads the label from the running app. A skipped test or a failed deletion leaves the app closed, so remember
  // the label, and launch the app to read it if it is not known yet. Remember only a real name, so that a bad read is
  // retried by the next test.
  static NSString *appName = nil;
  XCUIApplication *app = [[XCUIApplication alloc] init];
  if (appName.length == 0) {
    if (app.state == XCUIApplicationStateNotRunning || app.state == XCUIApplicationStateUnknown) {
      [app launch];
    }
    NSString *label = app.label;
    if (label.length == 0) {
      NSLog(@"Could not read the app's name, so its icon cannot be found");
      [self attachFailureScreenshotTo:testCase];
      return NO;
    }
    appName = label;
  }
  NSLog(@"Uninstalling app: %@", appName);

  [app terminate];

  XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];

  // Go to home screen (springboard) by pressing home button
  [[XCUIDevice sharedDevice] pressButton:XCUIDeviceButtonHome];
  [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];

  // Search for app icon on current screen and subsequent screens
  int maxScreens = 10; /* Maximum number of screens to check */
  for (int currentScreen = 0; currentScreen < maxScreens; currentScreen++) {
    NSLog(@"Checking screen %d for app: %@", currentScreen + 1, appName);

    XCUIElement *icon = springboard.icons[appName];
    if (icon.exists && icon.isHittable) {
      NSLog(@"App icon found on screen %d: %@", currentScreen + 1, appName);

      // From the long press on, Springboard animates and does not become idle, so XCTest would wait a minute for it
      // after every step. Wait for each element instead. If this XCTest has no wait to replace, every step still takes
      // that minute, so the timeouts below get longer.
      NSTimeInterval patience = PatrolReplaceQuiescenceWait() ? 1.0 : 40.0;
      __block BOOL deleted = NO;
      PatrolWithoutQuiescenceWait(^{
        [icon pressForDuration:1.3];
        deleted = [self deleteAppIcon:icon named:appName inSpringboard:springboard patience:patience];
        if (!deleted) {
          // Take the screenshot while the menu or alert that blocked the deletion is still open.
          [self attachFailureScreenshotTo:testCase];
          // Close the context menu or alert that is left open, so the next launch is not covered.
          [[XCUIDevice sharedDevice] pressButton:XCUIDeviceButtonHome];
        }
      });
      return deleted;
    }

    // If app not found on current screen, swipe right to next screen
    if (currentScreen + 1 < maxScreens) {
      NSLog(@"App not found on screen %d, swiping right to next screen", currentScreen + 1);
      XCUICoordinate *startCoordinate = [springboard coordinateWithNormalizedOffset:CGVectorMake(0.8, 0.5)];
      XCUICoordinate *endCoordinate = [springboard coordinateWithNormalizedOffset:CGVectorMake(0.2, 0.5)];
      [startCoordinate pressForDuration:0.0
                   thenDragToCoordinate:endCoordinate
                           withVelocity:XCUIGestureVelocityFast
                    thenHoldForDuration:0.0];
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }
  }

  NSLog(@"App icon not found on any home screen: %@", appName);
  XCUIElement *alert = springboard.alerts.firstMatch;
  if (alert.exists) {
    NSLog(@"An alert hides the home screen: %@, buttons: %@", alert.label,
          [alert.buttons.allElementsBoundByIndex valueForKey:@"label"]);
  }
  [self attachFailureScreenshotTo:testCase];
  return NO;
}

// Confirms the deletion from the icon's context menu and waits until the icon is gone. [patience] multiplies the
// timeouts.
+ (BOOL)deleteAppIcon:(XCUIElement *)icon
                named:(NSString *)appName
        inSpringboard:(XCUIApplication *)springboard
             patience:(NSTimeInterval)patience {
  NSString *removeAppText = [ObjCLocalization getLocalizedStringWithKey:@"remove_app"];
  XCUIElement *removeAppButton = springboard.buttons[removeAppText];
  if (![removeAppButton waitForExistenceWithTimeout:5.0 * patience]) {
    NSLog(@"'%@' button not found", removeAppText);
    return NO;
  }
  [self tapWhenSettled:removeAppButton];
  NSDate *removeAppTappedAt = [NSDate date];

  // Depending on the iOS version, one or two alerts ask to confirm. Tap whichever shows up until the icon is gone.
  NSString *deleteText = [ObjCLocalization getLocalizedStringWithKey:@"delete"];
  NSArray<NSString *> *confirmTexts = @[ [ObjCLocalization getLocalizedStringWithKey:@"delete_app"], deleteText ];
  NSPredicate *isConfirmButton = [NSPredicate predicateWithFormat:@"label IN %@", confirmTexts];
  XCUIElement *confirmButton = [springboard.alerts.buttons matchingPredicate:isConfirmButton].firstMatch;
  // An alert or the context menu hides the icons below it from XCTest, and between two alerts neither may be visible.
  // So the app counts as deleted once neither the icon, the menu nor any alert has shown up for a while: 1 s after the
  // final "Delete", 3 s otherwise, in case another alert comes.
  XCUIElement *anyAlert = springboard.alerts.firstMatch;
  NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:15.0 * patience];
  NSDate *goneSince = nil;
  BOOL confirmedDelete = NO;
  while (goneSince == nil || -goneSince.timeIntervalSinceNow < (confirmedDelete ? 1.0 : 3.0)) {
    if (deadline.timeIntervalSinceNow <= 0) {
      if (anyAlert.exists && !confirmButton.exists) {
        NSLog(@"An alert Patrol does not recognize is open: %@, buttons: %@", anyAlert.label,
              [anyAlert.buttons.allElementsBoundByIndex valueForKey:@"label"]);
      }
      NSLog(@"Could not confirm deleting the app: %@", appName);
      return NO;
    }
    if (confirmButton.exists) {
      NSString *text = confirmButton.label;
      goneSince = nil;
      if (![self tapWhenSettled:confirmButton]) {
        continue;
      }
      if (![self waitUntilGone:springboard.alerts.buttons[text] timeout:3.0 * patience]) {
        NSLog(@"'%@' alert did not close, trying again", text);
        continue;
      }
      confirmedDelete = [text isEqualToString:deleteText];
      continue;
    }
    if (removeAppButton.exists && -removeAppTappedAt.timeIntervalSinceNow > 2.0 * patience) {
      removeAppTappedAt = [NSDate date];
      goneSince = nil;
      if ([self tapWhenSettled:removeAppButton]) {
        NSLog(@"'%@' menu was still open, tapped it again", removeAppText);
      }
      continue;
    }
    if (icon.exists || removeAppButton.exists || anyAlert.exists) {
      goneSince = nil;
    } else if (goneSince == nil) {
      goneSince = [NSDate date];
    }
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  }

  NSLog(@"App uninstallation completed");
  return YES;
}

// XCTest does not wait for Springboard here, so give a menu or alert a moment to finish appearing. Returns NO, without
// tapping, when the element went away meanwhile: tapping a missing element fails the test.
+ (BOOL)tapWhenSettled:(XCUIElement *)element {
  [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
  if (!element.exists) {
    return NO;
  }
  [element tap];
  return YES;
}

+ (BOOL)waitUntilGone:(XCUIElement *)element timeout:(NSTimeInterval)timeout {
  NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:timeout];
  while (element.exists) {
    if (deadline.timeIntervalSinceNow <= 0) {
      return NO;
    }
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  }
  return YES;
}

+ (void)resetPermissions {
  NSLog(@"Clearing permissions");
  XCUIApplication *app = [[XCUIApplication alloc] init];
  if (@available(iOS 13.4, *)) {
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceLocation];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceContacts];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceCalendar];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceReminders];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourcePhotos];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceBluetooth];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceMicrophone];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceCamera];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceHomeKit];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceMediaLibrary];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceKeyboardNetwork];
  }
  if (@available(iOS 14.0, *)) {
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceHealth];
  }
  if (@available(iOS 15.0, *)) {
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceUserTracking];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceFocus];
  }
  if (@available(iOS 15.4, *)) {
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceLocalNetwork];
  }
}
#endif

/// Runs between tests: resets permissions or reinstalls the app if asked to.
/// Returns NO, after failing [testCase], when the app could not be deleted.
+ (BOOL)patrolPrepareTestCase:(XCTestCase *)testCase atIndex:(NSUInteger)index {
#if TARGET_OS_IOS
  if (index == 0) {
    return YES;
  }
  if ([self patrolClearPermissions]) {
    [self resetPermissions];
    NSLog(@"App permissions cleared");
  }
  if ([self patrolFullIsolation]) {
    NSLog(@"Uninstalling app");
    if (![self uninstallAppReportingFailureTo:testCase]) {
      XCTFail(@"Could not delete the app for --full-isolation. The runner log says which step failed. "
              @"Patrol finds Springboard's buttons in English, German, French, Polish, Japanese or Korean.");
      return NO;
    }
    NSLog(@"Launching the app");
  }
#endif
  return YES;
}

/// Attaches the screenshots the test took, and one of the current screen when the app died mid-test.
- (void)patrolAttachScreenshotsAppDied:(BOOL)appDied {
#if TARGET_OS_IOS
  [[PatrolScreenshotBuffer sharedBuffer] drainAttachingTo:self];
  if (appDied) {
    [[self class] attachFailureScreenshotTo:self];
  }
#endif
}

+ (NSArray<NSInvocation *> *)patrolDevelopTestInvocations {
  static dispatch_once_t onceToken;
  Class runnerClass = self;
  dispatch_once(&onceToken, ^{
    IMP implementation = imp_implementationWithBlock(^(id _self) {
      NSLog(@"Patrol develop session: starting native automation server");
      if (![runnerClass patrolStartServerIfNeeded]) {
        XCTFail(@"patrolServer.start() failed: %@", _patrolServerStartError);
        return;
      }
      [runnerClass patrolAllowLocalNetwork];
      [runnerClass launchPatrolAppWithServer:_patrolServer];
      NSLog(@"Patrol develop session: keeping XCTest alive for hot restart");
      while (true) {
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
      }
    });
    class_addMethod(runnerClass, @selector(testPatrolDevelopSession), implementation, "v@:");
  });
  SEL selector = @selector(testPatrolDevelopSession);
  NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
  invocation.selector = selector;
  return @[ invocation ];
}

/// Asks the app for its Dart tests. Returns nil on failure.
+ (nullable NSArray<NSDictionary *> *)patrolListDartTests {
  static NSArray<NSDictionary *> *allDartTests = nil;
  if (allDartTests != nil) {
    return allDartTests;
  }
  [self launchPatrolAppWithServer:_patrolServer];
  if (![self waitForPatrolAppReadyWithServer:_patrolServer timeout:60.0]) {
    XCTFail(@"Patrol app did not become ready on port %ld", (long)_patrolServer.boundAppPort);
    return nil;
  }
  __block NSArray<NSDictionary *> *listedTests = nil;
  __block NSError *listError = nil;
  __block BOOL listCompleted = NO;
  [_patrolAppServiceClient
      listDartTestsWithCompletion:^(NSArray<NSDictionary *> *_Nullable tests, NSError *_Nullable err) {
        if (err != nil) {
          NSLog(@"listDartTests(): failed, err: %@", err);
          listError = err;
        }
        listedTests = tests;
        listCompleted = YES;
      }];
  while (!listCompleted) {
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
  }
  if (listError != nil || listedTests == nil) {
    XCTFail(@"listDartTests() failed: %@", listError);
    return nil;
  }
  allDartTests = listedTests;
  NSLog(@"Got %lu Dart tests: %@", (unsigned long)allDartTests.count, allDartTests);
  return allDartTests;
}

+ (NSArray<NSDictionary *> *)patrolSelectDartTests:(NSArray<NSDictionary *> *)allDartTests {
  NSMutableArray<NSDictionary *> *dartTests = [[NSMutableArray alloc] init];
  if ([self selectedTestNames].count == 0) {
    for (NSDictionary *fullTest in allDartTests) {
      [dartTests addObject:@{
        @"selector" : [self patrolSelectorForDartTestName:fullTest[@"name"]],
        @"name" : fullTest[@"name"],
        @"skip" : fullTest[@"skip"] ?: @(NO)
      }];
    }
    return dartTests;
  }
  NSLog(@"selectedTestNames: %@", [self selectedTestNames]);
  for (NSString *selectorName in [self selectedTestNames]) {
    BOOL matched = NO;
    for (NSDictionary *fullTest in allDartTests) {
      NSString *fullName = fullTest[@"name"];
      NSString *fullSelector = [self patrolSelectorForDartTestName:fullName];
      if ([fullSelector isEqualToString:selectorName] || [fullName isEqualToString:selectorName]) {
        [dartTests addObject:@{@"selector" : fullSelector, @"name" : fullName, @"skip" : fullTest[@"skip"] ?: @(NO)}];
        matched = YES;
      }
    }
    if (!matched) {
      NSLog(@"selected test \"%@\" has no matching Dart test; skipping it", selectorName);
      [dartTests addObject:@{@"selector" : selectorName, @"name" : selectorName, @"skip" : @(YES)}];
    }
  }
  return dartTests;
}

+ (NSArray<NSInvocation *> *)testInvocations {
  // The base class itself never holds tests.
  if (self == [PatrolIntegrationTestCase class]) {
    return @[];
  }

  // A class generated by build-time discovery: XCTest finds its test_ methods.
  if (![self isPatrolRunnerClass]) {
    return [self isPatrolDevelopMode] ? @[] : [super testInvocations];
  }

  if ([self isPatrolDevelopMode]) {
    return [self patrolDevelopTestInvocations];
  }

  if ([self patrolHasGeneratedTests]) {
    return @[];
  }

  // Runtime discovery: launch the app once and ask it for its Dart tests.
  if (![self patrolStartServerIfNeeded]) {
    XCTFail(@"patrolServer.start() failed: %@", _patrolServerStartError);
    return @[];
  }
  [self patrolAllowLocalNetwork];

  NSArray<NSDictionary *> *allDartTests = [self patrolListDartTests];
  if (allDartTests == nil) {
    return @[];
  }
  NSArray<NSDictionary *> *dartTests = [self patrolSelectDartTests:allDartTests];

  NSMutableArray<NSInvocation *> *invocations = [[NSMutableArray alloc] init];
  for (NSUInteger i = 0; i < dartTests.count; i++) {
    NSDictionary *dartTest = dartTests[i];
    NSString *dartTestName = dartTest[@"name"];
    NSString *selectorName = dartTest[@"selector"];
    BOOL skip = [dartTest[@"skip"] boolValue];

    IMP implementation = imp_implementationWithBlock(^(PatrolIntegrationTestCase *_self) {
      [_self patrolRunDartTest:dartTestName skip:skip index:i timeout:60.0];
    });
    SEL selector = NSSelectorFromString(selectorName);
    class_addMethod(self, selector, implementation, "v@:");

    NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;

    NSLog(@"%@.testInvocations(): selectorName = %@, dartTestName = %@", NSStringFromClass(self), selectorName,
          dartTestName);
    [invocations addObject:invocation];
  }
  return invocations;
}

- (void)patrolRunDartTest:(NSString *)dartTestName
                     skip:(BOOL)skip
                    index:(NSUInteger)index
                  timeout:(NSTimeInterval)timeout {
  Class cls = [self class];
  NSLog(@"%@ running Dart test: %@", NSStringFromClass(cls), dartTestName);
  if (![cls patrolStartServerIfNeeded]) {
    XCTFail(@"patrolServer.start() failed: %@", _patrolServerStartError);
    return;
  }
  if (skip) {
    XCTSkip(@"Skip that test \"%@\"", dartTestName);
  }
#if TARGET_OS_IOS
  // A capture that landed after the previous test's drain isn't ours.
  [[PatrolScreenshotBuffer sharedBuffer] discardPending];
#endif
  if (![cls patrolPrepareTestCase:self atIndex:index]) {
    return;
  }

  [cls launchPatrolAppWithServer:_patrolServer];
  if (![cls waitForPatrolAppReadyWithServer:_patrolServer timeout:timeout]) {
#if TARGET_OS_IOS
    [cls attachFailureScreenshotTo:self];
#endif
    XCTFail(@"Patrol app did not become ready on port %ld", (long)_patrolServer.boundAppPort);
    return;
  }

  __block ObjCRunDartTestResponse *response = nil;
  __block NSError *error = nil;
  [_patrolAppServiceClient runDartTestWithName:dartTestName
                                    completion:^(ObjCRunDartTestResponse *_Nullable r, NSError *_Nullable e) {
                                      if (e != nil) {
                                        error = e;
                                      } else {
                                        response = r;
                                      }
                                      NSLog(@"runDartTest(\"%@\"): call finished, test result: %@", dartTestName,
                                            e != nil ? @"CRASHED" : (r.passed ? @"PASSED" : @"FAILED"));
                                    }];

  while (!response && !error) {
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
  }
  BOOL passed = response ? response.passed : NO;
  NSString *details = response ? response.details : @"(no details - app likely crashed)";
  if (response && response.skipped) {
    XCTSkip(@"%@", details);
  }
  [self patrolAttachScreenshotsAppDied:response == nil];
  XCTAssertTrue(passed, @"%@", details);
}

- (void)patrolExecuteDartTest:(NSString *)dartTestName skip:(BOOL)skip {
  if (_patrolGeneratedTestIndex == 0 && [[self class] patrolStartServerIfNeeded]) {
    [[self class] patrolAllowLocalNetwork];
  }
  NSUInteger index = (NSUInteger)_patrolGeneratedTestIndex++;
  [self patrolRunDartTest:dartTestName skip:skip index:index timeout:180.0];
}

@end

#endif

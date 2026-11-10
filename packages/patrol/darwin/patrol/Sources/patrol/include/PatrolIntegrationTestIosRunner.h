// This file defines the iOS runners as macros to make the setup as easy as possible for the developer.
// A macro starts at its #define and ends at the first line without a trailing backslash. To edit one:
//  1. Copy the macro's lines and remove their trailing backslashes: $ sed 's/ *\\$//'
//  2. Paste them into the RunnerUITests.m in the RunnerUITests target
//  3. Make the changes, make sure it works
//  4. Re-add the trailing backslashes to the macro's lines only, aligned like the rest of the macro
//  5. Copy the macro back here
//  6. Go back to using a macro in RunnerUITests.m

// Set by patrol_cli from `screenshot_on_failure`; off when built without it.
#ifndef PATROL_SCREENSHOT_ON_FAILURE
#define PATROL_SCREENSHOT_ON_FAILURE 0
#endif

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

// Class methods shared by the iOS runners. They delete the app under test through Springboard.
// On the iOS Simulator, the next launch of the app installs it again.
#define PATROL_SPRINGBOARD_UNINSTALL_METHODS                                                                         \
  /* Attaches a screenshot of the current screen to [testCase] when Patrol takes screenshots on failure. */          \
  +(void)attachFailureScreenshotTo : (XCTestCase *)testCase {                                                        \
    if (PATROL_SCREENSHOT_ON_FAILURE) {                                                                              \
      [PatrolScreenshotBuffer attachCurrentScreenNamed:@"patrol_failure" to:testCase];                               \
    }                                                                                                                \
  }                                                                                                                  \
                                                                                                                     \
  /* When the deletion fails, attaches a screenshot to [testCase] that shows what blocked it. */                     \
  +(BOOL)uninstallAppReportingFailureTo : (XCTestCase *)testCase {                                                   \
    /* XCTest reads the label from the running app. A skipped test or a failed deletion leaves the app               \
       closed, so remember the label, and launch the app to read it if it is not known yet. Remember                 \
       only a real name, so that a bad read is retried by the next test. */                                          \
    static NSString *appName = nil;                                                                                  \
    XCUIApplication *app = [[XCUIApplication alloc] init];                                                           \
    if (appName.length == 0) {                                                                                       \
      if (app.state == XCUIApplicationStateNotRunning || app.state == XCUIApplicationStateUnknown) {                 \
        [app launch];                                                                                                \
      }                                                                                                              \
      NSString *label = app.label;                                                                                   \
      if (label.length == 0) {                                                                                       \
        NSLog(@"Could not read the app's name, so its icon cannot be found");                                        \
        [self attachFailureScreenshotTo:testCase];                                                                   \
        return NO;                                                                                                   \
      }                                                                                                              \
      appName = label;                                                                                               \
    }                                                                                                                \
    NSLog(@"Uninstalling app: %@", appName);                                                                         \
                                                                                                                     \
    [app terminate];                                                                                                 \
                                                                                                                     \
    XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];      \
                                                                                                                     \
    /* Go to home screen (springboard) by pressing home button */                                                    \
    [[XCUIDevice sharedDevice] pressButton:XCUIDeviceButtonHome];                                                    \
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                               \
                                                                                                                     \
    /* Search for app icon on current screen and subsequent screens */                                               \
    int maxScreens = 10; /* Maximum number of screens to check */                                                    \
    for (int currentScreen = 0; currentScreen < maxScreens; currentScreen++) {                                       \
      NSLog(@"Checking screen %d for app: %@", currentScreen + 1, appName);                                          \
                                                                                                                     \
      XCUIElement *icon = springboard.icons[appName];                                                                \
      if (icon.exists && icon.isHittable) {                                                                          \
        NSLog(@"App icon found on screen %d: %@", currentScreen + 1, appName);                                       \
                                                                                                                     \
        /* From the long press on, Springboard animates and does not become idle, so XCTest would wait               \
           a minute for it after every step. Wait for each element instead. If this XCTest has no wait to            \
           replace, every step still takes that minute, so the timeouts below get longer. */                         \
        NSTimeInterval patience = PatrolReplaceQuiescenceWait() ? 1.0 : 40.0;                                        \
        __block BOOL deleted = NO;                                                                                   \
        PatrolWithoutQuiescenceWait(^{                                                                               \
          [icon pressForDuration:1.3];                                                                               \
          deleted = [self deleteAppIcon:icon named:appName inSpringboard:springboard patience:patience];             \
          if (!deleted) {                                                                                            \
            /* Take the screenshot while the menu or alert that blocked the deletion is still open. */               \
            [self attachFailureScreenshotTo:testCase];                                                               \
            /* Close the context menu or alert that is left open, so the next launch is not covered. */              \
            [[XCUIDevice sharedDevice] pressButton:XCUIDeviceButtonHome];                                            \
          }                                                                                                          \
        });                                                                                                          \
        return deleted;                                                                                              \
      }                                                                                                              \
                                                                                                                     \
      /* If app not found on current screen, swipe right to next screen */                                           \
      if (currentScreen + 1 < maxScreens) {                                                                          \
        NSLog(@"App not found on screen %d, swiping right to next screen", currentScreen + 1);                       \
        XCUICoordinate *startCoordinate = [springboard coordinateWithNormalizedOffset:CGVectorMake(0.8, 0.5)];       \
        XCUICoordinate *endCoordinate = [springboard coordinateWithNormalizedOffset:CGVectorMake(0.2, 0.5)];         \
        [startCoordinate pressForDuration:0.0                                                                        \
                     thenDragToCoordinate:endCoordinate                                                              \
                             withVelocity:XCUIGestureVelocityFast                                                    \
                      thenHoldForDuration:0.0];                                                                      \
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                           \
      }                                                                                                              \
    }                                                                                                                \
                                                                                                                     \
    NSLog(@"App icon not found on any home screen: %@", appName);                                                    \
    XCUIElement *alert = springboard.alerts.firstMatch;                                                              \
    if (alert.exists) {                                                                                              \
      NSLog(@"An alert hides the home screen: %@, buttons: %@", alert.label,                                         \
            [alert.buttons.allElementsBoundByIndex valueForKey:@"label"]);                                           \
    }                                                                                                                \
    [self attachFailureScreenshotTo:testCase];                                                                       \
    return NO;                                                                                                       \
  }                                                                                                                  \
                                                                                                                     \
  /* Confirms the deletion from the icon's context menu and waits until the icon is gone. [patience]                 \
     multiplies the timeouts. */                                                                                     \
  +(BOOL)deleteAppIcon : (XCUIElement *)icon named : (NSString *)appName inSpringboard                               \
      : (XCUIApplication *)springboard patience : (NSTimeInterval)patience {                                         \
    NSString *removeAppText = [ObjCLocalization getLocalizedStringWithKey:@"remove_app"];                            \
    XCUIElement *removeAppButton = springboard.buttons[removeAppText];                                               \
    if (![removeAppButton waitForExistenceWithTimeout:5.0 * patience]) {                                             \
      NSLog(@"'%@' button not found", removeAppText);                                                                \
      return NO;                                                                                                     \
    }                                                                                                                \
    [self tapWhenSettled:removeAppButton];                                                                           \
    NSDate *removeAppTappedAt = [NSDate date];                                                                       \
                                                                                                                     \
    /* Depending on the iOS version, one or two alerts ask to confirm. Tap whichever shows up until the              \
       icon is gone. */                                                                                              \
    NSString *deleteText = [ObjCLocalization getLocalizedStringWithKey:@"delete"];                                   \
    NSArray<NSString *> *confirmTexts = @[ [ObjCLocalization getLocalizedStringWithKey:@"delete_app"], deleteText ]; \
    NSPredicate *isConfirmButton = [NSPredicate predicateWithFormat:@"label IN %@", confirmTexts];                   \
    XCUIElement *confirmButton = [springboard.alerts.buttons matchingPredicate:isConfirmButton].firstMatch;          \
    /* An alert or the context menu hides the icons below it from XCTest, and between two alerts neither             \
       may be visible. So the app counts as deleted once neither the icon, the menu nor any alert has                \
       shown up for a while: 1 s after the final "Delete", 3 s otherwise, in case another alert comes. */            \
    XCUIElement *anyAlert = springboard.alerts.firstMatch;                                                           \
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:15.0 * patience];                                        \
    NSDate *goneSince = nil;                                                                                         \
    BOOL confirmedDelete = NO;                                                                                       \
    while (goneSince == nil || -goneSince.timeIntervalSinceNow < (confirmedDelete ? 1.0 : 3.0)) {                    \
      if (deadline.timeIntervalSinceNow <= 0) {                                                                      \
        if (anyAlert.exists && !confirmButton.exists) {                                                              \
          NSLog(@"An alert Patrol does not recognize is open: %@, buttons: %@", anyAlert.label,                      \
                [anyAlert.buttons.allElementsBoundByIndex valueForKey:@"label"]);                                    \
        }                                                                                                            \
        NSLog(@"Could not confirm deleting the app: %@", appName);                                                   \
        return NO;                                                                                                   \
      }                                                                                                              \
      if (confirmButton.exists) {                                                                                    \
        NSString *text = confirmButton.label;                                                                        \
        goneSince = nil;                                                                                             \
        if (![self tapWhenSettled:confirmButton]) {                                                                  \
          continue;                                                                                                  \
        }                                                                                                            \
        if (![self waitUntilGone:springboard.alerts.buttons[text] timeout:3.0 * patience]) {                         \
          NSLog(@"'%@' alert did not close, trying again", text);                                                    \
          continue;                                                                                                  \
        }                                                                                                            \
        confirmedDelete = [text isEqualToString:deleteText];                                                         \
        continue;                                                                                                    \
      }                                                                                                              \
      if (removeAppButton.exists && -removeAppTappedAt.timeIntervalSinceNow > 2.0 * patience) {                      \
        removeAppTappedAt = [NSDate date];                                                                           \
        goneSince = nil;                                                                                             \
        if ([self tapWhenSettled:removeAppButton]) {                                                                 \
          NSLog(@"'%@' menu was still open, tapped it again", removeAppText);                                        \
        }                                                                                                            \
        continue;                                                                                                    \
      }                                                                                                              \
      if (icon.exists || removeAppButton.exists || anyAlert.exists) {                                                \
        goneSince = nil;                                                                                             \
      } else if (goneSince == nil) {                                                                                 \
        goneSince = [NSDate date];                                                                                   \
      }                                                                                                              \
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];                             \
    }                                                                                                                \
                                                                                                                     \
    NSLog(@"App uninstallation completed");                                                                          \
    return YES;                                                                                                      \
  }                                                                                                                  \
                                                                                                                     \
  /* XCTest does not wait for Springboard here, so give a menu or alert a moment to finish appearing.                \
     Returns NO, without tapping, when the element went away meanwhile: tapping a missing element fails              \
     the test. */                                                                                                    \
  +(BOOL)tapWhenSettled : (XCUIElement *)element {                                                                   \
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];                               \
    if (!element.exists) {                                                                                           \
      return NO;                                                                                                     \
    }                                                                                                                \
    [element tap];                                                                                                   \
    return YES;                                                                                                      \
  }                                                                                                                  \
                                                                                                                     \
  +(BOOL)waitUntilGone : (XCUIElement *)element timeout : (NSTimeInterval)timeout {                                  \
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:timeout];                                                \
    while (element.exists) {                                                                                         \
      if (deadline.timeIntervalSinceNow <= 0) {                                                                      \
        return NO;                                                                                                   \
      }                                                                                                              \
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];                             \
    }                                                                                                                \
    return YES;                                                                                                      \
  }

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
  static NSError *_patrolServerStartError = nil;                                                                    \
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
      _patrolServerStartError = err;                                                                                \
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
    [self launchPatrolAppWithServer:server url:nil];                                                                \
  }                                                                                                                 \
  /* Opens the app through url when it's set. Callers check it with patrolCanOpenDeepLinks first. */                \
  +(void)launchPatrolAppWithServer : (PatrolServer *)server url : (NSURL *)url {                                    \
    server.appReady = NO;                                                                                           \
    XCUIApplication *app = [[XCUIApplication alloc] init];                                                          \
    NSMutableDictionary<NSString *, NSString *> *environment =                                                      \
        [app.launchEnvironment mutableCopy] ?: [NSMutableDictionary dictionary];                                    \
    environment[@"PATROL_TEST_SERVER_PORT"] = [NSString stringWithFormat:@"%ld", (long)server.boundTestPort];       \
    environment[@"PATROL_APP_SERVER_PORT"] = [NSString stringWithFormat:@"%ld", (long)server.boundAppPort];         \
    environment[@"PATROL_HOST_SERVER_PORT"] = NSProcessInfo.processInfo.environment[@"PATROL_HOST_PORT"];           \
    app.launchEnvironment = environment;                                                                            \
    if (url == nil) {                                                                                               \
      [app launch];                                                                                                 \
    } else if (@available(iOS 16.4, *)) {                                                                           \
      [app openURL:url];                                                                                            \
    }                                                                                                               \
  }                                                                                                                 \
  /* XCUIApplication can open a URL in the app from iOS 16.4. On older iOS the system-wide                          \
     XCUISystem openURL: fails with "Device does not have the capability to open the default                        \
     app from a url". */                                                                                            \
  +(BOOL)patrolCanOpenDeepLinks {                                                                                   \
    if (@available(iOS 16.4, *)) {                                                                                  \
      return YES;                                                                                                   \
    }                                                                                                               \
    return NO;                                                                                                      \
  }                                                                                                                 \
  +(BOOL)waitForPatrolAppReadyWithServer : (PatrolServer *)server timeout : (NSTimeInterval)timeout {               \
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:timeout];                                               \
    while (!server.appReady && deadline.timeIntervalSinceNow > 0) {                                                 \
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                            \
    }                                                                                                               \
    return server.appReady;                                                                                         \
  }                                                                                                                 \
                                                                                                                    \
  /* Returns a failed result with the given details, reported like a Dart test failure. */                          \
  +(ObjCRunDartTestResponse *)patrolFailureResponse : (NSString *)details {                                         \
    return [[ObjCRunDartTestResponse alloc] initWithResult:@"failure"                                               \
                                                   details:details                                                  \
                                            nextPhaseIndex:nil                                                      \
                                        nextPhaseLaunchUrl:nil];                                                    \
  }                                                                                                                 \
                                                                                                                    \
  /* Runs a Dart test and, for a phased test, kills and relaunches the app for each next phase.                     \
     Returns nil only when a request fails, for example because the app crashed. */                                 \
  +(ObjCRunDartTestResponse *)patrolRunDartTest : (NSString *)dartTestName testCase : (XCTestCase *)testCase {      \
    __block ObjCRunDartTestResponse *response = NULL;                                                               \
    __block NSError *error = nil;                                                                                   \
    /* Asking for phase 0 tells the app that this runner can relaunch it for the next phases. */                    \
    NSNumber *phaseIndex = @0;                                                                                      \
    while (true) {                                                                                                  \
      response = NULL;                                                                                              \
      error = nil;                                                                                                  \
      [_patrolAppServiceClient                                                                                      \
          runDartTestWithName:dartTestName                                                                          \
                   phaseIndex:phaseIndex                                                                            \
                   completion:^(ObjCRunDartTestResponse *_Nullable r, NSError *_Nullable err) {                     \
                     if (err != NULL) {                                                                             \
                       error = err;                                                                                 \
                     } else {                                                                                       \
                       response = r;                                                                                \
                     }                                                                                              \
                     NSString *status = err != NULL ? @"CRASHED" : response.result.uppercaseString;                 \
                     NSLog(@"runDartTest(\"%@\"): call finished, test result: %@", dartTestName, status);           \
                   }];                                                                                              \
                                                                                                                    \
      while (!response && !error) {                                                                                 \
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                          \
      }                                                                                                             \
      if (error != nil || response == nil || ![response.result isEqualToString:@"continuation"]) {                  \
        break;                                                                                                      \
      }                                                                                                             \
                                                                                                                    \
      phaseIndex = response.nextPhaseIndex;                                                                         \
      if (phaseIndex == nil) {                                                                                      \
        return [self patrolFailureResponse:@"A phased Patrol test returned continuation without a next phase"];     \
      }                                                                                                             \
      if (response.nextPhaseKeepsProcess) {                                                                         \
        /* The next phase attaches to the running app. The engine survives on iOS, */                               \
        /* so the same app service runs it. */                                                                      \
        continue;                                                                                                   \
      }                                                                                                             \
      /* Check the link before the app is killed, so a bad one fails the test at once. */                           \
      NSString *launchURL = response.nextPhaseLaunchUrl;                                                            \
      NSURL *url = nil;                                                                                             \
      if (launchURL != nil) {                                                                                       \
        url = [NSURL URLWithString:launchURL];                                                                      \
        if (url == nil) {                                                                                           \
          NSString *details = [NSString stringWithFormat:@"Invalid deep link for the next phase: %@", launchURL];   \
          return [self patrolFailureResponse:details];                                                              \
        }                                                                                                           \
        if (![self patrolCanOpenDeepLinks]) {                                                                       \
          return [self patrolFailureResponse:@"A phase launched through a deep link needs iOS 16.4 or newer"];      \
        }                                                                                                           \
      }                                                                                                             \
      XCUIApplication *app = [[XCUIApplication alloc] init];                                                        \
      [app terminate];                                                                                              \
      [self launchPatrolAppWithServer:_patrolServer url:url];                                                       \
      if (![self waitForPatrolAppReadyWithServer:_patrolServer timeout:180.0]) {                                    \
        if (PATROL_SCREENSHOT_ON_FAILURE) {                                                                         \
          [PatrolScreenshotBuffer attachCurrentScreenNamed:@"patrol_failure" to:testCase];                          \
        }                                                                                                           \
        NSString *details =                                                                                         \
            [NSString stringWithFormat:@"Patrol app did not become ready for test \"%@\" phase %@ on port %ld",     \
                                       dartTestName, phaseIndex, (long)_patrolServer.boundAppPort];                 \
        return [self patrolFailureResponse:details];                                                                \
      }                                                                                                             \
    }                                                                                                               \
    return response;                                                                                                \
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
        if (![__test_class patrolStartServerIfNeeded]) {                                                            \
          XCTFail(@"patrolServer.start() failed: %@", _patrolServerStartError);                                     \
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
      XCTFail(@"patrolServer.start() failed: %@", _patrolServerStartError);                                         \
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
        if (skip) {                                                                                                 \
          XCTSkip(@"Skip that test \"%@\"", dartTestName);                                                          \
        }                                                                                                           \
        /* A capture that landed after the previous test's drain isn't ours. */                                     \
        [[PatrolScreenshotBuffer sharedBuffer] discardPending];                                                     \
                                                                                                                    \
        if (CLEAR_PERMISSIONS && i > 0) {                                                                           \
          [self resetPermissions];                                                                                  \
          NSLog(@"App permissions cleared");                                                                        \
        }                                                                                                           \
                                                                                                                    \
        if (FULL_ISOLATION && i > 0) {                                                                              \
          NSLog(@"Uninstalling app");                                                                               \
          if (![self uninstallAppReportingFailureTo:_self]) {                                                       \
            XCTFail(@"Could not delete the app for --full-isolation. The runner log says which step failed. "       \
                    @"Patrol finds Springboard's buttons in English, German, French, Polish, Japanese or Korean."); \
            return;                                                                                                 \
          }                                                                                                         \
          NSLog(@"Launching the app");                                                                              \
        }                                                                                                           \
                                                                                                                    \
        [__test_class launchPatrolAppWithServer:server];                                                            \
        BOOL appReady = [__test_class waitForPatrolAppReadyWithServer:server timeout:60.0];                         \
        if (!appReady) {                                                                                            \
          if (PATROL_SCREENSHOT_ON_FAILURE) {                                                                       \
            [PatrolScreenshotBuffer attachCurrentScreenNamed:@"patrol_failure" to:_self];                           \
          }                                                                                                         \
          XCTFail(@"Patrol app did not become ready on port %ld", (long)server.boundAppPort);                       \
          return;                                                                                                   \
        }                                                                                                           \
                                                                                                                    \
        ObjCRunDartTestResponse *response = [__test_class patrolRunDartTest:dartTestName testCase:_self];           \
        BOOL passed = response != nil && [response.result isEqualToString:@"success"];                              \
        NSString *details = response ? response.details : @"(no details - app likely crashed)";                     \
        if (response && [response.result isEqualToString:@"skipped"]) {                                             \
          XCTSkip(@"%@", details);                                                                                  \
        }                                                                                                           \
        [[PatrolScreenshotBuffer sharedBuffer] drainAttachingTo:_self];                                             \
        /* The app died mid-test, so the Dart failure hook never captured. */                                       \
        if (!response && PATROL_SCREENSHOT_ON_FAILURE) {                                                            \
          [PatrolScreenshotBuffer attachCurrentScreenNamed:@"patrol_failure" to:_self];                             \
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
    /* A capture that landed after the previous test's drain isn't ours. */                                         \
    [[PatrolScreenshotBuffer sharedBuffer] discardPending];                                                         \
    if (![__test_class patrolStartServerIfNeeded]) {                                                                \
      XCTFail(@"patrolServer.start() failed: %@", _patrolServerStartError);                                         \
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
      if (![__test_class uninstallAppReportingFailureTo:self]) {                                                    \
        XCTFail(@"Could not delete the app for --full-isolation. The runner log says which step failed. "           \
                @"Patrol finds Springboard's buttons in English, German, French, Polish, Japanese or Korean.");     \
        return;                                                                                                     \
      }                                                                                                             \
      NSLog(@"Launching the app");                                                                                  \
    }                                                                                                               \
    _patrolGeneratedTestIndex++;                                                                                    \
                                                                                                                    \
    [__test_class launchPatrolAppWithServer:_patrolServer];                                                         \
    if (skip) {                                                                                                     \
      XCTSkip(@"Skip that test \"%@\"", dartTestName);                                                              \
    }                                                                                                               \
                                                                                                                    \
    if (![__test_class waitForPatrolAppReadyWithServer:_patrolServer timeout:180.0]) {                              \
      if (PATROL_SCREENSHOT_ON_FAILURE) {                                                                           \
        [PatrolScreenshotBuffer attachCurrentScreenNamed:@"patrol_failure" to:self];                                \
      }                                                                                                             \
      XCTFail(@"App did not report PatrolAppService readiness on port %ld", (long)_patrolServer.boundAppPort);      \
      return;                                                                                                       \
    }                                                                                                               \
                                                                                                                    \
    ObjCRunDartTestResponse *response = [__test_class patrolRunDartTest:dartTestName testCase:self];                \
    BOOL passed = response != nil && [response.result isEqualToString:@"success"];                                  \
    NSString *details = response ? response.details : @"(no details - app likely crashed)";                         \
    if (response && [response.result isEqualToString:@"skipped"]) {                                                 \
      XCTSkip(@"%@", details);                                                                                      \
    }                                                                                                               \
    [[PatrolScreenshotBuffer sharedBuffer] drainAttachingTo:self];                                                  \
    /* The app died mid-test, so the Dart failure hook never captured. */                                           \
    if (!response && PATROL_SCREENSHOT_ON_FAILURE) {                                                                \
      [PatrolScreenshotBuffer attachCurrentScreenNamed:@"patrol_failure" to:self];                                  \
    }                                                                                                               \
    XCTAssertTrue(passed, @"%@", details);                                                                          \
  }                                                                                                                 \
                                                                                                                    \
  @end

// Deprecated: the runner above handles build-time discovery too. Kept so that
// RunnerUITests.m files set up for build-time discovery in Patrol 4.x still compile.
#define PATROL_INTEGRATION_TEST_IOS_RUNNER_STATIC_BASE(__test_class) PATROL_INTEGRATION_TEST_IOS_RUNNER(__test_class)

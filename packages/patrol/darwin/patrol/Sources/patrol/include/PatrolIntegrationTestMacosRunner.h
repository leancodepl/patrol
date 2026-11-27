// This file is a one giant macro to make the setup as easy as possible for the developer.
// To edit it:
//  1. Remove the trailing backslashes: $ sed 's/\\$//' PatrolIntegrationTestMacosRunner.h
//  2. Paste its contents into the RunnerUITests.m in the RunnerUITests target
//  3. Make the changes, make sure it works
//  4. Re-add trailing backslashes: $ sed 's/$/\\/' PatrolIntegrationTestMacosRunner.h
//  5. Copy the contents from RunnerUITests.m back here
//  6. Go back to using a macro in RunnerUITests.m

// One runner for both test discovery modes. With build-time discovery, the
// generated PatrolGeneratedTests.inc (#included right after this macro) declares
// one subclass per Dart test file with real test_ methods, and this class runs
// none. Without it, this class asks the app for its Dart tests at runtime and
// registers one dynamic method per test, reported as a native XCTest result.
#define PATROL_INTEGRATION_TEST_MACOS_RUNNER(__test_class)                                                       \
  @interface __test_class : XCTestCase                                                                           \
  @end                                                                                                           \
                                                                                                                 \
  @implementation __test_class                                                                                   \
                                                                                                                 \
  static PatrolServer *_patrolServer = nil;                                                                      \
  static ObjCPatrolAppServiceClient *_patrolAppServiceClient = nil;                                              \
  static NSError *_patrolServerStartError = nil;                                                                 \
                                                                                                                 \
  /* True when build-time discovery generated test classes (PatrolGeneratedTests.inc)                            \
     that subclass this one. They then own the tests, and this class runs none. */                               \
  +(BOOL)patrolHasGeneratedTests {                                                                               \
    static BOOL hasGeneratedTests = NO;                                                                          \
    static dispatch_once_t onceToken;                                                                            \
    dispatch_once(&onceToken, ^{                                                                                 \
      unsigned int classCount = 0;                                                                               \
      Class *classes = objc_copyClassList(&classCount);                                                          \
      for (unsigned int i = 0; i < classCount; i++) {                                                            \
        if (class_getSuperclass(classes[i]) == [__test_class class]) {                                           \
          hasGeneratedTests = YES;                                                                               \
          break;                                                                                                 \
        }                                                                                                        \
      }                                                                                                          \
      free(classes);                                                                                             \
    });                                                                                                          \
    return hasGeneratedTests;                                                                                    \
  }                                                                                                              \
                                                                                                                 \
  +(BOOL)patrolStartServerIfNeeded {                                                                             \
    if (_patrolServer != nil) {                                                                                  \
      return YES;                                                                                                \
    }                                                                                                            \
    PatrolServer *server = [[PatrolServer alloc] init];                                                          \
    NSError *err = nil;                                                                                          \
    [server startAndReturnError:&err];                                                                           \
    if (err != nil) {                                                                                            \
      NSLog(@"patrolServer.start(): failed, err: %@", err);                                                      \
      _patrolServerStartError = err;                                                                             \
      return NO;                                                                                                 \
    }                                                                                                            \
    _patrolServer = server;                                                                                      \
    _patrolAppServiceClient = [[ObjCPatrolAppServiceClient alloc] initWithPort:server.boundAppPort];             \
    return YES;                                                                                                  \
  }                                                                                                              \
                                                                                                                 \
  +(void)launchPatrolAppWithServer : (PatrolServer *)server {                                                    \
    server.appReady = NO;                                                                                        \
    XCUIApplication *app = [[XCUIApplication alloc] init];                                                       \
    NSMutableDictionary<NSString *, NSString *> *environment =                                                   \
        [app.launchEnvironment mutableCopy] ?: [NSMutableDictionary dictionary];                                 \
    environment[@"PATROL_TEST_SERVER_PORT"] = [NSString stringWithFormat:@"%ld", (long)server.boundTestPort];    \
    environment[@"PATROL_APP_SERVER_PORT"] = [NSString stringWithFormat:@"%ld", (long)server.boundAppPort];      \
    app.launchEnvironment = environment;                                                                         \
    [app launch];                                                                                                \
  }                                                                                                              \
  +(BOOL)waitForPatrolAppReadyWithServer : (PatrolServer *)server {                                              \
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:60.0];                                               \
    while (!server.appReady && deadline.timeIntervalSinceNow > 0) {                                              \
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                         \
    }                                                                                                            \
    return server.appReady;                                                                                      \
  }                                                                                                              \
                                                                                                                 \
  +(NSArray<NSInvocation *> *)testInvocations {                                                                  \
    /* A class generated by build-time discovery: XCTest finds its test_ methods. */                             \
    if (self != [__test_class class]) {                                                                          \
      return [super testInvocations];                                                                            \
    }                                                                                                            \
                                                                                                                 \
    if ([self patrolHasGeneratedTests]) {                                                                        \
      return @[];                                                                                                \
    }                                                                                                            \
                                                                                                                 \
    /* Runtime discovery: launch the app once and ask it for its Dart tests. */                                  \
    if (![self patrolStartServerIfNeeded]) {                                                                     \
      XCTFail(@"patrolServer.start() failed: %@", _patrolServerStartError);                                      \
      return @[];                                                                                                \
    }                                                                                                            \
    PatrolServer *server = _patrolServer;                                                                        \
    __block ObjCPatrolAppServiceClient *appServiceClient = _patrolAppServiceClient;                              \
                                                                                                                 \
    NSLog(@"Run the app for the first time");                                                                    \
                                                                                                                 \
    /* Run the app for the first time to gather Dart tests */                                                    \
    [__test_class launchPatrolAppWithServer:server];                                                             \
                                                                                                                 \
    NSLog(@"Waiting until the app reports that it is ready");                                                    \
                                                                                                                 \
    /* Spin the runloop waiting until the app reports that it is ready to report Dart tests */                   \
    if (![__test_class waitForPatrolAppReadyWithServer:server]) {                                                \
      XCTFail(@"Patrol app did not become ready on port %ld", (long)server.boundAppPort);                        \
      return @[];                                                                                                \
    }                                                                                                            \
                                                                                                                 \
    NSLog(@"listDartTests");                                                                                     \
                                                                                                                 \
    __block NSArray<NSDictionary *> *dartTests = NULL;                                                           \
    __block NSError *listError = nil;                                                                            \
    __block BOOL listCompleted = NO;                                                                             \
    [appServiceClient                                                                                            \
        listDartTestsWithCompletion:^(NSArray<NSDictionary *> *_Nullable tests, NSError *_Nullable err) {        \
          if (err != NULL) {                                                                                     \
            NSLog(@"listDartTests(): failed, err: %@", err);                                                     \
            listError = err;                                                                                     \
          }                                                                                                      \
                                                                                                                 \
          dartTests = tests;                                                                                     \
          listCompleted = YES;                                                                                   \
        }];                                                                                                      \
                                                                                                                 \
    NSLog(@"Spin the runloop waiting");                                                                          \
                                                                                                                 \
    /* Spin the runloop waiting until the app reports the Dart tests it contains */                              \
    while (!listCompleted) {                                                                                     \
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];                         \
    }                                                                                                            \
                                                                                                                 \
    if (listError != nil || dartTests == nil) {                                                                  \
      XCTFail(@"listDartTests() failed: %@", listError);                                                         \
      return @[];                                                                                                \
    }                                                                                                            \
                                                                                                                 \
    NSLog(@"Got %lu Dart tests: %@", dartTests.count, dartTests);                                                \
                                                                                                                 \
    NSMutableArray<NSInvocation *> *invocations = [[NSMutableArray alloc] init];                                 \
                                                                                                                 \
    /**                                                                                                          \
     * Once Dart tests are available, we:                                                                        \
     *                                                                                                           \
     *  Step 1. Dynamically add test case methods that request execution of an individual Dart test file.        \
     *                                                                                                           \
     *  Step 2. Create invocations to the generated methods and return them                                      \
     */                                                                                                          \
                                                                                                                 \
    for (NSDictionary * dartTest in dartTests) {                                                                 \
      /* Step 1 - dynamically create test cases */                                                               \
      NSString *dartTestName = dartTest[@"name"];                                                                \
      BOOL skip = [dartTest[@"skip"] boolValue];                                                                 \
                                                                                                                 \
      IMP implementation = imp_implementationWithBlock(^(id _self) {                                             \
        if (skip) {                                                                                              \
          XCTSkip(@"Skip that test \"%@\"", dartTestName);                                                       \
        }                                                                                                        \
                                                                                                                 \
        [__test_class launchPatrolAppWithServer:server];                                                         \
        BOOL appReady = [__test_class waitForPatrolAppReadyWithServer:server];                                   \
        XCTAssertTrue(appReady, @"Patrol app did not become ready on port %ld", (long)server.boundAppPort);      \
        if (!appReady) {                                                                                         \
          return;                                                                                                \
        }                                                                                                        \
                                                                                                                 \
        __block ObjCRunDartTestResponse *response = NULL;                                                        \
        __block NSError *error;                                                                                  \
        [appServiceClient                                                                                        \
            runDartTestWithName:dartTestName                                                                     \
                     completion:^(ObjCRunDartTestResponse *_Nullable r, NSError *_Nullable err) {                \
                       NSString *status;                                                                         \
                       if (err != NULL) {                                                                        \
                         error = err;                                                                            \
                         status = @"CRASHED";                                                                    \
                       } else {                                                                                  \
                         response = r;                                                                           \
                         status = response.passed ? @"PASSED" : @"FAILED";                                       \
                       }                                                                                         \
                       NSLog(@"runDartTest(\"%@\"): call finished, test result: %@", dartTestName, status);      \
                     }];                                                                                         \
                                                                                                                 \
        /* Wait until Dart test finishes (either fails or passes) or crashes */                                  \
        while (!response && !error) {                                                                            \
          [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                     \
        }                                                                                                        \
        BOOL passed = response ? response.passed : NO;                                                           \
        NSString *details = response ? response.details : @"(no details - app likely crashed)";                  \
        if (response && response.skipped) {                                                                      \
          XCTSkip(@"%@", details);                                                                               \
        }                                                                                                        \
        XCTAssertTrue(passed, @"%@", details);                                                                   \
      });                                                                                                        \
      SEL selector = NSSelectorFromString(dartTestName);                                                         \
      class_addMethod(self, selector, implementation, "v@:");                                                    \
                                                                                                                 \
      /* Step 2 – create invocations to the dynamically created methods */                                       \
      NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];                         \
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];                         \
      invocation.selector = selector;                                                                            \
                                                                                                                 \
      NSLog(@"RunnerUITests.testInvocations(): selectorName = %@, signature: %@", dartTestName, signature);      \
                                                                                                                 \
      [invocations addObject:invocation];                                                                        \
    }                                                                                                            \
                                                                                                                 \
    return invocations;                                                                                          \
  }                                                                                                              \
                                                                                                                 \
  /* Called by the test_ methods that build-time discovery generates. */                                         \
  -(void)patrolExecuteDartTest : (NSString *)dartTestName skip : (BOOL)skip {                                    \
    NSLog(@"RunnerUITests running Dart test: %@", dartTestName);                                                 \
    if (skip) {                                                                                                  \
      XCTSkip(@"Skip that test \"%@\"", dartTestName);                                                           \
    }                                                                                                            \
    if (![[self class] patrolStartServerIfNeeded]) {                                                             \
      XCTFail(@"patrolServer.start() failed: %@", _patrolServerStartError);                                      \
      return;                                                                                                    \
    }                                                                                                            \
                                                                                                                 \
    [[self class] launchPatrolAppWithServer:_patrolServer];                                                      \
    if (![[self class] waitForPatrolAppReadyWithServer:_patrolServer]) {                                         \
      XCTFail(@"Patrol app did not become ready on port %ld", (long)_patrolServer.boundAppPort);                 \
      return;                                                                                                    \
    }                                                                                                            \
                                                                                                                 \
    __block ObjCRunDartTestResponse *response = NULL;                                                            \
    __block NSError *error;                                                                                      \
    [_patrolAppServiceClient runDartTestWithName:dartTestName                                                    \
                                      completion:^(ObjCRunDartTestResponse *_Nullable r, NSError *_Nullable e) { \
                                        if (e != NULL) {                                                         \
                                          error = e;                                                             \
                                        } else {                                                                 \
                                          response = r;                                                          \
                                        }                                                                        \
                                      }];                                                                        \
                                                                                                                 \
    while (!response && !error) {                                                                                \
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];                         \
    }                                                                                                            \
    BOOL passed = response ? response.passed : NO;                                                               \
    NSString *details = response ? response.details : @"(no details - app likely crashed)";                      \
    if (response && response.skipped) {                                                                          \
      XCTSkip(@"%@", details);                                                                                   \
    }                                                                                                            \
    XCTAssertTrue(passed, @"%@", details);                                                                       \
  }                                                                                                              \
                                                                                                                 \
  @end

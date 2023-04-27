@import XCTest;
@import patrol;
@import ObjectiveC.runtime;

@interface RunnerUITests : XCTestCase
@end

@implementation RunnerUITests
+ (NSArray<NSInvocation *> *)testInvocations {
  /* Start native automation gRPC server */
  PatrolServer *server = [[PatrolServer alloc] init];
  [server startWithCompletionHandler:^(NSError *err) {
    NSLog(@"Server loop done, error: %@", err);
  }];

  /* Create a client for PatrolAppService, which lets us list and run Dart tests */
  __block PatrolAppServiceClient *appServiceClient = [[PatrolAppServiceClient alloc] init];

  /* Allow the Local Network permission required by Dart Observatory */
  XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
  XCUIElementQuery *systemAlerts = springboard.alerts;
  if (systemAlerts.buttons[@"Allow"].exists) {
    [systemAlerts.buttons[@"Allow"] tap];
  }

  /* Run the app for the first time to gather Dart tests */
  [[[XCUIApplication alloc] init] launch];

  /* Spin the runloop waiting until the app reports that it is ready to report Dart tests */
  while (!server.appReady) {
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
  }

  __block NSArray<NSString *> *dartTestFiles = NULL;
  [appServiceClient
      listDartTestsWithCompletionHandler:^(NSArray<NSString *> *_Nullable dartTests, NSError *_Nullable err) {
        if (err != NULL) {
          NSLog(@"listDartTests(): failed, err: %@", err);
        }

        dartTestFiles = dartTests;
      }];

  /* Spin the runloop waiting until the app reports the Dart tests it contains */
  while (!dartTestFiles) {
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
  }

  NSLog(@"Got %lu Dart tests: %@", dartTestFiles.count, dartTestFiles);

  NSMutableArray<NSInvocation *> *invocations = [[NSMutableArray alloc] init];

  /**
   * Once Dart tests are available, we:
   *
   *  Step 1. Dynamically add test case methods that request execution of an individual Dart test file.
   *
   *  Step 2. Create invocations to the generated methods and return them
   */

  for (NSString *dartTestFile in dartTestFiles) {

    /* Step 1 - dynamically create test cases */

    IMP implementation = imp_implementationWithBlock(^(id _self) {
      [[[XCUIApplication alloc] init] launch];

      __block RunDartTestResponse *response = NULL;
      [appServiceClient runDartTestWithName:dartTestFile
                          completionHandler:^(RunDartTestResponse *_Nullable r, NSError *_Nullable err) {
                            if (err != NULL) {
                              NSLog(@"runDartTestWithName(%@): failed, err: %@", dartTestFile, err);
                            }

                            response = r;
                          }];

      /* Wait until Dart test finishes */
      while (!response) {
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
      }

      XCTAssertTrue(response.passed, @"%@", response.details);
    });
    NSString *selectorName = [PatrolUtils createMethodNameFromPatrolGeneratedGroup:dartTestFile];
    SEL selector = NSSelectorFromString(selectorName);
    class_addMethod(self, selector, implementation, "v@:");

    /* Step 2 – create invocations to the dynamically created methods */
    NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;

    NSLog(@"RunnerUITests.testInvocations(): selectorName = %@, signature: %@", selectorName, signature);

    [invocations addObject:invocation];
  }

  return invocations;
}

@end

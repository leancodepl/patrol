@import Foundation;
@import ObjectiveC.runtime;
#import "PatrolTestCaseBase.h"

@implementation PatrolTestCaseBase

// MARK: Class properties

static PatrolServer *_server = nil;
+ (PatrolServer *)server {
  return _server;
}
+ (void)setServer:(PatrolServer *)newServer {
  if (newServer != _server) {
    _server = newServer;
  }
}

static ObjCPatrolAppServiceClient *_appServiceClient = nil;
+ (ObjCPatrolAppServiceClient *)appServiceClient {
  return _appServiceClient;
}
+ (void)setAppServiceClient:(ObjCPatrolAppServiceClient *)newAppServiceClient {
  if (newAppServiceClient != _appServiceClient) {
    _appServiceClient = newAppServiceClient;
  }
}

static NSString *_selectedTest = nil;
+ (NSString *)selectedTest {
  return _selectedTest;
}
+ (void)setSelectedTest:(NSString *)newSelectedTest {
  if (newSelectedTest != _selectedTest) {
    _selectedTest = [newSelectedTest copy];
  }
}

// MARK: Initializer

- (instancetype)init {
  self = [super initWithInvocation:nil];

  return self;
}

// MARK: Header implementation

+ (NSArray<NSString *> *)_ptr_testMethodSelectors {
  if ([self selectedTest] != nil) {
    // A single test was specified with the -only-testing option of xcodebuild
    NSLog(@"selectedTest: %@", [self selectedTest]);
    return [NSArray arrayWithObject:[self selectedTest]];
  }

  // No test was specified. Run app under test and perform test discovery

  /* Allow the Local Network permission required by Dart Observatory */
  XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
  XCUIElementQuery *systemAlerts = springboard.alerts;
  if (systemAlerts.buttons[@"Allow"].exists) {
    [systemAlerts.buttons[@"Allow"] tap];
  }

  __block NSArray<NSString *> *dartTests = NULL;
  /* Run the app for the first time to gather Dart tests */
  [[[XCUIApplication alloc] init] launch];

  /* Spin the runloop waiting until the app reports that it is ready to report Dart tests */
  while (![self server].appReady) {
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
  }

  [[self appServiceClient] listDartTestsWithCompletion:^(NSArray<NSString *> *_Nullable tests, NSError *_Nullable err) {
    if (err != NULL) {
      NSLog(@"listDartTests(): failed, err: %@", err);
    }

    dartTests = tests;
  }];

  /* Spin the runloop waiting until the app reports the Dart tests it contains */
  while (!dartTests) {
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
  }

  NSLog(@"Got %lu Dart tests: %@", dartTests.count, dartTests);

  return dartTests;
}

+ (IMP)_ptr_testMethodImplementation:(NSString *)testName {
  IMP implementation = imp_implementationWithBlock(^(id _self) {
    [[[XCUIApplication alloc] init] launch];

    __block ObjCRunDartTestResponse *response = NULL;
    [[self appServiceClient] runDartTestWithName:testName
                                      completion:^(ObjCRunDartTestResponse *_Nullable r, NSError *_Nullable err) {
                                        if (err != NULL) {
                                          NSLog(@"runDartTestWithName(%@): failed, err: %@", testName, err);
                                        }
                                        response = r;
                                      }];

    /* Wait until Dart test finishes */
    while (!response) {
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }

    XCTAssertTrue(response.passed, @"%@", response.details);
  });

  return implementation;
}

// MARK: Core logic

+ (BOOL)instancesRespondToSelector:(SEL)aSelector {
  NSString *selectedTest = [PatrolUtils createMethodNameFromPatrolGeneratedGroup:NSStringFromSelector(aSelector)];

  NSLog(@"instancesRespondToSelector: selected test \"%@\"", selectedTest);

  [self setSelectedTest:selectedTest];
  [self defaultTestSuite];  // calls testInvocations

  BOOL result = [super instancesRespondToSelector:aSelector];
  return true;  // TODO: return real result
}

+ (NSArray<NSInvocation *> *)testInvocations {
  [self setServer:[[PatrolServer alloc] init]];

  NSError *_Nullable __autoreleasing *_Nullable err = NULL;
  [[self server] startAndReturnError:err];
  if (err != NULL) {
    NSLog(@"patrolServer.start(): failed, err: %@", err);
  }

  [self setAppServiceClient:[[ObjCPatrolAppServiceClient alloc] init]];

  NSArray<NSString *> *selectors = [self _ptr_testMethodSelectors];
  NSArray<NSInvocation *> *invocations = [NSMutableArray arrayWithCapacity:selectors.count];

  for (NSString *selectorStr in selectors) {
    SEL selector = NSSelectorFromString(selectorStr);

    NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;

    // TODO: Re-add
    // class_addMethod(self, selector, implementation, "v@:");
  }

  return invocations;
}

@end

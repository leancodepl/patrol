@import Foundation;
@import ObjectiveC.runtime;

#import "PatrolTestCaseBase.h"
#import "patrol/patrol-Swift.h"


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

static Class _runnerClass = nil;
+ (Class)runnerClass {
  return _runnerClass;
}
+ (void)setRunnerClass:(Class)newRunnerClass {
  NSLog(@"DEBUG: set runner class to %@", newRunnerClass);
  if (newRunnerClass != _runnerClass) {
    _runnerClass = newRunnerClass;
  }
}

// MARK: Initializer

- (instancetype)init {
  self = [super initWithInvocation:nil];

  return self;
}

- (instancetype)initWithSelector:(SEL)selector {
  NSLog(@"DEBUG: PatrolTestCaseBase.initWithSelector: called with %@", NSStringFromSelector(selector));
  self = [super initWithSelector:selector];
  
  return self;
}

// MARK: Header implementation

+ (NSArray<NSString *> *)_ptr_dartTests {
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
    NSLog(@"Local Network permission dialog appeared, will accept it...");
    [systemAlerts.buttons[@"Allow"] tap];
  }

  __block NSArray<NSString *> *dartTests = NULL;
  /* Run the app for the first time to gather Dart tests */
  [[[XCUIApplication alloc] init] launch];
  
  NSLog(@"Will wait for the app to report its readiness...");

  /* Spin the runloop waiting until the app reports that it is ready to report Dart tests */
  while (![[self server] appReady]) {
    NSLog(@"Waiting for the app to report its readiness... appReady: %d", [[self server] appReady]);
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
  }

  NSLog(@"Will list Dart tests...");
  [[self appServiceClient] listDartTestsWithCompletion:^(NSArray<NSString *> *_Nullable tests, NSError *_Nullable err) {
    if (err != NULL) {
      NSLog(@"listDartTests(): failed, err: %@", err);
    }

    dartTests = tests;
  }];

  /* Spin the runloop waiting until the app reports the Dart tests it contains */
  while (!dartTests) {
    NSLog(@"Waiting for app to return list of Dart tests..");
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
  NSString *selectedTest = NSStringFromSelector(aSelector);
  NSLog(@"instancesRespondToSelector: selected test \"%@\"", selectedTest);

  [self setSelectedTest:selectedTest];
  [self defaultTestSuite];  // calls testInvocations

  BOOL responds = [super instancesRespondToSelector:aSelector];
  if (!responds) {
    NSLog(@"Fatal error: instance does not respond to selector \"%@\"", selectedTest);
  }
  
  return responds;
}

+ (NSArray<NSInvocation *> *)testInvocations {
  NSLog(@"testInvocations: begin");
  [self setServer:[[PatrolServer alloc] init]];

  NSError *_Nullable __autoreleasing *_Nullable err = NULL;
  [[self server] startAndReturnError:err];
  if (err != NULL) {
    NSLog(@"patrolServer.start(): failed, err: %@", err);
  }

  [self setAppServiceClient:[[ObjCPatrolAppServiceClient alloc] init]];

  NSLog(@"Will call _ptr_dartTests...");
  NSArray<NSString *> *dartTests = [self _ptr_dartTests];
  NSMutableArray<NSInvocation *> *invocations = [NSMutableArray arrayWithCapacity:dartTests.count];

  for (NSString *dartTest in dartTests) {
    NSString *selectorStr = [PatrolUtils createMethodNameFromPatrolGeneratedGroup:dartTest];
    SEL selector = NSSelectorFromString(selectorStr);
    
    NSString *classStr = NSStringFromClass([self runnerClass]);
    NSLog(@"Will create method %@ in class %@ for Dart test \"%@\"", selectorStr, classStr, dartTest);
    
    // Instance method must be created before calling instanceMethodSignatureForSelector
    IMP imp = [self _ptr_testMethodImplementation:dartTest];
    BOOL ok = class_addMethod([self runnerClass], selector, imp, "v@:");
    if (!ok) {
      NSLog(@"DEBUG: Failed to class_addMethod");
    }
    
    NSMethodSignature *signature = [[self runnerClass] instanceMethodSignatureForSelector:selector];
    NSLog(@"NSMethodSignature for selector %@: %@", selectorStr, signature);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;
    
    [invocations addObject:invocation];
  }

  NSLog(@"testInvocations: end, invocation count: %lu", invocations.count);
  return invocations;
}

@end

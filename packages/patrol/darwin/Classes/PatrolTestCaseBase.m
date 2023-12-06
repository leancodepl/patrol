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
+ (NSString *)selectedDartTest {
  return _selectedTest;
}
+ (void)setSelectedDartTest:(NSString *)newSelectedTest {
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

//- (instancetype)init {
//  self = [super initWithInvocation:nil];
//
//  return self;
//}
//
- (instancetype)initWithSelector:(SEL)selector {
  NSString *selectorStr = [PatrolUtils createMethodNameFromPatrolGeneratedGroup:NSStringFromSelector(selector)];
  selector = NSSelectorFromString(selectorStr);
  
  NSLog(@"DEBUG: PatrolTestCaseBase.initWithSelector: called with \"%@\"", NSStringFromSelector(selector));
  NSLog(@"DEBUG: PatrolTestCaseBase.initWithSelector: before super initWithSelector");
  self = [super initWithSelector:selector];
  NSLog(@"DEBUG: PatrolTestCaseBase.initWithSelector: after super initWithSelector");
  
  return self;
}

// MARK: Header implementation

+ (NSArray<NSString *> *)_ptr_listDartTests {
  if ([self selectedDartTest] != nil) {
    // A single test was specified with the -only-testing option of xcodebuild
    // NSString *selectorStr = [PatrolUtils createMethodNameFromPatrolGeneratedGroup:_selectedTest];
    
    // NSLog(@"Selected Dart test \"%@\" as selector \"%@\"", [self selectedTest], selectorStr);
    NSLog(@"Selected Dart test \"%@\"", [self selectedDartTest]);
    
    return [NSArray arrayWithObject:[self selectedDartTest]];
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

+ (IMP)_ptr_methodIplementationForDartTest:(NSString *)testName {
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
  // aSelector is not really a valid selector here! Rename to make it obvious.
  NSString *dartTest = NSStringFromSelector(aSelector);
  [self setSelectedDartTest:dartTest];
  // NSString *selectorStr = [PatrolUtils createMethodNameFromPatrolGeneratedGroup:[self selectedDartTest]];
  
  NSLog(@"Selected Dart test \"%@\" as selector \"%@\"", [self selectedDartTest], NSStringFromSelector(aSelector));
  
  [self defaultTestSuite];  // calls testInvocations and swizzles-in test methods

  // SEL selector = NSSelectorFromString(selectorStr);
  
  BOOL responds = [super instancesRespondToSelector:aSelector];
  if (!responds) {
    NSLog(@"Fatal error: instance does not respond to selector \"%@\"", NSStringFromSelector(aSelector));
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

  NSLog(@"Will call _ptr_listDartTests...");
  NSArray<NSString *> *dartTests = [self _ptr_listDartTests];
  NSMutableArray<NSInvocation *> *invocations = [NSMutableArray arrayWithCapacity:dartTests.count];

  for (NSString *dartTest in dartTests) {
    NSString *selectorStr = [dartTest copy];
    if ([self selectedDartTest] != nil) {
      selectorStr = [PatrolUtils createMethodNameFromPatrolGeneratedGroup:dartTest];
    }
    SEL selector = NSSelectorFromString(selectorStr);
    
    NSString *classStr = NSStringFromClass([self runnerClass]);
    NSLog(@"Will create method \"%@\" in class \"%@\" for Dart test \"%@\"", selectorStr, classStr, dartTest);
    
    // Instance method must be created before calling instanceMethodSignatureForSelector
    IMP imp = [self _ptr_methodIplementationForDartTest:dartTest];
    BOOL ok = class_addMethod([self runnerClass], selector, imp, "v@:");
    if (!ok) {
      NSLog(@"Fatal error: ailed to class_addMethod");
    }
    
    NSMethodSignature *signature = [[self runnerClass] instanceMethodSignatureForSelector:selector];
    NSLog(@"NSMethodSignature for selector %@: %@", selectorStr, signature);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;
    
    [invocations addObject:invocation];
  }

  NSLog(@"testInvocations: end, invocation count: %lu, will list them...", invocations.count);
  for (int i = 0; i < invocations.count; i++) {
    NSInvocation *invocation = [invocations objectAtIndex:i];
    NSLog(@"invocation %d: %@", i, NSStringFromSelector(invocation.selector));
  }
    
  
  return invocations;
}

@end

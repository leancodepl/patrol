@import XCTest;
@import patrol_next;
@import ObjectiveC.runtime;
#import <eDistantObject/EDOHostService.h>

// INTEGRATION_TEST_IOS_RUNNER(RunnerTests)

static UInt16 const kTestResultsServicePort = 9091;

@interface RunnerTests : XCTestCase

@end

@implementation RunnerTests

+ (NSArray<NSInvocation *> *)testInvocations {
  // Start native automation gRPC server
  PatrolServer *server = [[PatrolServer alloc] init];
  [server startWithCompletionHandler:^(NSError* err) {
    NSLog(@"Server loop done, error: %@", err);
  }];

  // Start RPC server for receiving Dart test results
  ActualTestResultsService *testResultsService = [[ActualTestResultsService alloc] init];
  dispatch_queue_t executionQueue = dispatch_queue_create("MyQueue", DISPATCH_QUEUE_SERIAL);
  [EDOHostService serviceWithPort:kTestResultsServicePort
                       rootObject:testResultsService
                            queue:executionQueue];
  
  XCUIApplication *app = [[XCUIApplication alloc] init];
  [app launch];

  // Spin the runloop waiting for test results
  while (!testResultsService.testResults) {
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
  }

  PatrolIntegrationTestRunner *testRunner = [[PatrolIntegrationTestRunner alloc] init];
  NSMutableArray<NSInvocation *> *testInvocations = [[NSMutableArray alloc] init];
  
  // Dynamically create test case methods from Dart results
  [testRunner iterateOverTestResults:testResultsService.testResults withSelector:^(SEL testSelector, BOOL success, NSString *failureMessage) {
    IMP assertImplementation = imp_implementationWithBlock(^(id _self) {
      XCTAssertTrue(success, @"%@", failureMessage);
    });
    class_addMethod(self, testSelector, assertImplementation, "v@:");
    NSMethodSignature *signature = [self instanceMethodSignatureForSelector:testSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = testSelector;
    [testInvocations addObject:invocation];
  }];
  
  // Add captured screenshots
  NSDictionary<NSString *, UIImage *> *capturedScreenshotsByName = testRunner.capturedScreenshotsByName;
  if (capturedScreenshotsByName.count > 0) {
    IMP screenshotImplementation = imp_implementationWithBlock(^(id _self) {
      [capturedScreenshotsByName enumerateKeysAndObjectsUsingBlock:^(NSString *name, UIImage *screenshot, BOOL *stop) {
        XCTAttachment *attachment = [XCTAttachment attachmentWithImage:screenshot];
        attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
        if (name != nil) {
          attachment.name = name;
        }
        [_self addAttachment:attachment];
      }];
    });
    SEL attachmentSelector = NSSelectorFromString(@"screenshotPlaceholder");
    class_addMethod(self, attachmentSelector, screenshotImplementation, "v@:");
    NSMethodSignature *attachmentSignature = [self instanceMethodSignatureForSelector:attachmentSelector];
    NSInvocation *attachmentInvocation = [NSInvocation invocationWithMethodSignature:attachmentSignature];
    attachmentInvocation.selector = attachmentSelector;
    [testInvocations addObject:attachmentInvocation];
  }
  return testInvocations;
}

@end

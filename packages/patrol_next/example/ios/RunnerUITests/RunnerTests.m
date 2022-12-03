@import XCTest;
@import integration_test;
@import patrol_next;
#import "RunnerUITests-Swift.h"
#import <eDistantObject/EDOHostService.h>

// INTEGRATION_TEST_IOS_RUNNER(RunnerTests)

static NSInteger const kTestResultsServicePort = 9091;

@interface RunnerTests : XCTestCase

@property(readwrite, nonatomic, strong) dispatch_queue_t executionQueue;

@end

@implementation RunnerTests

- (void)testRunPatrolServer {
  XCUIApplication *app = [[XCUIApplication alloc] init];
  [app launch];
  
  PatrolServer *server = [[PatrolServer alloc] init];
  [server startWithCompletionHandler:^(NSError* err) {
    [[Logger shared] i:[NSString stringWithFormat:@"Server loop done, error: %@", err]];
  }];

  ActualTestResultsService *testResultsService = [[ActualTestResultsService alloc] init];
  
  self.executionQueue = dispatch_queue_create("MyQueue", DISPATCH_QUEUE_SERIAL);
  [EDOHostService serviceWithPort:kTestResultsServicePort // FIXME: this might be a bug (it needs Uint16)
                       rootObject:testResultsService
                            queue:self.executionQueue];
  
  [[Logger shared] d:@"Wait start"];
  
  // Spin the runloop.
  while (!testResultsService.testResults) {
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
  }
  
  [[Logger shared] d:@"Wait end"];
}


//+ (NSArray<NSInvocation *> *)testInvocations {
//  [[Logger shared] i:@"START"];
//
//  [[Logger shared] i:@"Starting server loop..."];
//  PatrolServer *server = [[PatrolServer alloc] init];
//  [server startWithCompletionHandler:^(NSError* err) {
//    [[Logger shared] i:@"Server loop done"];
//  }];
//
//
//  FLTIntegrationTestRunner *integrationTestRunner = [[FLTIntegrationTestRunner alloc] init];
//  NSMutableArray<NSInvocation *> *testInvocations = [[NSMutableArray alloc] init];
////  [integrationTestRunner testIntegrationTestWithResults:^(SEL testSelector, BOOL success, NSString *failureMessage) {
////    IMP assertImplementation = imp_implementationWithBlock(^(id _self) {
////      XCTAssertTrue(success, @"%@", failureMessage);
////    });
////    class_addMethod(self, testSelector, assertImplementation, "v@:");
////    NSMethodSignature *signature = [self instanceMethodSignatureForSelector:testSelector];
////    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
////    invocation.selector = testSelector;
////    [testInvocations addObject:invocation];
////  }];
////  NSDictionary<NSString *, UIImage *> *capturedScreenshotsByName = integrationTestRunner.capturedScreenshotsByName;
////  if (capturedScreenshotsByName.count > 0) {
////    IMP screenshotImplementation = imp_implementationWithBlock(^(id _self) {
////      [capturedScreenshotsByName enumerateKeysAndObjectsUsingBlock:^(NSString *name, UIImage *screenshot, BOOL *stop) {
////        XCTAttachment *attachment = [XCTAttachment attachmentWithImage:screenshot];
////        attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
////        if (name != nil) {
////          attachment.name = name;
////        }
////        [_self addAttachment:attachment];
////      }];
////    });
////    SEL attachmentSelector = NSSelectorFromString(@"screenshotPlaceholder");
////    class_addMethod(self, attachmentSelector, screenshotImplementation, "v@:");
////    NSMethodSignature *attachmentSignature = [self instanceMethodSignatureForSelector:attachmentSelector];
////    NSInvocation *attachmentInvocation = [NSInvocation invocationWithMethodSignature:attachmentSignature];
////    attachmentInvocation.selector = attachmentSelector;
////    [testInvocations addObject:attachmentInvocation];
////  }
//  return testInvocations;
//}

@end

@import XCTest;
@import integration_test;
#import "RunnerTests-Swift.h"

// INTEGRATION_TEST_IOS_RUNNER(RunnerTests)

@interface RunnerTests : XCTestCase
@end

@implementation RunnerTests
+ (NSArray<NSInvocation *> *)testInvocations {
  [[Logger shared] i:@"START"];

  [[Logger shared] i:@"Starting server loop..."];
  PatrolServer *server = [[PatrolServer alloc] init];
  [server startWithCompletionHandler:^(NSError* err) {
    [[Logger shared] i:@"Server loop done"];
  }];


  FLTIntegrationTestRunner *integrationTestRunner = [[FLTIntegrationTestRunner alloc] init];
  NSMutableArray<NSInvocation *> *testInvocations = [[NSMutableArray alloc] init];
  [integrationTestRunner testIntegrationTestWithResults:^(SEL testSelector, BOOL success, NSString *failureMessage) {
    IMP assertImplementation = imp_implementationWithBlock(^(id _self) {
      XCTAssertTrue(success, @"%@", failureMessage);
    });
    class_addMethod(self, testSelector, assertImplementation, "v@:");
    NSMethodSignature *signature = [self instanceMethodSignatureForSelector:testSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = testSelector;
    [testInvocations addObject:invocation];
  }];
  NSDictionary<NSString *, UIImage *> *capturedScreenshotsByName = integrationTestRunner.capturedScreenshotsByName;
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

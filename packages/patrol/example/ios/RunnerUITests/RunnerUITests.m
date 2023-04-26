@import XCTest;
@import patrol;

NS_ASSUME_NONNULL_BEGIN

@interface RunnerUITests : XCTestCase
@end
                                                                                                                 
@implementation RunnerUITests
+(NSArray<NSInvocation *> *)testInvocations {
  /* Start native automation gRPC server */
  PatrolServer *server = [[PatrolServer alloc] init];
  [server startWithCompletionHandler:^(NSError * err) {
    NSLog(@"Server loop done, error: %@", err);
  }];
                                                                                                                 
  /* Allow the Local Network permission required by Dart Observatory */
  XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
  XCUIElementQuery *systemAlerts = springboard.alerts;
  if (systemAlerts.buttons[@"Allow"].exists) {
    [systemAlerts.buttons[@"Allow"] tap];
  }
                                                                                                                 
  XCUIApplication *app = [[XCUIApplication alloc] init];
  [app activate];
                                                                                                                 
  /* Spin the runloop waiting for test results */
  while (!server.dartTestResults) {
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
  }
                                                                                                                 
  PatrolIntegrationTestRunner *testRunner = [[PatrolIntegrationTestRunner alloc] init];
  NSMutableArray<NSInvocation *> *testInvocations = [[NSMutableArray alloc] init];
                                                                                                                 
  /* Dynamically create test case methods from Dart results */
  [testRunner iterateOverTestResults:server.dartTestResults
                        withSelector:^(SEL testSelector, BOOL success, NSString * failureMessage) {
                          IMP assertImplementation = imp_implementationWithBlock(^(id _self) {
                            XCTAssertTrue(success, @"%@", failureMessage);
                          });
                          class_addMethod(self, testSelector, assertImplementation, "v@:");
                          NSMethodSignature *signature = [self instanceMethodSignatureForSelector:testSelector];
                          NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                          invocation.selector = testSelector;
                          [testInvocations addObject:invocation];
                        }];
                                                                                                                 
  /* Add captured screenshots */
  NSDictionary<NSString *, UIImage *> *capturedScreenshotsByName = testRunner.capturedScreenshotsByName;
  if (capturedScreenshotsByName.count > 0) {
    IMP screenshotImplementation = imp_implementationWithBlock(^(id _self) {
      [capturedScreenshotsByName
          enumerateKeysAndObjectsUsingBlock:^(NSString * name, UIImage * screenshot, BOOL * stop) {
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

NS_ASSUME_NONNULL_END

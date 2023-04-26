#import "PatrolIntegrationTestRunner.h"
#import "PatrolPlugin.h"
#import "XCTest/XCTest.h"

@import ObjectiveC.runtime;
@import UIKit;

@implementation PatrolIntegrationTestRunner

- (instancetype)init {
  self = [super init];
  return self;
}

- (void)iterateOverTestResults:(NSDictionary<NSString *, NSString *> *)tests
                  withSelector:(NS_NOESCAPE PatrolIntegrationTestResults)testResult {
  NSMutableSet<NSString *> *testCaseNames = [[NSMutableSet alloc] init];

  [tests enumerateKeysAndObjectsUsingBlock:^(NSString *test, NSString *result, BOOL *stop) {
    NSString *testSelectorName = [[self class] testCaseNameFromDartTestName:test];

    // Make sure that Objective-C test method names are unique after
    // sanitization
    if ([testCaseNames containsObject:testSelectorName]) {
      NSString *reason = [NSString
          stringWithFormat:@"Cannot test \"%@\", duplicate XCTestCase tests named %@", test, testSelectorName];
      testResult(NSSelectorFromString(@"testDuplicateTestNames"), NO, reason);
      *stop = YES;
      return;
    }
    [testCaseNames addObject:testSelectorName];
    SEL testSelector = NSSelectorFromString(testSelectorName);

    if ([result isEqualToString:@"success"]) {
      testResult(testSelector, YES /*success*/, nil /*failureMessage*/);
    } else {
      testResult(testSelector, NO /*success*/, result /*failureMessage*/);
    }
  }];
}

@end

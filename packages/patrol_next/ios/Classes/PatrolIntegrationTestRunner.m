#import "PatrolNextPlugin.h"
#import "PatrolIntegrationTestRunner.h"

@import ObjectiveC.runtime;
@import UIKit;

@implementation PatrolIntegrationTestRunner

- (instancetype)init {
  self = [super init];
  return self;
}

- (void)iterateOverTestResults:(NSDictionary<NSString *,NSString *> *)tests withSelector:(NS_NOESCAPE PatrolIntegrationTestResults)testResult {
  NSMutableSet<NSString *> *testCaseNames = [[NSMutableSet alloc] init];

  [tests enumerateKeysAndObjectsUsingBlock:^(NSString *test, NSString *result, BOOL *stop) {
    NSString *testSelectorName = [[self class] testCaseNameFromDartTestName:test];

    // Make sure that Objective-C test method names are unique after sanitization
    if ([testCaseNames containsObject:testSelectorName]) {
      NSString *reason = [NSString stringWithFormat:@"Cannot test \"%@\", duplicate XCTestCase tests named %@", test, testSelectorName];
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

- (NSDictionary<NSString *,UIImage *> *)capturedScreenshotsByName {
  // TODO: Implement
  return [[NSDictionary alloc] init];
}

+ (NSString *)testCaseNameFromDartTestName:(NSString *)dartTestName {
  NSString *capitalizedString = dartTestName.localizedCapitalizedString;
  
  // Objective-C method names must be alphanumeric
  NSCharacterSet *disallowedCharacters = NSCharacterSet.alphanumericCharacterSet.invertedSet;
  
  // Remove disallowed characters
  NSString *upperCamelTestName = [[capitalizedString componentsSeparatedByCharactersInSet:disallowedCharacters] componentsJoinedByString:@""];
  return [NSString stringWithFormat:@"test%@", upperCamelTestName];
}

@end

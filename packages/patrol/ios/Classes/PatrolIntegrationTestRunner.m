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

//- (void)iterateOverTestResults:(NSDictionary<NSString *, NSString *> *)tests
//                  withSelector:(NS_NOESCAPE PatrolIntegrationTestResults)testResult {
//  NSMutableSet<NSString *> *testCaseNames = [[NSMutableSet alloc] init];
//
//  [tests enumerateKeysAndObjectsUsingBlock:^(NSString *test, NSString *result, BOOL *stop) {
//    NSString *testSelectorName = [[self class] testCaseNameFromDartTestName:test];
//
//    // Make sure that Objective-C test method names are unique after
//    // sanitization
//    if ([testCaseNames containsObject:testSelectorName]) {
//      NSString *reason = [NSString
//          stringWithFormat:@"Cannot test \"%@\", duplicate XCTestCase tests named %@", test, testSelectorName];
//      testResult(NSSelectorFromString(@"testDuplicateTestNames"), NO, reason);
//      *stop = YES;
//      return;
//    }
//    [testCaseNames addObject:testSelectorName];
//    SEL testSelector = NSSelectorFromString(testSelectorName);
//
//    if ([result isEqualToString:@"success"]) {
//      testResult(testSelector, YES /*success*/, nil /*failureMessage*/);
//    } else {
//      testResult(testSelector, NO /*success*/, result /*failureMessage*/);
//    }
//  }];
//}


+ (NSString *)createMethodNameFromPatrolGeneratedGroup:(NSString *)dartGroupName {
  NSMutableString *temp = [NSMutableString stringWithString:dartGroupName];

  // Split the string by dot
  NSArray<NSString *> *components = [[temp componentsSeparatedByString:@"."] mutableCopy];

  NSLog(@"Components: %@", components);
  
  // Convert the filename from snake_case to camelCase
  NSMutableString *fileName = [components.lastObject mutableCopy];
  NSArray *words = [fileName componentsSeparatedByString:@"_"];
  [fileName setString:words[0]];
  for (NSUInteger i = 1; i < words.count; i++) {
      NSString *word = words[i];
      NSString *firstLetter = [[word substringToIndex:1] capitalizedString];
      NSString *restOfWord = [word substringFromIndex:1];
      NSString *camelCaseWord = [firstLetter stringByAppendingString:restOfWord];
      [fileName appendString:camelCaseWord];
  }
  
  NSMutableArray<NSString * > *pathComponents = [[components subarrayWithRange:NSMakeRange(0, components.count - 1)] mutableCopy];
  if (pathComponents.count > 0) {
    NSString *path = [pathComponents componentsJoinedByString:@"_"];
    return [NSString stringWithFormat:@"%@_%@", path, fileName];
  } else {
    return fileName;
  }
}

@end

@import XCTest;
@import patrol;
@import ObjectiveC.runtime;

@interface RunnerUITests : PatrolTestCaseBase

@end

@implementation RunnerUITests

+ (instancetype)testCaseWithSelector:(SEL)selector {
  NSLog(@"DEBUG: testCaseWithSelector CALLED with \"%@\"", NSStringFromSelector(selector));
  return [super testCaseWithSelector:selector];
}

// - (instancetype)initWithSelector:(SEL)selector {}

+ (XCTestSuite *)defaultTestSuite {
  NSLog(@"DEBUG: defaultTestSuite CALLED");
  [super setRunnerClass:self];
  return [super defaultTestSuite];
}

// Maybe this will have to be uncommented?
//+ (BOOL)instancesRespondToSelector:(SEL)aSelector {
//  return [super instancesRespondToSelector:aSelector];
//}
@end

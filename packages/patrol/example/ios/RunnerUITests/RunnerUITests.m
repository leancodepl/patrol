@import XCTest;
@import patrol;
@import ObjectiveC.runtime;

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <objc/runtime.h>

@interface DummyTests : XCTestCase
@end

@implementation DummyTests
+ (NSArray<NSInvocation *> *)testInvocations {
  NSLog(@"testInvocations() called");

  /* Prepare dummy input */
  __block NSMutableArray<NSString *> *dartTestFiles = [[NSMutableArray alloc] init];
  [dartTestFiles addObject:@"example_test"];
  [dartTestFiles addObject:@"permissions_location_test"];
  [dartTestFiles addObject:@"permissions_many_test"];

  NSMutableArray *invocations = [NSMutableArray array];

  NSLog(@"Before the loop, %lu elements in the array", (unsigned long)dartTestFiles.count);

  for (int i = 0; i < dartTestFiles.count; i++) {
    /* Step 1 */

    NSString *name = dartTestFiles[i];

    void (^func)(DummyTests *) = ^(DummyTests *instance) {
      NSLog(@"func called!");
      [[[XCUIApplication alloc] init] launch];
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
      NSLog(@"func finished!");
      XCTAssertTrue(true, "dummy assert");
    };

    IMP implementation = imp_implementationWithBlock(func);
    NSString *selectorStr = [NSString stringWithFormat:@"test_%@", name];
    SEL selector = NSSelectorFromString(selectorStr);
    class_addMethod(self, selector, implementation, "v@:");

    /* Step 2 */

    NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;

    NSLog(@"RunnerUITests.testInvocations(): selectorStr = %@", selectorStr);

    [invocations addObject:invocation];
  }

  NSLog(@"After the loop");

  return invocations;
}

@end

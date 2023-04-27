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
//    IMP implementation = imp_implementationWithBlock(^(id _self) {
//      XCTAssertTrue(true, "dummy assert");
//    });

    NSString *selectorStr = [ NSString stringWithFormat:@"test_%@", name];
    SEL selector = NSSelectorFromString(selectorStr);

    BOOL ok = class_addMethod([self class], selector, (IMP) myMethodIMP, "v@:"); /* Last arg is method signature. v for void, @ for self, : for the selector */
    NSLog(@"class_addMethod successful? %{BOOL}d", ok);

    /* Step 2 */
    NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];

    NSLog(@"RunnerUITests.testInvocations(): selectorStr = %@", selectorStr);

    [invocations addObject:invocation];
  }

  NSLog(@"After the loop");

  return invocations;
}

void myMethodIMP(id self, SEL _cmd) {
  NSLog(@"myMethodIMP called!");
  XCTAssertTrue(true, "dummy assert");
}

@end

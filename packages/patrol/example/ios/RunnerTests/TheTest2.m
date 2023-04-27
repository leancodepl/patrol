#import "ParametrizedTestCase.h"
#import <objc/runtime.h>

@interface RuntimeTestsExample : ParametrizedTestCase

- (void)p:(NSString *)s;

@end

@implementation RuntimeTestsExample

- (void)p:(NSString *)s {
  NSLog(@"Objective-C Magic: %@", s);
  XCTAssertTrue(YES);
}

+ (NSArray *)_qck_testMethodSelectors {
  NSLog(@"_qck_testMethodSelectors called");

  NSArray *parameters = @[ @"first", @"second", @"third" ];
  NSMutableArray *selectors = [NSMutableArray array];

  for (NSString *parameter in parameters) {
    void (^block)(RuntimeTestsExample *) = ^(RuntimeTestsExample *instance) {
      [instance p:parameter];
    };

    IMP implementation = imp_implementationWithBlock(block);
    NSString *selectorNameStr = [NSString stringWithFormat:@"test_%@", parameter];
    SEL selector = NSSelectorFromString(selectorNameStr);
    class_addMethod(self, selector, implementation, "v@:");

    [selectors addObject:[[_QuickSelectorWrapper alloc] initWithSelector:selector]];
  }

  return [selectors copy];
}

@end

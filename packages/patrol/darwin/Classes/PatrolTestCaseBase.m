@import Foundation;
@import ObjectiveC.runtime;
#import "PatrolTestCaseBase.h"

@implementation PatrolTestCaseBase

- (instancetype)init {
  self = [super initWithInvocation:nil];
  return self;
}

+ (NSArray<NSInvocation *> *)testInvocations {
  NSArray<NSString *> *selectors  = [self _ptr_testMethodSelectors];
  NSArray<NSInvocation *> *invocations = [NSMutableArray arrayWithCapacity:selectors.count];
  
  for (NSString *selectorStr in selectors) {
    SEL selector = NSSelectorFromString(selectorStr);
    
    NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;
    
    // TODO: Re-add
    // class_addMethod(self, selector, implementation, "v@:");
  }
  
  return invocations;
}

+ (NSArray<NSString *> *)_ptr_testMethodSelectors {
  return @[];
}

@end

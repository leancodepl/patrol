#import <Foundation/Foundation.h>

#include "ParametrizedTestCase.h"
@interface _QuickSelectorWrapper ()
@property(nonatomic, assign) SEL selector;
@end

@implementation _QuickSelectorWrapper
- (instancetype)initWithSelector:(SEL)selector {
  self = [super init];
  _selector = selector;
  return self;
}
@end

@implementation ParametrizedTestCase
+ (NSArray<NSInvocation *> *)testInvocations {
  NSLog(@"testInvocations called!");

  // here we take list of test selectors from subclass
  NSArray<_QuickSelectorWrapper *> *wrappers = [self _qck_testMethodSelectors];
  NSMutableArray<NSInvocation *> *invocations = [NSMutableArray arrayWithCapacity:wrappers.count];

  // And wrap them in NSInvocation as XCTest api require
  for (_QuickSelectorWrapper *wrapper in wrappers) {
    SEL selector = wrapper.selector;
    NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;

    [invocations addObject:invocation];
  }

  /// If you want to mix parametrized test with normal `test_something` then you need to call super and append his
  /// invocations as well. Otherwise `test`-prefixed methods will be ignored
  return invocations;
}

+ (NSArray<_QuickSelectorWrapper *> *)_qck_testMethodSelectors {
  return @[];
}
@end

#ifndef ParametrizedTestCase_h
#define ParametrizedTestCase_h


#endif /* ParametrizedTestCase_h */

#import <XCTest/XCTest.h>

/// SEL is just pointer on C struct so we cannot put it inside of NSArray.
/// Instead we use this class as wrapper.
@interface _QuickSelectorWrapper : NSObject
- (instancetype)initWithSelector:(SEL)selector;
@end

@interface ParametrizedTestCase : XCTestCase
/// List of test methods to call. By default return nothing
+ (NSArray<_QuickSelectorWrapper *> *)_qck_testMethodSelectors;
@end

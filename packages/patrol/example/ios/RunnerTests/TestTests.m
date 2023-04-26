#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <objc/runtime.h>

@interface DynamicTestCase : XCTestCase

@end

@implementation DynamicTestCase

+ (void)load {
    [self createDynamicTestMethods];
}

+ (void)createDynamicTestMethods {
    SEL dynamicTestMethodSelector = NSSelectorFromString(@"dynamicTestMethod");

    BOOL success = class_addMethod(self, dynamicTestMethodSelector, (IMP)dynamicTestMethodImplementation, "v@:");
    if (success) {
        NSLog(@"Successfully added dynamic test method");
    } else {
        NSLog(@"Failed to add dynamic test method");
    }
}

void dynamicTestMethodImplementation(id self, SEL _cmd) {
    NSLog(@"Dynamic test method called");
    // Implement the logic for your dynamic test method
    // You can use assertions here to check the validity of the test
}

+ (NSArray<NSInvocation *> *)testInvocations {
    NSLog(@"testInvocations() called");
    NSMutableArray *invocations = [NSMutableArray array];
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(object_getClass(self), &methodCount);

    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);

        NSString *methodName = NSStringFromSelector(selector);
        if ([methodName hasPrefix:@"test"]) {
            NSMethodSignature *methodSignature = [self methodSignatureForSelector:selector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            invocation.selector = selector;
            invocation.target = self;
            [invocations addObject:invocation];
        }
    }

    return invocations;
}

@end

@import Foundation;
@import XCTest;

#import "PatrolUtils.h"
#import "patrol/patrol-Swift.h"

@interface PatrolTestCaseBase : XCTestCase

@property(class, nonatomic, readwrite) PatrolServer *server;
@property(class, nonatomic, readwrite) ObjCPatrolAppServiceClient *appServiceClient;
@property(class, strong, nonatomic) NSString *selectedTest;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
+ (NSArray<NSString *> *)_ptr_testMethodSelectors;
+ (IMP)_ptr_testMethodImplementation:(NSString *)testName;

@end

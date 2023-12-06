@import Foundation;
@import XCTest;

#import "PatrolUtils.h"

@class PatrolServer;
@class ObjCPatrolAppServiceClient;

@interface PatrolTestCaseBase : XCTestCase

@property(class, nonatomic, readwrite, strong) PatrolServer *server;
@property(class, nonatomic, readwrite, strong) ObjCPatrolAppServiceClient *appServiceClient;
@property(class, nonatomic, readwrite, copy) NSString *selectedTest;
@property(class, nonatomic, readwrite, strong) Class runnerClass;

// - (instancetype)init;
+ (NSArray<NSString *> *)_ptr_dartTests;
+ (IMP)_ptr_testMethodImplementation:(NSString *)testName;

@end

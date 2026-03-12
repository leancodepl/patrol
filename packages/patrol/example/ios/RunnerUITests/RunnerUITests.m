@import XCTest;
@import patrol;
@import ObjectiveC.runtime;

// With CocoaPods, @import patrol exports ObjC headers including this macro.
// With SPM, @import patrol only exports Swift APIs, so we need explicit #import.
#if !defined(PATROL_INTEGRATION_TEST_IOS_RUNNER)
#import "PatrolIntegrationTestIosRunner.h"
#endif

PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)

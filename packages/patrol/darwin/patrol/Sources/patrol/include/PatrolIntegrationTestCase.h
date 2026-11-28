#import <Foundation/Foundation.h>

// The app target imports this module too, and only test targets can see XCTest.
#if __has_include(<XCTest/XCTest.h>)
#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

/// Base class of the Patrol XCTest runner.
///
/// `PATROL_INTEGRATION_TEST_IOS_RUNNER` and `PATROL_INTEGRATION_TEST_MACOS_RUNNER`
/// declare its one direct subclass (`RunnerUITests`). That class asks the app for
/// its Dart tests at runtime, unless build-time test discovery generated
/// subclasses of it, whose `test_` methods call `-patrolExecuteDartTest:skip:`.
///
/// Compiled only when the patrol pod or Swift package is built with
/// `PATROL_ENABLED=1`.
@interface PatrolIntegrationTestCase : XCTestCase

/// Whether to uninstall the app between tests on iOS. The iOS runner macro
/// returns the `FULL_ISOLATION` build flag.
@property(class, nonatomic, readonly) BOOL patrolFullIsolation;

/// Whether to reset app permissions between tests on iOS. The iOS runner macro
/// returns the `CLEAR_PERMISSIONS` build flag.
@property(class, nonatomic, readonly) BOOL patrolClearPermissions;

/// Whether to attach a screenshot on iOS when a test fails before the Dart
/// failure hook can take one. The iOS runner macro returns the
/// `PATROL_SCREENSHOT_ON_FAILURE` build flag.
@property(class, nonatomic, readonly) BOOL patrolScreenshotOnFailure;

/// Runs one Dart test in the app and reports its result as this XCTest's result.
- (void)patrolExecuteDartTest:(NSString *)dartTestName skip:(BOOL)skip;

@end

NS_ASSUME_NONNULL_END

#endif

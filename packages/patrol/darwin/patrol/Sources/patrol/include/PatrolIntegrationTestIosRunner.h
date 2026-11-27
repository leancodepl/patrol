#import "PatrolIntegrationTestCase.h"

#ifndef FULL_ISOLATION
#define FULL_ISOLATION 0
#endif
#ifndef CLEAR_PERMISSIONS
#define CLEAR_PERMISSIONS 0
#endif
// Set by patrol_cli from `screenshot_on_failure`; off when built without it.
#ifndef PATROL_SCREENSHOT_ON_FAILURE
#define PATROL_SCREENSHOT_ON_FAILURE 0
#endif

// Declares the XCTest runner class. The logic lives in PatrolIntegrationTestCase.
// With build-time discovery, PatrolGeneratedTests.inc (#included right after this
// macro) declares one subclass per Dart test file with real test_ methods.
#define PATROL_INTEGRATION_TEST_IOS_RUNNER(__test_class) \
  @interface __test_class : PatrolIntegrationTestCase    \
  @end                                                   \
                                                         \
  @implementation __test_class                           \
  +(BOOL)patrolFullIsolation {                           \
    return FULL_ISOLATION;                               \
  }                                                      \
  +(BOOL)patrolClearPermissions {                        \
    return CLEAR_PERMISSIONS;                            \
  }                                                      \
  +(BOOL)patrolScreenshotOnFailure {                     \
    return PATROL_SCREENSHOT_ON_FAILURE;                 \
  }                                                      \
  @end

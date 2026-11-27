#import "PatrolIntegrationTestCase.h"

// Declares the XCTest runner class. The logic lives in PatrolIntegrationTestCase.
// With build-time discovery, PatrolGeneratedTests.inc (#included right after this
// macro) declares one subclass per Dart test file with real test_ methods.
#define PATROL_INTEGRATION_TEST_MACOS_RUNNER(__test_class) \
  @interface __test_class : PatrolIntegrationTestCase      \
  @end                                                     \
                                                           \
  @implementation __test_class                             \
  @end

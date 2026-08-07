@import XCTest;
@import patrol;
@import ObjectiveC.runtime;

// Under Swift Package Manager the runner macros live in their own Clang module,
// because `patrol` itself has to be the Swift module (see
// darwin/patrol/Package.swift). Under CocoaPods everything is a single `patrol`
// module and the macro is already defined by the import above.
#if !defined(PATROL_INTEGRATION_TEST_MACOS_RUNNER)
@import PatrolRunner;
#endif

PATROL_INTEGRATION_TEST_MACOS_RUNNER(RunnerUITests)

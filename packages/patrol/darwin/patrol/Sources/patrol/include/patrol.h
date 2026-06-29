#import <Foundation/Foundation.h>

// This umbrella header is SwiftPM-ONLY: it is the umbrella of the `patrol` Clang
// module (see module.modulemap) and is excluded from the CocoaPods build in the
// podspec. Under SwiftPM the Swift sources live in a separate module (PatrolImpl)
// because SwiftPM cannot mix Swift and ObjC in one target, so we re-export it
// (together with `export *` in module.modulemap) — a single `@import patrol` then
// also exposes the Swift @objc API (PatrolPlugin, PatrolServer,
// ObjCPatrolAppServiceClient, ObjCLocalization, ...) that the runner macros use.
//
// The import is unconditional on purpose: a preprocessor guard cannot reliably
// detect "SwiftPM vs CocoaPods" here. SWIFT_PACKAGE is not defined when Xcode
// compiles a SwiftPM Clang module, and COCOAPODS leaks in from the consuming
// target in a hybrid app (CocoaPods + SwiftPM side by side), poisoning the
// `patrol` module variant. Excluding this file from CocoaPods is what keeps the
// two worlds apart: under CocoaPods everything is one module and the @objc classes
// are already visible without PatrolImpl.
@import PatrolImpl;

#import "PatrolIntegrationTestIosRunner.h"
#import "PatrolIntegrationTestMacosRunner.h"

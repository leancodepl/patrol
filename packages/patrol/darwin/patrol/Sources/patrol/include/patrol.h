#import <Foundation/Foundation.h>

// This umbrella header is SwiftPM-ONLY: it is the umbrella of the `patrol` Clang
// module (see module.modulemap) and is excluded from the CocoaPods build in the
// podspec.
//
// Under SwiftPM the Swift sources live in a separate module (PatrolImpl) because
// SwiftPM cannot mix Swift and ObjC in one target. We deliberately do NOT
// `@import PatrolImpl` here: a Clang module that imports a Swift module is only
// importable from ObjC, never from Swift — and Flutter's macOS
// GeneratedPluginRegistrant is Swift (`import patrol`). See
// https://github.com/leancodepl/patrol/issues/3177.
//
// Instead:
//  - PatrolPlugin is implemented in ObjC in this module (so `import patrol`
//    works from Swift and ObjC).
//  - Macro-facing @objc types from PatrolImpl are declared below as interfaces.
//    The Swift implementations (same @objc names) are linked via the package
//    dependency and resolve at runtime. RunnerUITests only need `@import patrol`.
//
// Under CocoaPods this file is unused: everything compiles into one `patrol`
// module and the Swift @objc classes are visible directly.

NS_ASSUME_NONNULL_BEGIN

/// Implemented in PatrolImpl (Swift). Declared here so runner macros compile
/// against module `patrol` without importing the Swift module.
@interface PatrolServer : NSObject
@property(nonatomic, assign) BOOL appReady;
- (instancetype)init;
- (BOOL)startAndReturnError:(NSError *_Nullable *_Nullable)error;
@end

@interface ObjCRunDartTestResponse : NSObject
@property(nonatomic, readonly) BOOL passed;
@property(nonatomic, readonly, nullable) NSString *details;
- (instancetype)initWithPassed:(BOOL)passed details:(NSString *_Nullable)details;
@end

@interface ObjCPatrolAppServiceClient : NSObject
- (instancetype)init;
- (void)listDartTestsWithCompletion:(void (^)(NSArray<NSDictionary *> *_Nullable tests,
                                              NSError *_Nullable error))completion;
- (void)runDartTestWithName:(NSString *)name
                 completion:(void (^)(ObjCRunDartTestResponse *_Nullable response, NSError *_Nullable error))completion;
@end

@interface ObjCLocalization : NSObject
+ (NSString *)getLocalizedStringWithKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END

#import "PatrolExtensionRegistry.h"
#import "PatrolIntegrationTestIosRunner.h"
#import "PatrolIntegrationTestMacosRunner.h"
#import "PatrolPlugin.h"

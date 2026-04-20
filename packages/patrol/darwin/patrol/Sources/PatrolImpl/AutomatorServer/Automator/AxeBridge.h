#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE

NS_ASSUME_NONNULL_BEGIN

/// Bridge to axeDevToolsXCUI APIs that are declared behind
/// `#if compiler(>=5.3) && $NonescapableTypes` in the framework's
/// `.swiftinterface`. Those methods are invisible to Swift 6.0
/// (Xcode 16.0) because the feature flag is not active, but they
/// are available as plain `@objc` methods on the compiled binary,
/// so Objective-C can call them directly.
@interface AxeBridge : NSObject

/// Calls `-[AxeDevTools postResult:withTags:withScanName:error:]`.
/// - Parameters:
///   - axe: The `AxeDevTools` session. Typed as `id` to avoid
///     importing `axeDevToolsXCUI` from this public header.
///   - result: The `AxeResult` returned by `-[AxeDevTools run...]`.
///   - tags: Tags to attach to the uploaded scan.
///   - scanName: Optional dashboard scan name.
/// - Returns: The opaque `AxeDevToolsResultKey` on success, or `nil`
///   on failure (in which case `error` is populated if non-NULL).
+ (nullable id)postResultOn:(id)axe
                     result:(id)result
                       tags:(NSArray<NSString *> *)tags
                   scanName:(nullable NSString *)scanName
                      error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END

#endif

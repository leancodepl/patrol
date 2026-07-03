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

+ (nullable id)postResultOn:(id)axe
                     result:(id)result
                       tags:(NSArray<NSString *> *)tags
                   scanName:(nullable NSString *)scanName
                      error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END

#endif

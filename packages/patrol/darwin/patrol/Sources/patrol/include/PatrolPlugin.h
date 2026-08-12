#import <Foundation/Foundation.h>

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/// Flutter plugin that exposes native Patrol runtime state to Dart.
///
/// Lives in the Clang `patrol` module (not PatrolImpl) so Flutter's generated
/// registrants can `import patrol` / `@import patrol` from both Swift and ObjC
/// without the Clang module importing a Swift module.
@interface PatrolPlugin : NSObject <FlutterPlugin>
@end

NS_ASSUME_NONNULL_END

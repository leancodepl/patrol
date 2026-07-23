#import <Foundation/Foundation.h>
#import <objc/runtime.h>

/// Registers a `PatrolServerExtension` implementation for discovery at server start.
///
/// Extension packages should call this from `+load` (see `patrol_axe` for an example).
FOUNDATION_EXPORT void PatrolRegisterServerExtensionClass(Class _Nonnull cls);

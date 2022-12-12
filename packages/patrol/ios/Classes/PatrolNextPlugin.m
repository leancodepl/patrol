#import "PatrolNextPlugin.h"
#if __has_include(<patrol_next/patrol_next-Swift.h>)
#import <patrol_next/patrol_next-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "patrol_next-Swift.h"
#endif

@implementation PatrolNextPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPatrolNextPlugin registerWithRegistrar:registrar];
}
@end

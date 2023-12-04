#import "PatrolPlugin.h"
#if __has_include(<patrol/patrol-Swift.h>)
#import <patrol/patrol-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "patrol-Swift.h"
#endif

@implementation PatrolPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [SwiftPatrolPlugin registerWithRegistrar:registrar];
}
@end

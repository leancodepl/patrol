#if TARGET_OS_IPHONE

#import <Foundation/Foundation.h>
#import <patrol/PatrolExtensionRegistry.h>

/// Registers `AxeServerExtension` with Patrol before UITest server startup.
@interface PatrolAxeExtensionLoader : NSObject
@end

@implementation PatrolAxeExtensionLoader

+ (void)load {
  Class extensionClass = NSClassFromString(@"AxeServerExtension");
  if (extensionClass == Nil) {
    NSLog(@"PatrolAxe: AxeServerExtension class not found, skipping registration");
    return;
  }
  PatrolRegisterServerExtensionClass(extensionClass);
}

@end

#endif

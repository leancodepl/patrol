// SwiftPM requires every target to have at least one non-header source file
// beyond optional plugin sources. PatrolPlugin.m already satisfies that; this
// file remains as a tiny anchor and documents the Clang target's role:
// host the Objective-C runner macros / public headers and the ObjC
// PatrolPlugin. Swift implementation lives in PatrolImpl and is linked as a
// dependency without being `@import`ed into this module's interface.
#import <Foundation/Foundation.h>

__attribute__((unused)) static void _patrol_objc_anchor(void) {}

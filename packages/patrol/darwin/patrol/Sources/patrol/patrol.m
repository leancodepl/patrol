// SwiftPM requires every target to have at least one non-header source file.
// This Clang target (`patrol`) exists only to host the Objective-C runner macros
// (in include/) and to re-export the Swift implementation module (PatrolImpl),
// so this translation unit is intentionally empty.
#import <Foundation/Foundation.h>

__attribute__((unused)) static void _patrol_objc_anchor(void) {}

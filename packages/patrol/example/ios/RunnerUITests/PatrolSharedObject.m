#import <Foundation/Foundation.h>
#import "PatrolSharedObject.h"

@implementation PatrolSharedObject

- (void)submitTestResults:(NSString*)message {
  NSLog(@"Test results submitted, message: %@", message);
}

@end

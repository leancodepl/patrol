#import <Foundation/Foundation.h>
#import "PatrolSharedObject.h"

@implementation PatrolSharedObject {
  CallCompletion completion;
}

- (id)init {
  self = [super init];  
  return self;
}

- (id)initWithCompletion:(void (^)(void))completion {
  self = [super init];
  self->completion = completion;
  return self;
}

- (void)submitTestResults:(NSString*)message {
  NSLog(@"Test results submitted, message: %@", message);
  
  if (completion != (id)[NSNull null]) {
    NSLog(@"calling completion!");
    completion();
  }
}

@end

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

- (void)submitTestResults:(NSString*)message results:(NSData*) results {
  NSLog(@"Test results submitted, message: %@", message);
  
  NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:results];
  
  [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
    NSLog(@"key %@, value: %@", key, value);
  }];
  
  if (completion != (id)[NSNull null]) {
    NSLog(@"calling completion!");
    completion();
  }
}

@end

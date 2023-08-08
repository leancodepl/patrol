#import "PatrolUtils.h"

@import ObjectiveC.runtime;
//@import AppKit;

@implementation PatrolUtils

+ (NSString *)createMethodNameFromPatrolGeneratedGroup:(NSString *)dartGroupName {
  NSMutableString *temp = [NSMutableString stringWithString:dartGroupName];

  // Split the string by dot
  NSArray<NSString *> *components = [[temp componentsSeparatedByString:@"."] mutableCopy];

  // Convert the filename from snake_case to camelCase
  NSMutableString *fileName = [components.lastObject mutableCopy];
  NSArray *words = [fileName componentsSeparatedByString:@"_"];
  [fileName setString:words[0]];
  for (NSUInteger i = 1; i < words.count; i++) {
    NSString *word = words[i];
    NSString *firstLetter = [[word substringToIndex:1] capitalizedString];
    NSString *restOfWord = [word substringFromIndex:1];
    NSString *camelCaseWord = [firstLetter stringByAppendingString:restOfWord];
    [fileName appendString:camelCaseWord];
  }

  NSMutableArray<NSString *> *pathComponents =
      [[components subarrayWithRange:NSMakeRange(0, components.count - 1)] mutableCopy];
  if (pathComponents.count > 0) {
    NSString *path = [pathComponents componentsJoinedByString:@"_"];
    return [NSString stringWithFormat:@"%@_%@", path, fileName];
  } else {
    return fileName;
  }
}

@end

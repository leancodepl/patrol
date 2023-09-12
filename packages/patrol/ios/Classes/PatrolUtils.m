#import "PatrolUtils.h"

@import ObjectiveC.runtime;
@import UIKit;

@implementation PatrolUtils

+ (NSString *)createMethodNameFromPatrolGeneratedGroup:(NSString *)dartGroupName {
  // Let's assume dartGroupName is "examples.example_test completes main flow".
  // It consists of two parts.
  //
  // The first part, "examples.example_test", reflects the location of the Dart
  // test file in the filesystem at integration_test/examples/example_test.
  // For the first part of this name to be a valid Objective-C identifier, we convert
  // it to "examples_exampleTest"
  //
  // The second part, "completes main flow" is the name of the test. For it to be a
  // valid Objective-C identifier, we convert it to "completesMainFlow".
  //
  // Then both parts are concatenated together with a "___", resulting in
  // "examples_exampleTest___completesMainFlow"

  NSArray<NSString *> *parts = [[self class] splitIntoParts:dartGroupName];

  NSString *firstPart = [[self class] convertFirstPart:parts[0]];
  NSString *secondPart = [[self class] convertSecondPart:parts[1]];

  NSString *result = @"";
  result = [result stringByAppendingString:firstPart];
  result = [result stringByAppendingString:@"___"];
  result = [result stringByAppendingString:secondPart];

  return result;
}

+ (NSString *)convertFirstPart:(NSString *)filePath {
  // Split the string by dot
  NSArray<NSString *> *components = [[filePath componentsSeparatedByString:@"."] mutableCopy];

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

  NSRange range = NSMakeRange(0, components.count - 1);
  NSMutableArray<NSString *> *pathComponents = [[components subarrayWithRange:range] mutableCopy];
  if (pathComponents.count > 0) {
    NSString *path = [pathComponents componentsJoinedByString:@"_"];
    [fileName setString:[NSString stringWithFormat:@"%@_%@", path, fileName]];
  }

  return fileName;
}

+ (NSString *)convertSecondPart:(NSString *)testName {
  // Convert the filename from "space delimeted words" to camelCasedWords
  // NSString.capitalizedString could be used here as well.

  NSArray *words = [testName componentsSeparatedByString:@" "];
  NSMutableString *capitalizedTestName = [words.firstObject mutableCopy];
  [capitalizedTestName setString:words[0]];
  for (NSUInteger i = 1; i < words.count; i++) {
    NSString *word = words[i];
    NSString *firstLetter = [[word substringToIndex:1] capitalizedString];
    NSString *restOfWord = [word substringFromIndex:1];
    NSString *camelCaseWord = [firstLetter stringByAppendingString:restOfWord];
    [capitalizedTestName appendString:camelCaseWord];
  }

  // Objective-C method names must be alphanumeric.
  NSMutableCharacterSet *allowedCharacters = [NSMutableCharacterSet alphanumericCharacterSet];  // invertedSet
  [allowedCharacters addCharactersInString:@"_"];
  NSCharacterSet *disallowedCharacters = allowedCharacters.invertedSet;

  // Remove disallowed characters.
  NSString *filteredTestName =
      [[capitalizedTestName componentsSeparatedByCharactersInSet:disallowedCharacters] componentsJoinedByString:@""];
  return filteredTestName;
}

+ (NSArray<NSString *> *)splitIntoParts:(NSString *)testName {
  // The first space in the original dartGroupName is a good separator for the 2 parts.
  NSArray<NSString *> *parts = [[testName componentsSeparatedByString:@" "] mutableCopy];
  NSString *firstPart = parts[0];
  NSString *secondPart = [[parts subarrayWithRange:NSMakeRange(1, parts.count - 1)] componentsJoinedByString:@" "];

  NSMutableArray<NSString *> *result = [[NSMutableArray alloc] init];
  [result addObject:firstPart];
  [result addObject:secondPart];
  return result;
}

@end

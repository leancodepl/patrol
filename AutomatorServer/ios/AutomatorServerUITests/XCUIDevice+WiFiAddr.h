#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface XCUIDevice (WiFiAddr)

/**
 Returns device current wifi ip4 address
 */
- (nullable NSString *)wiFiIPAddress;

@end

NS_ASSUME_NONNULL_END

#if TARGET_OS_IPHONE

#import "AxeBridge.h"

@import axeDevToolsXCUI;

@implementation AxeBridge

+ (nullable id)postResultOn:(id)axe
                     result:(id)result
                       tags:(NSArray<NSString *> *)tags
                   scanName:(nullable NSString *)scanName
                      error:(NSError * _Nullable * _Nullable)error {
    if (![axe isKindOfClass:[AxeDevTools class]]) {
        if (error) {
            *error = [NSError errorWithDomain:@"pl.leancode.patrol.AxeBridge"
                                         code:1
                                     userInfo:@{NSLocalizedDescriptionKey: @"axe is not an AxeDevTools instance"}];
        }
        return nil;
    }
    if (![result isKindOfClass:[AxeResult class]]) {
        if (error) {
            *error = [NSError errorWithDomain:@"pl.leancode.patrol.AxeBridge"
                                         code:2
                                     userInfo:@{NSLocalizedDescriptionKey: @"result is not an AxeResult instance"}];
        }
        return nil;
    }
    return [(AxeDevTools *)axe postResult:(AxeResult *)result
                                 withTags:tags
                             withScanName:scanName
                                    error:error];
}

@end

#endif

NS_ASSUME_NONNULL_BEGIN

typedef void (^CallCompletion)(void);

@interface PatrolSharedObject : NSObject

- (id)init;
- (id)initWithCompletion:(CallCompletion)completion;
- (void)submitTestResults:(NSString*)message;
@end

NS_ASSUME_NONNULL_END

#import "PatrolPlugin.h"

#if TARGET_OS_IOS
@import LocalAuthentication;
#import <objc/runtime.h>
#endif

#if TARGET_OS_IOS

// Experiment: answers LocalAuthentication from the test instead of the system,
// the way device farms do. Swizzled only when a test asks for it, so the app
// never runs this outside of a Patrol test.

typedef void (^PatrolLAReply)(BOOL success, NSError *error);

static BOOL gPatrolBiometricsIntercepted = NO;
static PatrolLAReply gPatrolPendingReply = nil;
static NSInteger gPatrolFailedAttempts = 0;
static const NSInteger kPatrolMaxFailedAttempts = 5;

static void PatrolSwizzle(Class cls, SEL original, SEL replacement) {
  Method originalMethod = class_getInstanceMethod(cls, original);
  Method replacementMethod = class_getInstanceMethod(cls, replacement);
  method_exchangeImplementations(originalMethod, replacementMethod);
}

@interface LAContext (PatrolBiometrics)
@end

@implementation LAContext (PatrolBiometrics)

- (BOOL)patrol_canEvaluatePolicy:(LAPolicy)policy error:(NSError *__autoreleasing *)error {
  if (!gPatrolBiometricsIntercepted) {
    return [self patrol_canEvaluatePolicy:policy error:error];
  }
  if (gPatrolFailedAttempts >= kPatrolMaxFailedAttempts) {
    if (error) {
      *error = [NSError errorWithDomain:LAErrorDomain code:LAErrorBiometryLockout userInfo:nil];
    }
    return NO;
  }
  return YES;
}

- (LABiometryType)patrol_biometryType API_AVAILABLE(ios(11.0)) {
  if (!gPatrolBiometricsIntercepted) {
    return [self patrol_biometryType];
  }
  return LABiometryTypeFaceID;
}

- (void)patrol_evaluatePolicy:(LAPolicy)policy
              localizedReason:(NSString *)localizedReason
                        reply:(PatrolLAReply)reply {
  if (!gPatrolBiometricsIntercepted) {
    [self patrol_evaluatePolicy:policy localizedReason:localizedReason reply:reply];
    return;
  }
  @synchronized([PatrolPlugin class]) {
    gPatrolPendingReply = [reply copy];
  }
  NSLog(@"PATROL_BIOMETRICS: intercepted evaluatePolicy(%ld): %@", (long)policy, localizedReason);
}

@end

static void PatrolInstallBiometricInterception(void) {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class cls = [LAContext class];
    PatrolSwizzle(cls, @selector(canEvaluatePolicy:error:), @selector(patrol_canEvaluatePolicy:error:));
    PatrolSwizzle(cls, @selector(biometryType), @selector(patrol_biometryType));
    PatrolSwizzle(cls, @selector(evaluatePolicy:localizedReason:reply:),
                  @selector(patrol_evaluatePolicy:localizedReason:reply:));
  });
}

// Answers the pending evaluatePolicy. Returns NO if no prompt is pending.
static BOOL PatrolAnswerPendingReply(BOOL success, NSInteger errorCode) {
  PatrolLAReply reply;
  @synchronized([PatrolPlugin class]) {
    reply = gPatrolPendingReply;
    gPatrolPendingReply = nil;
  }
  if (reply == nil) {
    return NO;
  }
  NSError *error = success ? nil : [NSError errorWithDomain:LAErrorDomain code:errorCode userInfo:nil];
  // LocalAuthentication replies on a private queue, not the main one.
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
    reply(success, error);
  });
  return YES;
}

static id PatrolHandleBiometricInterception(NSString *action) {
  if ([action isEqualToString:@"enable"]) {
    PatrolInstallBiometricInterception();
    gPatrolBiometricsIntercepted = YES;
    gPatrolFailedAttempts = 0;
    return @YES;
  }
  if ([action isEqualToString:@"disable"]) {
    gPatrolBiometricsIntercepted = NO;
    return @(PatrolAnswerPendingReply(NO, LAErrorSystemCancel));
  }
  if ([action isEqualToString:@"pass"]) {
    BOOL answered = PatrolAnswerPendingReply(YES, 0);
    if (answered) {
      gPatrolFailedAttempts = 0;
    }
    return @(answered);
  }
  if ([action isEqualToString:@"fail"]) {
    BOOL pending;
    @synchronized([PatrolPlugin class]) {
      pending = gPatrolPendingReply != nil;
    }
    if (!pending) {
      return @NO;
    }
    // Like the system prompt: a failed attempt keeps it open, until lockout.
    gPatrolFailedAttempts += 1;
    if (gPatrolFailedAttempts >= kPatrolMaxFailedAttempts) {
      PatrolAnswerPendingReply(NO, LAErrorBiometryLockout);
    }
    return @YES;
  }
  if ([action isEqualToString:@"cancel"]) {
    return @(PatrolAnswerPendingReply(NO, LAErrorUserCancel));
  }
  if ([action isEqualToString:@"isPending"]) {
    @synchronized([PatrolPlugin class]) {
      return @((BOOL)(gPatrolPendingReply != nil));
    }
  }
  return nil;
}

#endif

@implementation PatrolPlugin

static NSString *const kBiometricInterceptionMethod = @"biometricInterception";
static NSString *const kChannelName = @"pl.leancode.patrol/main";
static NSString *const kGetRuntimePortsMethod = @"getRuntimePorts";


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
#if TARGET_OS_OSX
  id<FlutterBinaryMessenger> messenger = [registrar messenger];
#else
  NSObject<FlutterBinaryMessenger> *messenger = [registrar messenger];
#endif

  FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:kChannelName binaryMessenger:messenger];
  PatrolPlugin *instance = [[PatrolPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([call.method isEqualToString:kGetRuntimePortsMethod]) {
    NSDictionary<NSString *, NSString *> *environment = [NSProcessInfo processInfo].environment;
    NSMutableDictionary<NSString *, NSString *> *ports = [NSMutableDictionary dictionary];
    ports[@"testServerPort"] = environment[@"PATROL_TEST_SERVER_PORT"];
    ports[@"appServerPort"] = environment[@"PATROL_APP_SERVER_PORT"];
    ports[@"hostServerPort"] = environment[@"PATROL_HOST_SERVER_PORT"];
    result(ports);
#if TARGET_OS_IOS
  } else if ([call.method isEqualToString:kBiometricInterceptionMethod]) {
    NSString *action = call.arguments;
    id answer = PatrolHandleBiometricInterception(action);
    if (answer == nil) {
      result([FlutterError errorWithCode:@"unknown_action"
                                 message:[NSString stringWithFormat:@"Unknown action: %@", action]
                                 details:nil]);
    } else {
      result(answer);
    }
#endif
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end

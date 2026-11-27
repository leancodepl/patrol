#import "PatrolPlugin.h"

@implementation PatrolPlugin

static NSString *const kChannelName = @"pl.leancode.patrol/main";
static NSString *const kGetRuntimePortsMethod = @"getRuntimePorts";

#if TARGET_OS_IOS
// NSUserDefaults keys where permission plugins remember they already asked.
// `resetAuthorizationStatusForResource:` does not touch them.
static NSArray<NSString *> *PatrolPermissionCacheKeys(void) {
  return @[
    // permission_handler_apple: skips the location Always request once set.
    @"org.baseflow.permission_handler_apple.permission_requested",
  ];
}

// The runner sets PATROL_CLEAR_PERMISSIONS on the launch after it reset permissions.
static void PatrolClearPermissionCachesIfRequested(void) {
  if (![[NSProcessInfo processInfo].environment[@"PATROL_CLEAR_PERMISSIONS"] isEqualToString:@"1"]) {
    return;
  }
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  for (NSString *key in PatrolPermissionCacheKeys()) {
    [defaults removeObjectForKey:key];
  }
  NSLog(@"Patrol: cleared app-side permission caches: %@", PatrolPermissionCacheKeys());
}
#endif

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
#if TARGET_OS_IOS
  PatrolClearPermissionCachesIfRequested();
#endif

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
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end

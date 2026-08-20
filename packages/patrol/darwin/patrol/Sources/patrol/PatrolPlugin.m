#import "PatrolPlugin.h"

@implementation PatrolPlugin

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
    result(ports);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end

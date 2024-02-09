/// Schema supports:
// - enum definition
// - late type name - required field definition
// - type? name - optional field definition
// - abstract class - service definition where we define:
//    - ResponseModel endpointName(RequestModel) - endpoint definition (void = no response)
//    - Generic types (IOSServer, IOSClient, AndroidServer, AndroidClient, DartServer, DartClient)
//      control where we need clients and servers

class DartGroupEntry {
  late String name;
  late GroupEntryType type;
  late List<DartGroupEntry> entries;
}

enum GroupEntryType { group, test }

class ListDartTestsResponse {
  late DartGroupEntry group;
}

enum RunDartTestResponseResult {
  success,
  skipped,
  failure,
}

class RunDartTestRequest {
  late String name;
}

class RunDartTestResponse {
  late RunDartTestResponseResult result;
  String? details;
}

abstract class PatrolAppService<IOSClient, AndroidClient, DartServer> {
  ListDartTestsResponse listDartTests();
  RunDartTestResponse runDartTest(RunDartTestRequest request);
}

class ConfigureRequest {
  late int findTimeoutMillis;
}

class OpenAppRequest {
  late String appId;
}

class OpenQuickSettingsRequest {}

class Selector {
  String? text;
  String? textStartsWith;
  String? textContains;
  String? className;
  String? contentDescription;
  String? contentDescriptionStartsWith;
  String? contentDescriptionContains;
  String? resourceId;
  int? instance;
  bool? enabled;
  bool? focused;
  String? pkg;
}

class GetNativeViewsRequest {
  late Selector selector;
  late String appId;
}

class GetNativeUITreeRequest {
  List<String>? iosInstalledApps;
}

class GetNativeUITreeRespone {
  late List<NativeView> roots;
}

class NativeView {
  String? className;
  String? text;
  String? contentDescription;
  late bool focused;
  late bool enabled;
  int? childCount;
  String? resourceName;
  String? applicationPackage;
  late List<NativeView> children;
}

class GetNativeViewsResponse {
  late List<NativeView> nativeViews;
}

class TapRequest {
  late Selector selector;
  late String appId;
  int? timeoutMillis;
}

class TapAtRequest {
  late double x;
  late double y;
  late String appId;
}

enum KeyboardBehavior {
  showAndDismiss,
  alternative,
}

class EnterTextRequest {
  late String data;
  late String appId;
  int? index;
  Selector? selector;
  late KeyboardBehavior keyboardBehavior;
  int? timeoutMillis;
}

class SwipeRequest {
  late String appId;
  late double startX;
  late double startY;
  late double endX;
  late double endY;
  late int steps;
}

class WaitUntilVisibleRequest {
  late Selector selector;
  late String appId;
  int? timeoutMillis;
}

class DarkModeRequest {
  late String appId;
}

class Notification {
  String? appName;
  late String title;
  late String content;
  String? raw;
}

class GetNotificationsResponse {
  late List<Notification> notifications;
}

class GetNotificationsRequest {}

class TapOnNotificationRequest {
  int? index;
  Selector? selector;
  int? timeoutMillis;
}

class PermissionDialogVisibleResponse {
  late bool visible;
}

class PermissionDialogVisibleRequest {
  late int timeoutMillis;
}

enum HandlePermissionRequestCode {
  whileUsing,
  onlyThisTime,
  denied,
}

class HandlePermissionRequest {
  late HandlePermissionRequestCode code;
}

enum SetLocationAccuracyRequestLocationAccuracy {
  coarse,
  fine,
}

class SetLocationAccuracyRequest {
  late SetLocationAccuracyRequestLocationAccuracy locationAccuracy;
}

abstract class NativeAutomator<IOSServer, AndroidServer, DartClient> {
  void initialize();
  void configure(ConfigureRequest request);

// general
  void pressHome();
  void pressBack();
  void pressRecentApps();
  void doublePressRecentApps();
  void openApp(OpenAppRequest request);
  void openQuickSettings(OpenQuickSettingsRequest request);

// general UI interaction
  GetNativeUITreeRespone getNativeUITree(GetNativeUITreeRequest request);
  GetNativeViewsResponse getNativeViews(GetNativeViewsRequest request);
  void tap(TapRequest request);
  void doubleTap(TapRequest request);
  void tapAt(TapAtRequest request);
  void enterText(EnterTextRequest request);
  void swipe(SwipeRequest request);
  void waitUntilVisible(WaitUntilVisibleRequest request);

// services
  void enableAirplaneMode();
  void disableAirplaneMode();
  void enableWiFi();
  void disableWiFi();
  void enableCellular();
  void disableCellular();
  void enableBluetooth();
  void disableBluetooth();
  void enableDarkMode(DarkModeRequest request);
  void disableDarkMode(DarkModeRequest request);

// notifications
  void openNotifications();
  void closeNotifications();
  void closeHeadsUpNotification();
  GetNotificationsResponse getNotifications(GetNotificationsRequest request);
  void tapOnNotification(TapOnNotificationRequest request);

// permissions
  PermissionDialogVisibleResponse isPermissionDialogVisible(
      PermissionDialogVisibleRequest request);
  void handlePermissionDialog(HandlePermissionRequest request);
  void setLocationAccuracy(SetLocationAccuracyRequest request);

// other
  void debug();

// TODO(bartekpacia): Move this RPC into a new PatrolNativeTestService service because it doesn't fit here
  void markPatrolAppServiceReady();
}

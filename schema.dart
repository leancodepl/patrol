class DartTestCase {
  late String name;
}

class DartTestGroup {
  late String name;
  late List<DartTestCase> tests;
  late List<DartTestGroup> groups;
}

class ListDartTestsResponse {
  late DartTestGroup group;
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

class NativeView {
  late String className;
  late String text;
  late String contentDescription;
  late bool focused;
  late bool enabled;
  late int childCount;
  late String resourceName;
  late String applicationPackage;
  late List<NativeView> children;
}

class GetNativeViewsResponse {
  late List<NativeView> nativeViews;
}

class TapRequest {
  late Selector selector;
  late String appId;
}

class EnterTextRequest {
  late String data;
  late String appId;
  int? index;
  Selector? selector;
  late bool showKeyboard;
}

class SwipeRequest {
  late double startX;
  late double startY;
  late double endX;
  late double endY;
  late int steps;
}

class WaitUntilVisibleRequest {
  late Selector selector;
  late String appId;
}

class DarkModeRequest {
  late String appId;
}

class Notification {
  String? appName;
  late String title;
  late String content;
  late String raw;
}

class GetNotificationsResponse {
  late List<Notification> notifications;
}

class GetNotificationsRequest {}

class TapOnNotificationRequest {
  int? index;
  Selector? selector;
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
  GetNativeViewsResponse getNativeViews(GetNativeViewsRequest request);
  void tap(TapRequest request);
  void doubleTap(TapRequest request);
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

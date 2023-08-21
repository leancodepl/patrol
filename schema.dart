class DartTestCase {
  late String name;
}

class DartTestGroup {
  String? name;
  List<DartTestCase>? tests;
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
  String? name;
}

class RunDartTestResponse {
  late RunDartTestResponseResult result;
  String? details;
}

abstract class PatrolAppService<IOSClient, DartServer> {
  ListDartTestsResponse listDartTests();
  RunDartTestResponse runDartTest(RunDartTestRequest request);
}

class ConfigureRequest {
  late int findTimeoutMillis;
}

class OpenAppRequest {
  String? appId;
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
  Selector? selector;
  String? appId;
}

class NativeView {
  String? className;
  String? text;
  String? contentDescription;
  bool? focused;
  bool? enabled;
  int? childCount;
  String? resourceName;
  String? applicationPackage;
  List<NativeView>? children;
}

class GetNativeViewsResponse {
  List<NativeView>? nativeViews;
}

class TapRequest {
  Selector? selector;
  String? appId;
}

class EnterTextRequest {
  String? data;
  String? appId;
  int? index;
  Selector? selector;
  bool? showKeyboard;
}

class SwipeRequest {
  double? startX;
  double? startY;
  double? endX;
  double? endY;
  int? steps;
  String? appId;
}

class WaitUntilVisibleRequest {
  Selector? selector;
  String? appId;
}

class DarkModeRequest {
  String? appId;
}

class Notification {
  String? appName;
  String? title;
  String? content;
  String? raw;
}

class GetNotificationsResponse {
  List<Notification>? notifications;
}

class GetNotificationsRequest {}

class TapOnNotificationRequest {
  int? index;
  Selector? selector;
}

class PermissionDialogVisibleResponse {
  bool? visible;
}

class PermissionDialogVisibleRequest {
  int? timeoutMillis;
}

enum HandlePermissionRequestCode {
  whileUsing,
  onlyThisTime,
  denied,
}

class HandlePermissionRequest {
  HandlePermissionRequestCode? code;
}

enum SetLocationAccuracyRequestLocationAccuracy {
  coarse,
  fine,
}

class SetLocationAccuracyRequest {
  SetLocationAccuracyRequestLocationAccuracy? locationAccuracy;
}

abstract class NativeAutomator<IOSServer, DartClient> {
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

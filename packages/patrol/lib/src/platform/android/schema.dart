// ignore_for_file: type=lint

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
  late bool skip;
  late List<String> tags;
}

enum GroupEntryType { group, test }

class ListDartTestsResponse {
  late DartGroupEntry group;
}

enum RunDartTestResponseResult { success, skipped, failure }

class RunDartTestRequest {
  late String name;
}

class RunDartTestResponse {
  late RunDartTestResponseResult result;
  String? details;
}

abstract class PatrolAppService<AndroidClient, DartServer> {
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

class OpenUrlRequest {
  late String url;
}

class Selector {
  String? className;
  bool? isCheckable;
  bool? isChecked;
  bool? isClickable;
  bool? isEnabled;
  bool? isFocusable;
  bool? isFocused;
  bool? isLongClickable;
  bool? isScrollable;
  bool? isSelected;
  String? applicationPackage;
  String? contentDescription;
  String? contentDescriptionStartsWith;
  String? contentDescriptionContains;
  String? text;
  String? textStartsWith;
  String? textContains;
  String? resourceName;
  int? instance;
}

class GetNativeViewsRequest {
  late Selector selector;
  late String appId;
}

class GetNativeUITreeRequest {
  late bool useNativeViewHierarchy;
}

class GetNativeUITreeRespone {
  late List<NativeView> roots;
}

class NativeView {
  String? resourceName;
  String? text;
  String? className;
  String? contentDescription;
  String? applicationPackage;
  late int childCount;
  late bool isCheckable;
  late bool isChecked;
  late bool isClickable;
  late bool isEnabled;
  late bool isFocusable;
  late bool isFocused;
  late bool isLongClickable;
  late bool isScrollable;
  late bool isSelected;
  late Rectangle visibleBounds;
  late Point2D visibleCenter;
  late List<NativeView> children;
}

class Rectangle {
  late double minX;
  late double minY;
  late double maxX;
  late double maxY;
}

class Point2D {
  late double x;
  late double y;
}

class GetNativeViewsResponse {
  late List<NativeView> nativeViews;
}

class TapRequest {
  late Selector selector;
  late String appId;
  int? timeoutMillis;
  int? delayBetweenTapsMillis;
}

class TapAtRequest {
  late double x;
  late double y;
  late String appId;
}

enum KeyboardBehavior { showAndDismiss, alternative }

class EnterTextRequest {
  late String data;
  late String appId;
  int? index;
  Selector? selector;
  late KeyboardBehavior keyboardBehavior;
  int? timeoutMillis;
  double? dx;
  double? dy;
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

enum HandlePermissionRequestCode { whileUsing, onlyThisTime, denied }

class HandlePermissionRequest {
  late HandlePermissionRequestCode code;
}

enum SetLocationAccuracyRequestLocationAccuracy { coarse, fine }

class SetLocationAccuracyRequest {
  late SetLocationAccuracyRequestLocationAccuracy locationAccuracy;
}

class SetMockLocationRequest {
  late double latitude;
  late double longitude;
  late String packageName;
}

class IsVirtualDeviceResponse {
  late bool isVirtualDevice;
}

class GetOsVersionResponse {
  late int osVersion;
}

class TakeCameraPhotoRequest {
  late Selector? shutterButtonSelector;
  late Selector? doneButtonSelector;
  late int? timeoutMillis;
  late String appId;
}

class PickImageFromGalleryRequest {
  late Selector? imageSelector;
  late int? imageIndex;
  late int? timeoutMillis;
  late String appId;
}

class PickMultipleImagesFromGalleryRequest {
  late Selector? imageSelector;
  late List<int> imageIndexes;
  late int? timeoutMillis;
  late String appId;
}

abstract class NativeAutomator<AndroidServer, DartClient> {
  void initialize();
  void configure(ConfigureRequest request);

  // general
  void pressHome();
  void pressBack();
  void pressRecentApps();
  void doublePressRecentApps();
  void openApp(OpenAppRequest request);
  void openQuickSettings(OpenQuickSettingsRequest request);
  void openUrl(OpenUrlRequest request);

  // general UI interaction
  GetNativeUITreeRespone getNativeUITree(GetNativeUITreeRequest request);
  GetNativeViewsResponse getNativeViews(GetNativeViewsRequest request);
  void tap(TapRequest request);
  void doubleTap(TapRequest request);
  void tapAt(TapAtRequest request);
  void enterText(EnterTextRequest request);
  void swipe(SwipeRequest request);
  void waitUntilVisible(WaitUntilVisibleRequest request);

  // volume settings
  void pressVolumeUp();
  void pressVolumeDown();

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
  void enableLocation();
  void disableLocation();

  // notifications
  void openNotifications();
  void closeNotifications();
  GetNotificationsResponse getNotifications(GetNotificationsRequest request);
  void tapOnNotification(TapOnNotificationRequest request);

  // permissions
  PermissionDialogVisibleResponse isPermissionDialogVisible(
    PermissionDialogVisibleRequest request,
  );
  void handlePermissionDialog(HandlePermissionRequest request);
  void setLocationAccuracy(SetLocationAccuracyRequest request);

  // camera
  void takeCameraPhoto(TakeCameraPhotoRequest request);
  void pickImageFromGallery(PickImageFromGalleryRequest request);
  void pickMultipleImagesFromGallery(
    PickMultipleImagesFromGalleryRequest request,
  );

  // other
  void setMockLocation(SetMockLocationRequest request);

  // TODO(bartekpacia): Move this RPC into a new PatrolNativeTestService service because it doesn't fit here
  void markPatrolAppServiceReady();

  IsVirtualDeviceResponse isVirtualDevice();

  GetOsVersionResponse getOsVersion();
}

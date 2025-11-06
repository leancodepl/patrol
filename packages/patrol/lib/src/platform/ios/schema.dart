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

abstract class PatrolAppService<IOSClient, DartServer> {
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
  String? value;
  int? instance;
  IOSElementType? elementType;
  String? identifier;
  String? text;
  String? textStartsWith;
  String? textContains;
  String? label;
  String? labelStartsWith;
  String? labelContains;
  String? title;
  String? titleStartsWith;
  String? titleContains;
  bool? hasFocus;
  bool? isEnabled;
  bool? isSelected;
  String? placeholderValue;
  String? placeholderValueStartsWith;
  String? placeholderValueContains;
}

class GetNativeViewsRequest {
  Selector? selector;
  late String appId;
}

class GetNativeUITreeRequest {
  List<String>? iosInstalledApps;
  late bool useNativeViewHierarchy;
}

class GetNativeUITreeRespone {
  late List<NativeView> roots;
}

class NativeView {
  late List<NativeView> children;
  late IOSElementType elementType;
  late String identifier;
  late String label;
  late String title;
  late bool hasFocus;
  late bool isEnabled;
  late bool isSelected;
  late Rectangle frame;
  String? placeholderValue;
  String? value;
  //TODO we can get other properties from XCUIElement in next request
  // exists, isHittable,normalizedSliderPosition, accessibilityLabel, accessbilityHint, accessibilityValue, isAccessibilityElement etc..;
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
  Selector? selector;
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

abstract class NativeAutomator<IOSServer, DartClient> {
  void initialize();
  void configure(ConfigureRequest request);

  // general
  void pressHome();
  void pressRecentApps();
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
  void closeHeadsUpNotification();
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
  void debug();
  void setMockLocation(SetMockLocationRequest request);

  // TODO(bartekpacia): Move this RPC into a new PatrolNativeTestService service because it doesn't fit here
  void markPatrolAppServiceReady();

  IsVirtualDeviceResponse isVirtualDevice();

  GetOsVersionResponse getOsVersion();
}

enum IOSElementType {
  any,
  other,
  application,
  group,
  window,
  sheet,
  drawer,
  alert,
  dialog,
  button,
  radioButton,
  radioGroup,
  checkBox,
  disclosureTriangle,
  popUpButton,
  comboBox,
  menuButton,
  toolbarButton,
  popover,
  keyboard,
  key,
  navigationBar,
  tabBar,
  tabGroup,
  toolbar,
  statusBar,
  table,
  tableRow,
  tableColumn,
  outline,
  outlineRow,
  browser,
  collectionView,
  slider,
  pageIndicator,
  progressIndicator,
  activityIndicator,
  segmentedControl,
  picker,
  pickerWheel,
  switch_,
  toggle,
  link,
  image,
  icon,
  searchField,
  scrollView,
  scrollBar,
  staticText,
  textField,
  secureTextField,
  datePicker,
  textView,
  menu,
  menuItem,
  menuBar,
  menuBarItem,
  map,
  webView,
  incrementArrow,
  decrementArrow,
  timeline,
  ratingIndicator,
  valueIndicator,
  splitGroup,
  splitter,
  relevanceIndicator,
  colorWell,
  helpTag,
  matte,
  dockItem,
  ruler,
  rulerMarker,
  grid,
  levelIndicator,
  cell,
  layoutArea,
  layoutItem,
  handle,
  stepper,
  tab,
  touchBar,
  statusItem,
}

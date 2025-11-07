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

class OpenUrlRequest {
  late String url;
}

class AndroidSelector {
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

class IOSSelector {
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

class AndroidGetNativeViewsRequest {
  AndroidSelector? selector;
}

class IOSGetNativeViewsRequest {
  IOSSelector? selector;
  late String appId;
}

class IOSGetNativeUITreeRequest {
  List<String>? iosInstalledApps;
}

class AndroidNativeView {
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
  late List<AndroidNativeView> children;
}

class IOSNativeView {
  late List<IOSNativeView> children;
  late IOSElementType elementType;
  late String identifier;
  late String label;
  late String title;
  late bool hasFocus;
  late bool isEnabled;
  late bool isSelected;
  late Rectangle frame;
  late String? accessibilityLabel;
  String? placeholderValue;
  String? value;
  //TODO we can get other properties from XCUIElement in next request
  // exists, isHittable,normalizedSliderPosition, accessibilityLabel, accessbilityHint, accessibilityValue, isAccessibilityElement etc..;
}

class AndroidGetNativeUITreeResponse {
  late List<AndroidNativeView> roots;
}

class IOSGetNativeUITreeResponse {
  late List<IOSNativeView> roots;
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

class AndroidTapRequest {
  late AndroidSelector? selector;
  int? timeoutMillis;
  int? delayBetweenTapsMillis;
}

class IOSTapRequest {
  late IOSSelector selector;
  late String appId;
  int? timeoutMillis;
}

class AndroidTapAtRequest {
  late double x;
  late double y;
}

class IOSTapAtRequest {
  late double x;
  late double y;
  late String appId;
}

enum KeyboardBehavior { showAndDismiss, alternative }

class AndroidEnterTextRequest {
  late String data;
  int? index;
  AndroidSelector? selector;
  late KeyboardBehavior keyboardBehavior;
  int? timeoutMillis;
  double? dx;
  double? dy;
}

class IOSEnterTextRequest {
  late String data;
  late String appId;
  int? index;
  IOSSelector? selector;
  late KeyboardBehavior keyboardBehavior;
  int? timeoutMillis;
  double? dx;
  double? dy;
}

class AndroidSwipeRequest {
  late double startX;
  late double startY;
  late double endX;
  late double endY;
  late int steps;
}

class IOSSwipeRequest {
  late String appId;
  late double startX;
  late double startY;
  late double endX;
  late double endY;
}

class AndroidWaitUntilVisibleRequest {
  late AndroidSelector selector;
  int? timeoutMillis;
}

class IOSTwaitUntilVisibleRequest {
  late IOSSelector selector;
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

class AndroidTapOnNotificationRequest {
  int? index;
  late AndroidSelector? selector;
  int? timeoutMillis;
}

class IOSTapOnNotificationRequest {
  int? index;
  IOSSelector? selector;
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

class AndroidTakeCameraPhotoRequest {
  AndroidSelector? shutterButtonSelector;
  AndroidSelector? doneButtonSelector;
  late int? timeoutMillis;
}

class IOSTakeCameraPhotoRequest {
  IOSSelector? shutterButtonSelector;
  IOSSelector? doneButtonSelector;
  late int? timeoutMillis;
  late String appId;
}

class AndroidPickImageFromGalleryRequest {
  late AndroidSelector? imageSelector;
  late int? imageIndex;
  late int? timeoutMillis;
}

class IOSPickImageFromGalleryRequest {
  late IOSSelector? imageSelector;
  late int? imageIndex;
  late int? timeoutMillis;
  late String appId;
}

class AndroidPickMultipleImagesFromGalleryRequest {
  late AndroidSelector? imageSelector;
  late List<int> imageIndexes;
  late int? timeoutMillis;
}

class IOSPickMultipleImagesFromGalleryRequest {
  late IOSSelector? imageSelector;
  late List<int> imageIndexes;
  late int? timeoutMillis;
  late String appId;
}

abstract class MobileAutomator<IOSServer, AndroidServer, DartClient> {
  void initialize();
  void configure(ConfigureRequest request);

  // general
  void pressHome();
  void pressRecentApps();
  void openApp(OpenAppRequest request);
  void openQuickSettings(OpenQuickSettingsRequest request);
  void openUrl(OpenUrlRequest request);

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

  // notifications
  void openNotifications();
  void closeNotifications();
  GetNotificationsResponse getNotifications(GetNotificationsRequest request);

  // permissions
  PermissionDialogVisibleResponse isPermissionDialogVisible(
    PermissionDialogVisibleRequest request,
  );
  void handlePermissionDialog(HandlePermissionRequest request);
  void setLocationAccuracy(SetLocationAccuracyRequest request);

  // other
  void debug();
  void setMockLocation(SetMockLocationRequest request);

  // TODO(bartekpacia): Move this RPC into a new PatrolNativeTestService service because it doesn't fit here
  void markPatrolAppServiceReady();

  IsVirtualDeviceResponse isVirtualDevice();

  GetOsVersionResponse getOsVersion();
}

abstract class AndroidAutomator<AndroidServer, DartClient> {
  void pressBack();
  void doublePressRecentApps();

  // general UI interaction
  AndroidGetNativeUITreeResponse getNativeUITree();
  AndroidGetNativeUITreeResponse getNativeViews(
    AndroidGetNativeViewsRequest request,
  );
  void tap(AndroidTapRequest request);
  void doubleTap(AndroidTapRequest request);
  void tapAt(AndroidTapAtRequest request);
  void enterText(AndroidEnterTextRequest request);
  void waitUntilVisible(AndroidWaitUntilVisibleRequest request);
  void swipe(AndroidSwipeRequest request);

  // services
  void enableLocation();
  void disableLocation();

  // notifications
  void tapOnNotification(AndroidTapOnNotificationRequest request);

  // camera
  void takeCameraPhoto(AndroidTakeCameraPhotoRequest request);
  void pickImageFromGallery(AndroidPickImageFromGalleryRequest request);
  void pickMultipleImagesFromGallery(
    AndroidPickMultipleImagesFromGalleryRequest request,
  );
}

abstract class IosAutomator<IOSServer, DartClient> {
  // general UI interaction
  IOSGetNativeUITreeResponse getNativeUITree(IOSGetNativeUITreeRequest request);
  IOSGetNativeUITreeResponse getNativeViews(IOSGetNativeViewsRequest request);
  void tap(IOSTapRequest request);
  void doubleTap(IOSTapRequest request);
  void enterText(IOSEnterTextRequest request);
  void tapAt(IOSTapAtRequest request);
  void waitUntilVisible(IOSTwaitUntilVisibleRequest request);
  void swipe(IOSSwipeRequest request);

  // notifications
  void closeHeadsUpNotification();
  void tapOnNotification(IOSTapOnNotificationRequest request);

  // permissions
  PermissionDialogVisibleResponse isPermissionDialogVisible(
    PermissionDialogVisibleRequest request,
  );
  void handlePermissionDialog(HandlePermissionRequest request);
  void setLocationAccuracy(SetLocationAccuracyRequest request);

  // camera
  void takeCameraPhoto(IOSTakeCameraPhotoRequest request);
  void pickImageFromGallery(IOSPickImageFromGalleryRequest request);
  void pickMultipleImagesFromGallery(
    IOSPickMultipleImagesFromGalleryRequest request,
  );
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

//
//  Generated code. Do not modify.
//  source: schema.dart
//

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contracts.g.dart';

enum GroupEntryType {
  group('group'),
  test('test');

  const GroupEntryType(this.value);
  final String value;
}

enum RunDartTestResponseResult {
  success('success'),
  skipped('skipped'),
  failure('failure');

  const RunDartTestResponseResult(this.value);
  final String value;
}

enum KeyboardBehavior {
  showAndDismiss('showAndDismiss'),
  alternative('alternative');

  const KeyboardBehavior(this.value);
  final String value;
}

enum HandlePermissionRequestCode {
  whileUsing('whileUsing'),
  onlyThisTime('onlyThisTime'),
  denied('denied');

  const HandlePermissionRequestCode(this.value);
  final String value;
}

enum SetLocationAccuracyRequestLocationAccuracy {
  coarse('coarse'),
  fine('fine');

  const SetLocationAccuracyRequestLocationAccuracy(this.value);
  final String value;
}

enum IOSElementType {
  any('any'),
  other('other'),
  application('application'),
  group('group'),
  window('window'),
  sheet('sheet'),
  drawer('drawer'),
  alert('alert'),
  dialog('dialog'),
  button('button'),
  radioButton('radioButton'),
  radioGroup('radioGroup'),
  checkBox('checkBox'),
  disclosureTriangle('disclosureTriangle'),
  popUpButton('popUpButton'),
  comboBox('comboBox'),
  menuButton('menuButton'),
  toolbarButton('toolbarButton'),
  popover('popover'),
  keyboard('keyboard'),
  key('key'),
  navigationBar('navigationBar'),
  tabBar('tabBar'),
  tabGroup('tabGroup'),
  toolbar('toolbar'),
  statusBar('statusBar'),
  table('table'),
  tableRow('tableRow'),
  tableColumn('tableColumn'),
  outline('outline'),
  outlineRow('outlineRow'),
  browser('browser'),
  collectionView('collectionView'),
  slider('slider'),
  pageIndicator('pageIndicator'),
  progressIndicator('progressIndicator'),
  activityIndicator('activityIndicator'),
  segmentedControl('segmentedControl'),
  picker('picker'),
  pickerWheel('pickerWheel'),
  switch_('switch_'),
  toggle('toggle'),
  link('link'),
  image('image'),
  icon('icon'),
  searchField('searchField'),
  scrollView('scrollView'),
  scrollBar('scrollBar'),
  staticText('staticText'),
  textField('textField'),
  secureTextField('secureTextField'),
  datePicker('datePicker'),
  textView('textView'),
  menu('menu'),
  menuItem('menuItem'),
  menuBar('menuBar'),
  menuBarItem('menuBarItem'),
  map('map'),
  webView('webView'),
  incrementArrow('incrementArrow'),
  decrementArrow('decrementArrow'),
  timeline('timeline'),
  ratingIndicator('ratingIndicator'),
  valueIndicator('valueIndicator'),
  splitGroup('splitGroup'),
  splitter('splitter'),
  relevanceIndicator('relevanceIndicator'),
  colorWell('colorWell'),
  helpTag('helpTag'),
  matte('matte'),
  dockItem('dockItem'),
  ruler('ruler'),
  rulerMarker('rulerMarker'),
  grid('grid'),
  levelIndicator('levelIndicator'),
  cell('cell'),
  layoutArea('layoutArea'),
  layoutItem('layoutItem'),
  handle('handle'),
  stepper('stepper'),
  tab('tab'),
  touchBar('touchBar'),
  statusItem('statusItem');

  const IOSElementType(this.value);
  final String value;
}

enum GoogleApp {
  calculator('com.google.android.calculator'),
  calendar('com.google.android.calendar'),
  chrome('com.android.chrome'),
  drive('com.google.android.apps.docs'),
  gmail('com.google.android.gm'),
  maps('com.google.android.apps.maps'),
  photos('com.google.android.apps.photos'),
  playStore('com.android.vending'),
  settings('com.android.settings'),
  youtube('com.google.android.youtube');

  const GoogleApp(this.value);
  final String value;
}

enum AppleApp {
  appStore('com.apple.AppStore'),
  appleStore('com.apple.store.Jolly'),
  barcodeScanner('com.apple.BarcodeScanner'),
  books('com.apple.iBooks'),
  calculator('com.apple.calculator'),
  calendar('com.apple.mobilecal'),
  camera('com.apple.camera'),
  clips('com.apple.clips'),
  clock('com.apple.mobiletimer'),
  compass('com.apple.compass'),
  contacts('com.apple.MobileAddressBook'),
  developer('developer.apple.wwdc-Release'),
  faceTime('com.apple.facetime'),
  files('com.apple.DocumentsApp'),
  findMy('com.apple.findmy'),
  fitness('com.apple.Fitness'),
  freeform('com.apple.freeform'),
  garageBand('com.apple.mobilegarageband'),
  health('com.apple.Health'),
  home('com.apple.Home'),
  iCloudDrive('com.apple.iCloudDriveApp'),
  imagePlayground('com.apple.GenerativePlaygroundApp'),
  iMovie('com.apple.iMovie'),
  invites('com.apple.rsvp'),
  iTunesStore('com.apple.MobileStore'),
  journal('com.apple.journal'),
  keynote('com.apple.Keynote'),
  magnifier('com.apple.Magnifier'),
  mail('com.apple.mobilemail'),
  maps('com.apple.Maps'),
  measure('com.apple.measure'),
  messages('com.apple.MobileSMS'),
  music('com.apple.Music'),
  news('com.apple.news'),
  notes('com.apple.mobilenotes'),
  numbers('com.apple.Numbers'),
  pages('com.apple.Pages'),
  passwords('com.apple.Passwords'),
  phone('com.apple.mobilephone'),
  photoBooth('com.apple.Photo-Booth'),
  photos('com.apple.mobileslideshow'),
  podcasts('com.apple.podcasts'),
  reminders('com.apple.reminders'),
  safari('com.apple.mobilesafari'),
  settings('com.apple.Preferences'),
  shortcuts('com.apple.shortcuts'),
  stocks('com.apple.stocks'),
  swiftPlaygrounds('com.apple.Playgrounds'),
  tips('com.apple.tips'),
  translate('com.apple.Translate'),
  tv('com.apple.tv'),
  voiceMemos('com.apple.VoiceMemos'),
  wallet('com.apple.Passbook'),
  watch('com.apple.Bridge'),
  weather('com.apple.weather');

  const AppleApp(this.value);
  final String value;
}

@JsonSerializable()
class DartGroupEntry with EquatableMixin {
  DartGroupEntry({
    required this.name,
    required this.type,
    required this.entries,
    required this.skip,
    required this.tags,
  });

  factory DartGroupEntry.fromJson(Map<String, dynamic> json) =>
      _$DartGroupEntryFromJson(json);

  final String name;
  final GroupEntryType type;
  final List<DartGroupEntry> entries;
  final bool skip;
  final List<String> tags;

  Map<String, dynamic> toJson() => _$DartGroupEntryToJson(this);

  @override
  List<Object?> get props => [name, type, entries, skip, tags];
}

@JsonSerializable()
class ListDartTestsResponse with EquatableMixin {
  ListDartTestsResponse({required this.group});

  factory ListDartTestsResponse.fromJson(Map<String, dynamic> json) =>
      _$ListDartTestsResponseFromJson(json);

  final DartGroupEntry group;

  Map<String, dynamic> toJson() => _$ListDartTestsResponseToJson(this);

  @override
  List<Object?> get props => [group];
}

@JsonSerializable()
class RunDartTestRequest with EquatableMixin {
  RunDartTestRequest({required this.name});

  factory RunDartTestRequest.fromJson(Map<String, dynamic> json) =>
      _$RunDartTestRequestFromJson(json);

  final String name;

  Map<String, dynamic> toJson() => _$RunDartTestRequestToJson(this);

  @override
  List<Object?> get props => [name];
}

@JsonSerializable()
class RunDartTestResponse with EquatableMixin {
  RunDartTestResponse({required this.result, this.details});

  factory RunDartTestResponse.fromJson(Map<String, dynamic> json) =>
      _$RunDartTestResponseFromJson(json);

  final RunDartTestResponseResult result;
  final String? details;

  Map<String, dynamic> toJson() => _$RunDartTestResponseToJson(this);

  @override
  List<Object?> get props => [result, details];
}

@JsonSerializable()
class ConfigureRequest with EquatableMixin {
  ConfigureRequest({required this.findTimeoutMillis});

  factory ConfigureRequest.fromJson(Map<String, dynamic> json) =>
      _$ConfigureRequestFromJson(json);

  final int findTimeoutMillis;

  Map<String, dynamic> toJson() => _$ConfigureRequestToJson(this);

  @override
  List<Object?> get props => [findTimeoutMillis];
}

@JsonSerializable()
class OpenAppRequest with EquatableMixin {
  OpenAppRequest({required this.appId});

  factory OpenAppRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenAppRequestFromJson(json);

  final String appId;

  Map<String, dynamic> toJson() => _$OpenAppRequestToJson(this);

  @override
  List<Object?> get props => [appId];
}

@JsonSerializable()
class AndroidOpenPlatformAppRequest with EquatableMixin {
  AndroidOpenPlatformAppRequest({required this.androidAppId});

  factory AndroidOpenPlatformAppRequest.fromJson(Map<String, dynamic> json) =>
      _$AndroidOpenPlatformAppRequestFromJson(json);

  final String androidAppId;

  Map<String, dynamic> toJson() => _$AndroidOpenPlatformAppRequestToJson(this);

  @override
  List<Object?> get props => [androidAppId];
}

@JsonSerializable()
class IOSOpenPlatformAppRequest with EquatableMixin {
  IOSOpenPlatformAppRequest({required this.iosAppId});

  factory IOSOpenPlatformAppRequest.fromJson(Map<String, dynamic> json) =>
      _$IOSOpenPlatformAppRequestFromJson(json);

  final String iosAppId;

  Map<String, dynamic> toJson() => _$IOSOpenPlatformAppRequestToJson(this);

  @override
  List<Object?> get props => [iosAppId];
}

@JsonSerializable()
class OpenQuickSettingsRequest with EquatableMixin {
  OpenQuickSettingsRequest();

  factory OpenQuickSettingsRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenQuickSettingsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OpenQuickSettingsRequestToJson(this);

  @override
  List<Object?> get props => const [];
}

@JsonSerializable()
class OpenUrlRequest with EquatableMixin {
  OpenUrlRequest({required this.url});

  factory OpenUrlRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenUrlRequestFromJson(json);

  final String url;

  Map<String, dynamic> toJson() => _$OpenUrlRequestToJson(this);

  @override
  List<Object?> get props => [url];
}

@JsonSerializable()
class AndroidSelector with EquatableMixin {
  AndroidSelector({
    this.className,
    this.isCheckable,
    this.isChecked,
    this.isClickable,
    this.isEnabled,
    this.isFocusable,
    this.isFocused,
    this.isLongClickable,
    this.isScrollable,
    this.isSelected,
    this.applicationPackage,
    this.contentDescription,
    this.contentDescriptionStartsWith,
    this.contentDescriptionContains,
    this.text,
    this.textStartsWith,
    this.textContains,
    this.resourceName,
    this.instance,
  });

  factory AndroidSelector.fromJson(Map<String, dynamic> json) =>
      _$AndroidSelectorFromJson(json);

  final String? className;
  final bool? isCheckable;
  final bool? isChecked;
  final bool? isClickable;
  final bool? isEnabled;
  final bool? isFocusable;
  final bool? isFocused;
  final bool? isLongClickable;
  final bool? isScrollable;
  final bool? isSelected;
  final String? applicationPackage;
  final String? contentDescription;
  final String? contentDescriptionStartsWith;
  final String? contentDescriptionContains;
  final String? text;
  final String? textStartsWith;
  final String? textContains;
  final String? resourceName;
  final int? instance;

  Map<String, dynamic> toJson() => _$AndroidSelectorToJson(this);

  @override
  List<Object?> get props => [
    className,
    isCheckable,
    isChecked,
    isClickable,
    isEnabled,
    isFocusable,
    isFocused,
    isLongClickable,
    isScrollable,
    isSelected,
    applicationPackage,
    contentDescription,
    contentDescriptionStartsWith,
    contentDescriptionContains,
    text,
    textStartsWith,
    textContains,
    resourceName,
    instance,
  ];
}

@JsonSerializable()
class IOSSelector with EquatableMixin {
  IOSSelector({
    this.value,
    this.instance,
    this.elementType,
    this.identifier,
    this.text,
    this.textStartsWith,
    this.textContains,
    this.label,
    this.labelStartsWith,
    this.labelContains,
    this.title,
    this.titleStartsWith,
    this.titleContains,
    this.hasFocus,
    this.isEnabled,
    this.isSelected,
    this.placeholderValue,
    this.placeholderValueStartsWith,
    this.placeholderValueContains,
  });

  factory IOSSelector.fromJson(Map<String, dynamic> json) =>
      _$IOSSelectorFromJson(json);

  final String? value;
  final int? instance;
  final IOSElementType? elementType;
  final String? identifier;
  final String? text;
  final String? textStartsWith;
  final String? textContains;
  final String? label;
  final String? labelStartsWith;
  final String? labelContains;
  final String? title;
  final String? titleStartsWith;
  final String? titleContains;
  final bool? hasFocus;
  final bool? isEnabled;
  final bool? isSelected;
  final String? placeholderValue;
  final String? placeholderValueStartsWith;
  final String? placeholderValueContains;

  Map<String, dynamic> toJson() => _$IOSSelectorToJson(this);

  @override
  List<Object?> get props => [
    value,
    instance,
    elementType,
    identifier,
    text,
    textStartsWith,
    textContains,
    label,
    labelStartsWith,
    labelContains,
    title,
    titleStartsWith,
    titleContains,
    hasFocus,
    isEnabled,
    isSelected,
    placeholderValue,
    placeholderValueStartsWith,
    placeholderValueContains,
  ];
}

@JsonSerializable()
class AndroidGetNativeViewsRequest with EquatableMixin {
  AndroidGetNativeViewsRequest({this.selector});

  factory AndroidGetNativeViewsRequest.fromJson(Map<String, dynamic> json) =>
      _$AndroidGetNativeViewsRequestFromJson(json);

  final AndroidSelector? selector;

  Map<String, dynamic> toJson() => _$AndroidGetNativeViewsRequestToJson(this);

  @override
  List<Object?> get props => [selector];
}

@JsonSerializable()
class IOSGetNativeViewsRequest with EquatableMixin {
  IOSGetNativeViewsRequest({
    this.selector,
    this.iosInstalledApps,
    required this.appId,
  });

  factory IOSGetNativeViewsRequest.fromJson(Map<String, dynamic> json) =>
      _$IOSGetNativeViewsRequestFromJson(json);

  final IOSSelector? selector;
  final List<String>? iosInstalledApps;
  final String appId;

  Map<String, dynamic> toJson() => _$IOSGetNativeViewsRequestToJson(this);

  @override
  List<Object?> get props => [selector, iosInstalledApps, appId];
}

@JsonSerializable()
class AndroidNativeView with EquatableMixin {
  AndroidNativeView({
    this.resourceName,
    this.text,
    this.className,
    this.contentDescription,
    this.applicationPackage,
    required this.childCount,
    required this.isCheckable,
    required this.isChecked,
    required this.isClickable,
    required this.isEnabled,
    required this.isFocusable,
    required this.isFocused,
    required this.isLongClickable,
    required this.isScrollable,
    required this.isSelected,
    required this.visibleBounds,
    required this.visibleCenter,
    required this.children,
  });

  factory AndroidNativeView.fromJson(Map<String, dynamic> json) =>
      _$AndroidNativeViewFromJson(json);

  final String? resourceName;
  final String? text;
  final String? className;
  final String? contentDescription;
  final String? applicationPackage;
  final int childCount;
  final bool isCheckable;
  final bool isChecked;
  final bool isClickable;
  final bool isEnabled;
  final bool isFocusable;
  final bool isFocused;
  final bool isLongClickable;
  final bool isScrollable;
  final bool isSelected;
  final Rectangle visibleBounds;
  final Point2D visibleCenter;
  final List<AndroidNativeView> children;

  Map<String, dynamic> toJson() => _$AndroidNativeViewToJson(this);

  @override
  List<Object?> get props => [
    resourceName,
    text,
    className,
    contentDescription,
    applicationPackage,
    childCount,
    isCheckable,
    isChecked,
    isClickable,
    isEnabled,
    isFocusable,
    isFocused,
    isLongClickable,
    isScrollable,
    isSelected,
    visibleBounds,
    visibleCenter,
    children,
  ];
}

@JsonSerializable()
class IOSNativeView with EquatableMixin {
  IOSNativeView({
    required this.children,
    required this.elementType,
    required this.identifier,
    required this.label,
    required this.title,
    required this.hasFocus,
    required this.isEnabled,
    required this.isSelected,
    required this.frame,
    this.accessibilityLabel,
    this.placeholderValue,
    this.value,
    this.bundleId,
  });

  factory IOSNativeView.fromJson(Map<String, dynamic> json) =>
      _$IOSNativeViewFromJson(json);

  final List<IOSNativeView> children;
  final IOSElementType elementType;
  final String identifier;
  final String label;
  final String title;
  final bool hasFocus;
  final bool isEnabled;
  final bool isSelected;
  final Rectangle frame;
  final String? accessibilityLabel;
  final String? placeholderValue;
  final String? value;
  final String? bundleId;

  Map<String, dynamic> toJson() => _$IOSNativeViewToJson(this);

  @override
  List<Object?> get props => [
    children,
    elementType,
    identifier,
    label,
    title,
    hasFocus,
    isEnabled,
    isSelected,
    frame,
    accessibilityLabel,
    placeholderValue,
    value,
    bundleId,
  ];
}

@JsonSerializable()
class AndroidGetNativeViewsResponse with EquatableMixin {
  AndroidGetNativeViewsResponse({required this.roots});

  factory AndroidGetNativeViewsResponse.fromJson(Map<String, dynamic> json) =>
      _$AndroidGetNativeViewsResponseFromJson(json);

  final List<AndroidNativeView> roots;

  Map<String, dynamic> toJson() => _$AndroidGetNativeViewsResponseToJson(this);

  @override
  List<Object?> get props => [roots];
}

@JsonSerializable()
class IOSGetNativeViewsResponse with EquatableMixin {
  IOSGetNativeViewsResponse({required this.roots});

  factory IOSGetNativeViewsResponse.fromJson(Map<String, dynamic> json) =>
      _$IOSGetNativeViewsResponseFromJson(json);

  final List<IOSNativeView> roots;

  Map<String, dynamic> toJson() => _$IOSGetNativeViewsResponseToJson(this);

  @override
  List<Object?> get props => [roots];
}

@JsonSerializable()
class Rectangle with EquatableMixin {
  Rectangle({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  factory Rectangle.fromJson(Map<String, dynamic> json) =>
      _$RectangleFromJson(json);

  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  Map<String, dynamic> toJson() => _$RectangleToJson(this);

  @override
  List<Object?> get props => [minX, minY, maxX, maxY];
}

@JsonSerializable()
class Point2D with EquatableMixin {
  Point2D({required this.x, required this.y});

  factory Point2D.fromJson(Map<String, dynamic> json) =>
      _$Point2DFromJson(json);

  final double x;
  final double y;

  Map<String, dynamic> toJson() => _$Point2DToJson(this);

  @override
  List<Object?> get props => [x, y];
}

@JsonSerializable()
class AndroidTapRequest with EquatableMixin {
  AndroidTapRequest({
    required this.selector,
    this.timeoutMillis,
    this.delayBetweenTapsMillis,
  });

  factory AndroidTapRequest.fromJson(Map<String, dynamic> json) =>
      _$AndroidTapRequestFromJson(json);

  final AndroidSelector selector;
  final int? timeoutMillis;
  final int? delayBetweenTapsMillis;

  Map<String, dynamic> toJson() => _$AndroidTapRequestToJson(this);

  @override
  List<Object?> get props => [selector, timeoutMillis, delayBetweenTapsMillis];
}

@JsonSerializable()
class IOSTapRequest with EquatableMixin {
  IOSTapRequest({
    required this.selector,
    required this.appId,
    this.timeoutMillis,
  });

  factory IOSTapRequest.fromJson(Map<String, dynamic> json) =>
      _$IOSTapRequestFromJson(json);

  final IOSSelector selector;
  final String appId;
  final int? timeoutMillis;

  Map<String, dynamic> toJson() => _$IOSTapRequestToJson(this);

  @override
  List<Object?> get props => [selector, appId, timeoutMillis];
}

@JsonSerializable()
class AndroidTapAtRequest with EquatableMixin {
  AndroidTapAtRequest({required this.x, required this.y});

  factory AndroidTapAtRequest.fromJson(Map<String, dynamic> json) =>
      _$AndroidTapAtRequestFromJson(json);

  final double x;
  final double y;

  Map<String, dynamic> toJson() => _$AndroidTapAtRequestToJson(this);

  @override
  List<Object?> get props => [x, y];
}

@JsonSerializable()
class IOSTapAtRequest with EquatableMixin {
  IOSTapAtRequest({required this.x, required this.y, required this.appId});

  factory IOSTapAtRequest.fromJson(Map<String, dynamic> json) =>
      _$IOSTapAtRequestFromJson(json);

  final double x;
  final double y;
  final String appId;

  Map<String, dynamic> toJson() => _$IOSTapAtRequestToJson(this);

  @override
  List<Object?> get props => [x, y, appId];
}

@JsonSerializable()
class AndroidEnterTextRequest with EquatableMixin {
  AndroidEnterTextRequest({
    required this.data,
    this.index,
    this.selector,
    required this.keyboardBehavior,
    this.timeoutMillis,
    this.dx,
    this.dy,
  });

  factory AndroidEnterTextRequest.fromJson(Map<String, dynamic> json) =>
      _$AndroidEnterTextRequestFromJson(json);

  final String data;
  final int? index;
  final AndroidSelector? selector;
  final KeyboardBehavior keyboardBehavior;
  final int? timeoutMillis;
  final double? dx;
  final double? dy;

  Map<String, dynamic> toJson() => _$AndroidEnterTextRequestToJson(this);

  @override
  List<Object?> get props => [
    data,
    index,
    selector,
    keyboardBehavior,
    timeoutMillis,
    dx,
    dy,
  ];
}

@JsonSerializable()
class IOSEnterTextRequest with EquatableMixin {
  IOSEnterTextRequest({
    required this.data,
    required this.appId,
    this.index,
    this.selector,
    required this.keyboardBehavior,
    this.timeoutMillis,
    this.dx,
    this.dy,
  });

  factory IOSEnterTextRequest.fromJson(Map<String, dynamic> json) =>
      _$IOSEnterTextRequestFromJson(json);

  final String data;
  final String appId;
  final int? index;
  final IOSSelector? selector;
  final KeyboardBehavior keyboardBehavior;
  final int? timeoutMillis;
  final double? dx;
  final double? dy;

  Map<String, dynamic> toJson() => _$IOSEnterTextRequestToJson(this);

  @override
  List<Object?> get props => [
    data,
    appId,
    index,
    selector,
    keyboardBehavior,
    timeoutMillis,
    dx,
    dy,
  ];
}

@JsonSerializable()
class AndroidSwipeRequest with EquatableMixin {
  AndroidSwipeRequest({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.steps,
  });

  factory AndroidSwipeRequest.fromJson(Map<String, dynamic> json) =>
      _$AndroidSwipeRequestFromJson(json);

  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final int steps;

  Map<String, dynamic> toJson() => _$AndroidSwipeRequestToJson(this);

  @override
  List<Object?> get props => [startX, startY, endX, endY, steps];
}

@JsonSerializable()
class IOSSwipeRequest with EquatableMixin {
  IOSSwipeRequest({
    required this.appId,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
  });

  factory IOSSwipeRequest.fromJson(Map<String, dynamic> json) =>
      _$IOSSwipeRequestFromJson(json);

  final String appId;
  final double startX;
  final double startY;
  final double endX;
  final double endY;

  Map<String, dynamic> toJson() => _$IOSSwipeRequestToJson(this);

  @override
  List<Object?> get props => [appId, startX, startY, endX, endY];
}

@JsonSerializable()
class AndroidWaitUntilVisibleRequest with EquatableMixin {
  AndroidWaitUntilVisibleRequest({required this.selector, this.timeoutMillis});

  factory AndroidWaitUntilVisibleRequest.fromJson(Map<String, dynamic> json) =>
      _$AndroidWaitUntilVisibleRequestFromJson(json);

  final AndroidSelector selector;
  final int? timeoutMillis;

  Map<String, dynamic> toJson() => _$AndroidWaitUntilVisibleRequestToJson(this);

  @override
  List<Object?> get props => [selector, timeoutMillis];
}

@JsonSerializable()
class IOSWaitUntilVisibleRequest with EquatableMixin {
  IOSWaitUntilVisibleRequest({
    required this.selector,
    required this.appId,
    this.timeoutMillis,
  });

  factory IOSWaitUntilVisibleRequest.fromJson(Map<String, dynamic> json) =>
      _$IOSWaitUntilVisibleRequestFromJson(json);

  final IOSSelector selector;
  final String appId;
  final int? timeoutMillis;

  Map<String, dynamic> toJson() => _$IOSWaitUntilVisibleRequestToJson(this);

  @override
  List<Object?> get props => [selector, appId, timeoutMillis];
}

@JsonSerializable()
class DarkModeRequest with EquatableMixin {
  DarkModeRequest({required this.appId});

  factory DarkModeRequest.fromJson(Map<String, dynamic> json) =>
      _$DarkModeRequestFromJson(json);

  final String appId;

  Map<String, dynamic> toJson() => _$DarkModeRequestToJson(this);

  @override
  List<Object?> get props => [appId];
}

@JsonSerializable()
class Notification with EquatableMixin {
  Notification({
    this.appName,
    required this.title,
    required this.content,
    this.raw,
  });

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  final String? appName;
  final String title;
  final String content;
  final String? raw;

  Map<String, dynamic> toJson() => _$NotificationToJson(this);

  @override
  List<Object?> get props => [appName, title, content, raw];
}

@JsonSerializable()
class GetNotificationsResponse with EquatableMixin {
  GetNotificationsResponse({required this.notifications});

  factory GetNotificationsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetNotificationsResponseFromJson(json);

  final List<Notification> notifications;

  Map<String, dynamic> toJson() => _$GetNotificationsResponseToJson(this);

  @override
  List<Object?> get props => [notifications];
}

@JsonSerializable()
class GetNotificationsRequest with EquatableMixin {
  GetNotificationsRequest();

  factory GetNotificationsRequest.fromJson(Map<String, dynamic> json) =>
      _$GetNotificationsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GetNotificationsRequestToJson(this);

  @override
  List<Object?> get props => const [];
}

@JsonSerializable()
class AndroidTapOnNotificationRequest with EquatableMixin {
  AndroidTapOnNotificationRequest({
    this.index,
    this.selector,
    this.timeoutMillis,
  });

  factory AndroidTapOnNotificationRequest.fromJson(Map<String, dynamic> json) =>
      _$AndroidTapOnNotificationRequestFromJson(json);

  final int? index;
  final AndroidSelector? selector;
  final int? timeoutMillis;

  Map<String, dynamic> toJson() =>
      _$AndroidTapOnNotificationRequestToJson(this);

  @override
  List<Object?> get props => [index, selector, timeoutMillis];
}

@JsonSerializable()
class IOSTapOnNotificationRequest with EquatableMixin {
  IOSTapOnNotificationRequest({this.index, this.selector, this.timeoutMillis});

  factory IOSTapOnNotificationRequest.fromJson(Map<String, dynamic> json) =>
      _$IOSTapOnNotificationRequestFromJson(json);

  final int? index;
  final IOSSelector? selector;
  final int? timeoutMillis;

  Map<String, dynamic> toJson() => _$IOSTapOnNotificationRequestToJson(this);

  @override
  List<Object?> get props => [index, selector, timeoutMillis];
}

@JsonSerializable()
class PermissionDialogVisibleResponse with EquatableMixin {
  PermissionDialogVisibleResponse({required this.visible});

  factory PermissionDialogVisibleResponse.fromJson(Map<String, dynamic> json) =>
      _$PermissionDialogVisibleResponseFromJson(json);

  final bool visible;

  Map<String, dynamic> toJson() =>
      _$PermissionDialogVisibleResponseToJson(this);

  @override
  List<Object?> get props => [visible];
}

@JsonSerializable()
class PermissionDialogVisibleRequest with EquatableMixin {
  PermissionDialogVisibleRequest({required this.timeoutMillis});

  factory PermissionDialogVisibleRequest.fromJson(Map<String, dynamic> json) =>
      _$PermissionDialogVisibleRequestFromJson(json);

  final int timeoutMillis;

  Map<String, dynamic> toJson() => _$PermissionDialogVisibleRequestToJson(this);

  @override
  List<Object?> get props => [timeoutMillis];
}

@JsonSerializable()
class HandlePermissionRequest with EquatableMixin {
  HandlePermissionRequest({required this.code});

  factory HandlePermissionRequest.fromJson(Map<String, dynamic> json) =>
      _$HandlePermissionRequestFromJson(json);

  final HandlePermissionRequestCode code;

  Map<String, dynamic> toJson() => _$HandlePermissionRequestToJson(this);

  @override
  List<Object?> get props => [code];
}

@JsonSerializable()
class SetLocationAccuracyRequest with EquatableMixin {
  SetLocationAccuracyRequest({required this.locationAccuracy});

  factory SetLocationAccuracyRequest.fromJson(Map<String, dynamic> json) =>
      _$SetLocationAccuracyRequestFromJson(json);

  final SetLocationAccuracyRequestLocationAccuracy locationAccuracy;

  Map<String, dynamic> toJson() => _$SetLocationAccuracyRequestToJson(this);

  @override
  List<Object?> get props => [locationAccuracy];
}

@JsonSerializable()
class SetMockLocationRequest with EquatableMixin {
  SetMockLocationRequest({
    required this.latitude,
    required this.longitude,
    required this.packageName,
  });

  factory SetMockLocationRequest.fromJson(Map<String, dynamic> json) =>
      _$SetMockLocationRequestFromJson(json);

  final double latitude;
  final double longitude;
  final String packageName;

  Map<String, dynamic> toJson() => _$SetMockLocationRequestToJson(this);

  @override
  List<Object?> get props => [latitude, longitude, packageName];
}

@JsonSerializable()
class IsVirtualDeviceResponse with EquatableMixin {
  IsVirtualDeviceResponse({required this.isVirtualDevice});

  factory IsVirtualDeviceResponse.fromJson(Map<String, dynamic> json) =>
      _$IsVirtualDeviceResponseFromJson(json);

  final bool isVirtualDevice;

  Map<String, dynamic> toJson() => _$IsVirtualDeviceResponseToJson(this);

  @override
  List<Object?> get props => [isVirtualDevice];
}

@JsonSerializable()
class GetOsVersionResponse with EquatableMixin {
  GetOsVersionResponse({required this.osVersion});

  factory GetOsVersionResponse.fromJson(Map<String, dynamic> json) =>
      _$GetOsVersionResponseFromJson(json);

  final int osVersion;

  Map<String, dynamic> toJson() => _$GetOsVersionResponseToJson(this);

  @override
  List<Object?> get props => [osVersion];
}

@JsonSerializable()
class AndroidTakeCameraPhotoRequest with EquatableMixin {
  AndroidTakeCameraPhotoRequest({
    this.shutterButtonSelector,
    this.doneButtonSelector,
    this.timeoutMillis,
  });

  factory AndroidTakeCameraPhotoRequest.fromJson(Map<String, dynamic> json) =>
      _$AndroidTakeCameraPhotoRequestFromJson(json);

  final AndroidSelector? shutterButtonSelector;
  final AndroidSelector? doneButtonSelector;
  final int? timeoutMillis;

  Map<String, dynamic> toJson() => _$AndroidTakeCameraPhotoRequestToJson(this);

  @override
  List<Object?> get props => [
    shutterButtonSelector,
    doneButtonSelector,
    timeoutMillis,
  ];
}

@JsonSerializable()
class IOSTakeCameraPhotoRequest with EquatableMixin {
  IOSTakeCameraPhotoRequest({
    this.shutterButtonSelector,
    this.doneButtonSelector,
    this.timeoutMillis,
    required this.appId,
  });

  factory IOSTakeCameraPhotoRequest.fromJson(Map<String, dynamic> json) =>
      _$IOSTakeCameraPhotoRequestFromJson(json);

  final IOSSelector? shutterButtonSelector;
  final IOSSelector? doneButtonSelector;
  final int? timeoutMillis;
  final String appId;

  Map<String, dynamic> toJson() => _$IOSTakeCameraPhotoRequestToJson(this);

  @override
  List<Object?> get props => [
    shutterButtonSelector,
    doneButtonSelector,
    timeoutMillis,
    appId,
  ];
}

@JsonSerializable()
class AndroidPickImageFromGalleryRequest with EquatableMixin {
  AndroidPickImageFromGalleryRequest({
    this.imageSelector,
    this.imageIndex,
    this.timeoutMillis,
  });

  factory AndroidPickImageFromGalleryRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$AndroidPickImageFromGalleryRequestFromJson(json);

  final AndroidSelector? imageSelector;
  final int? imageIndex;
  final int? timeoutMillis;

  Map<String, dynamic> toJson() =>
      _$AndroidPickImageFromGalleryRequestToJson(this);

  @override
  List<Object?> get props => [imageSelector, imageIndex, timeoutMillis];
}

@JsonSerializable()
class IOSPickImageFromGalleryRequest with EquatableMixin {
  IOSPickImageFromGalleryRequest({
    this.imageSelector,
    this.imageIndex,
    this.timeoutMillis,
    required this.appId,
  });

  factory IOSPickImageFromGalleryRequest.fromJson(Map<String, dynamic> json) =>
      _$IOSPickImageFromGalleryRequestFromJson(json);

  final IOSSelector? imageSelector;
  final int? imageIndex;
  final int? timeoutMillis;
  final String appId;

  Map<String, dynamic> toJson() => _$IOSPickImageFromGalleryRequestToJson(this);

  @override
  List<Object?> get props => [imageSelector, imageIndex, timeoutMillis, appId];
}

@JsonSerializable()
class AndroidPickMultipleImagesFromGalleryRequest with EquatableMixin {
  AndroidPickMultipleImagesFromGalleryRequest({
    this.imageSelector,
    required this.imageIndexes,
    this.timeoutMillis,
  });

  factory AndroidPickMultipleImagesFromGalleryRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$AndroidPickMultipleImagesFromGalleryRequestFromJson(json);

  final AndroidSelector? imageSelector;
  final List<int> imageIndexes;
  final int? timeoutMillis;

  Map<String, dynamic> toJson() =>
      _$AndroidPickMultipleImagesFromGalleryRequestToJson(this);

  @override
  List<Object?> get props => [imageSelector, imageIndexes, timeoutMillis];
}

@JsonSerializable()
class IOSPickMultipleImagesFromGalleryRequest with EquatableMixin {
  IOSPickMultipleImagesFromGalleryRequest({
    this.imageSelector,
    required this.imageIndexes,
    this.timeoutMillis,
    required this.appId,
  });

  factory IOSPickMultipleImagesFromGalleryRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$IOSPickMultipleImagesFromGalleryRequestFromJson(json);

  final IOSSelector? imageSelector;
  final List<int> imageIndexes;
  final int? timeoutMillis;
  final String appId;

  Map<String, dynamic> toJson() =>
      _$IOSPickMultipleImagesFromGalleryRequestToJson(this);

  @override
  List<Object?> get props => [
    imageSelector,
    imageIndexes,
    timeoutMillis,
    appId,
  ];
}

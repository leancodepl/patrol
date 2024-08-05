//
//  Generated code. Do not modify.
//  source: schema.dart
//
// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contracts.g.dart';

enum GroupEntryType {
  @JsonValue('group')
  group,
  @JsonValue('test')
  test
}

enum RunDartTestResponseResult {
  @JsonValue('success')
  success,
  @JsonValue('skipped')
  skipped,
  @JsonValue('failure')
  failure
}

enum KeyboardBehavior {
  @JsonValue('showAndDismiss')
  showAndDismiss,
  @JsonValue('alternative')
  alternative
}

enum HandlePermissionRequestCode {
  @JsonValue('whileUsing')
  whileUsing,
  @JsonValue('onlyThisTime')
  onlyThisTime,
  @JsonValue('denied')
  denied
}

enum SetLocationAccuracyRequestLocationAccuracy {
  @JsonValue('coarse')
  coarse,
  @JsonValue('fine')
  fine
}

enum IOSElementType {
  @JsonValue('any')
  any,
  @JsonValue('other')
  other,
  @JsonValue('application')
  application,
  @JsonValue('group')
  group,
  @JsonValue('window')
  window,
  @JsonValue('sheet')
  sheet,
  @JsonValue('drawer')
  drawer,
  @JsonValue('alert')
  alert,
  @JsonValue('dialog')
  dialog,
  @JsonValue('button')
  button,
  @JsonValue('radioButton')
  radioButton,
  @JsonValue('radioGroup')
  radioGroup,
  @JsonValue('checkBox')
  checkBox,
  @JsonValue('disclosureTriangle')
  disclosureTriangle,
  @JsonValue('popUpButton')
  popUpButton,
  @JsonValue('comboBox')
  comboBox,
  @JsonValue('menuButton')
  menuButton,
  @JsonValue('toolbarButton')
  toolbarButton,
  @JsonValue('popover')
  popover,
  @JsonValue('keyboard')
  keyboard,
  @JsonValue('key')
  key,
  @JsonValue('navigationBar')
  navigationBar,
  @JsonValue('tabBar')
  tabBar,
  @JsonValue('tabGroup')
  tabGroup,
  @JsonValue('toolbar')
  toolbar,
  @JsonValue('statusBar')
  statusBar,
  @JsonValue('table')
  table,
  @JsonValue('tableRow')
  tableRow,
  @JsonValue('tableColumn')
  tableColumn,
  @JsonValue('outline')
  outline,
  @JsonValue('outlineRow')
  outlineRow,
  @JsonValue('browser')
  browser,
  @JsonValue('collectionView')
  collectionView,
  @JsonValue('slider')
  slider,
  @JsonValue('pageIndicator')
  pageIndicator,
  @JsonValue('progressIndicator')
  progressIndicator,
  @JsonValue('activityIndicator')
  activityIndicator,
  @JsonValue('segmentedControl')
  segmentedControl,
  @JsonValue('picker')
  picker,
  @JsonValue('pickerWheel')
  pickerWheel,
  @JsonValue('switch_')
  switch_,
  @JsonValue('toggle')
  toggle,
  @JsonValue('link')
  link,
  @JsonValue('image')
  image,
  @JsonValue('icon')
  icon,
  @JsonValue('searchField')
  searchField,
  @JsonValue('scrollView')
  scrollView,
  @JsonValue('scrollBar')
  scrollBar,
  @JsonValue('staticText')
  staticText,
  @JsonValue('textField')
  textField,
  @JsonValue('secureTextField')
  secureTextField,
  @JsonValue('datePicker')
  datePicker,
  @JsonValue('textView')
  textView,
  @JsonValue('menu')
  menu,
  @JsonValue('menuItem')
  menuItem,
  @JsonValue('menuBar')
  menuBar,
  @JsonValue('menuBarItem')
  menuBarItem,
  @JsonValue('map')
  map,
  @JsonValue('webView')
  webView,
  @JsonValue('incrementArrow')
  incrementArrow,
  @JsonValue('decrementArrow')
  decrementArrow,
  @JsonValue('timeline')
  timeline,
  @JsonValue('ratingIndicator')
  ratingIndicator,
  @JsonValue('valueIndicator')
  valueIndicator,
  @JsonValue('splitGroup')
  splitGroup,
  @JsonValue('splitter')
  splitter,
  @JsonValue('relevanceIndicator')
  relevanceIndicator,
  @JsonValue('colorWell')
  colorWell,
  @JsonValue('helpTag')
  helpTag,
  @JsonValue('matte')
  matte,
  @JsonValue('dockItem')
  dockItem,
  @JsonValue('ruler')
  ruler,
  @JsonValue('rulerMarker')
  rulerMarker,
  @JsonValue('grid')
  grid,
  @JsonValue('levelIndicator')
  levelIndicator,
  @JsonValue('cell')
  cell,
  @JsonValue('layoutArea')
  layoutArea,
  @JsonValue('layoutItem')
  layoutItem,
  @JsonValue('handle')
  handle,
  @JsonValue('stepper')
  stepper,
  @JsonValue('tab')
  tab,
  @JsonValue('touchBar')
  touchBar,
  @JsonValue('statusItem')
  statusItem
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
  List<Object?> get props => [
        name,
        type,
        entries,
        skip,
        tags,
      ];
}

@JsonSerializable()
class ListDartTestsResponse with EquatableMixin {
  ListDartTestsResponse({
    required this.group,
  });

  factory ListDartTestsResponse.fromJson(Map<String, dynamic> json) =>
      _$ListDartTestsResponseFromJson(json);

  final DartGroupEntry group;

  Map<String, dynamic> toJson() => _$ListDartTestsResponseToJson(this);

  @override
  List<Object?> get props => [
        group,
      ];
}

@JsonSerializable()
class RunDartTestRequest with EquatableMixin {
  RunDartTestRequest({
    required this.name,
  });

  factory RunDartTestRequest.fromJson(Map<String, dynamic> json) =>
      _$RunDartTestRequestFromJson(json);

  final String name;

  Map<String, dynamic> toJson() => _$RunDartTestRequestToJson(this);

  @override
  List<Object?> get props => [
        name,
      ];
}

@JsonSerializable()
class RunDartTestResponse with EquatableMixin {
  RunDartTestResponse({
    required this.result,
    this.details,
  });

  factory RunDartTestResponse.fromJson(Map<String, dynamic> json) =>
      _$RunDartTestResponseFromJson(json);

  final RunDartTestResponseResult result;
  final String? details;

  Map<String, dynamic> toJson() => _$RunDartTestResponseToJson(this);

  @override
  List<Object?> get props => [
        result,
        details,
      ];
}

@JsonSerializable()
class ConfigureRequest with EquatableMixin {
  ConfigureRequest({
    required this.findTimeoutMillis,
  });

  factory ConfigureRequest.fromJson(Map<String, dynamic> json) =>
      _$ConfigureRequestFromJson(json);

  final int findTimeoutMillis;

  Map<String, dynamic> toJson() => _$ConfigureRequestToJson(this);

  @override
  List<Object?> get props => [
        findTimeoutMillis,
      ];
}

@JsonSerializable()
class OpenAppRequest with EquatableMixin {
  OpenAppRequest({
    required this.appId,
  });

  factory OpenAppRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenAppRequestFromJson(json);

  final String appId;

  Map<String, dynamic> toJson() => _$OpenAppRequestToJson(this);

  @override
  List<Object?> get props => [
        appId,
      ];
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
  OpenUrlRequest({
    required this.url,
  });

  factory OpenUrlRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenUrlRequestFromJson(json);

  final String url;

  Map<String, dynamic> toJson() => _$OpenUrlRequestToJson(this);

  @override
  List<Object?> get props => [
        url,
      ];
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
class Selector with EquatableMixin {
  Selector({
    this.text,
    this.textStartsWith,
    this.textContains,
    this.className,
    this.contentDescription,
    this.contentDescriptionStartsWith,
    this.contentDescriptionContains,
    this.resourceId,
    this.instance,
    this.enabled,
    this.focused,
    this.pkg,
  });

  factory Selector.fromJson(Map<String, dynamic> json) =>
      _$SelectorFromJson(json);

  final String? text;
  final String? textStartsWith;
  final String? textContains;
  final String? className;
  final String? contentDescription;
  final String? contentDescriptionStartsWith;
  final String? contentDescriptionContains;
  final String? resourceId;
  final int? instance;
  final bool? enabled;
  final bool? focused;
  final String? pkg;

  Map<String, dynamic> toJson() => _$SelectorToJson(this);

  @override
  List<Object?> get props => [
        text,
        textStartsWith,
        textContains,
        className,
        contentDescription,
        contentDescriptionStartsWith,
        contentDescriptionContains,
        resourceId,
        instance,
        enabled,
        focused,
        pkg,
      ];
}

@JsonSerializable()
class GetNativeViewsRequest with EquatableMixin {
  GetNativeViewsRequest({
    this.selector,
    this.androidSelector,
    this.iosSelector,
    required this.appId,
  });

  factory GetNativeViewsRequest.fromJson(Map<String, dynamic> json) =>
      _$GetNativeViewsRequestFromJson(json);

  final Selector? selector;
  final AndroidSelector? androidSelector;
  final IOSSelector? iosSelector;
  final String appId;

  Map<String, dynamic> toJson() => _$GetNativeViewsRequestToJson(this);

  @override
  List<Object?> get props => [
        selector,
        androidSelector,
        iosSelector,
        appId,
      ];
}

@JsonSerializable()
class GetNativeUITreeRequest with EquatableMixin {
  GetNativeUITreeRequest({
    this.iosInstalledApps,
    required this.useNativeViewHierarchy,
  });

  factory GetNativeUITreeRequest.fromJson(Map<String, dynamic> json) =>
      _$GetNativeUITreeRequestFromJson(json);

  final List<String>? iosInstalledApps;
  final bool useNativeViewHierarchy;

  Map<String, dynamic> toJson() => _$GetNativeUITreeRequestToJson(this);

  @override
  List<Object?> get props => [
        iosInstalledApps,
        useNativeViewHierarchy,
      ];
}

@JsonSerializable()
class GetNativeUITreeRespone with EquatableMixin {
  GetNativeUITreeRespone({
    required this.iOSroots,
    required this.androidRoots,
    required this.roots,
  });

  factory GetNativeUITreeRespone.fromJson(Map<String, dynamic> json) =>
      _$GetNativeUITreeResponeFromJson(json);

  final List<IOSNativeView> iOSroots;
  final List<AndroidNativeView> androidRoots;
  final List<NativeView> roots;

  Map<String, dynamic> toJson() => _$GetNativeUITreeResponeToJson(this);

  @override
  List<Object?> get props => [
        iOSroots,
        androidRoots,
        roots,
      ];
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
    this.placeholderValue,
    this.value,
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
  final String? placeholderValue;
  final String? value;

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
        placeholderValue,
        value,
      ];
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
  List<Object?> get props => [
        minX,
        minY,
        maxX,
        maxY,
      ];
}

@JsonSerializable()
class Point2D with EquatableMixin {
  Point2D({
    required this.x,
    required this.y,
  });

  factory Point2D.fromJson(Map<String, dynamic> json) =>
      _$Point2DFromJson(json);

  final double x;
  final double y;

  Map<String, dynamic> toJson() => _$Point2DToJson(this);

  @override
  List<Object?> get props => [
        x,
        y,
      ];
}

@JsonSerializable()
class NativeView with EquatableMixin {
  NativeView({
    this.className,
    this.text,
    this.contentDescription,
    required this.focused,
    required this.enabled,
    this.childCount,
    this.resourceName,
    this.applicationPackage,
    required this.children,
  });

  factory NativeView.fromJson(Map<String, dynamic> json) =>
      _$NativeViewFromJson(json);

  final String? className;
  final String? text;
  final String? contentDescription;
  final bool focused;
  final bool enabled;
  final int? childCount;
  final String? resourceName;
  final String? applicationPackage;
  final List<NativeView> children;

  Map<String, dynamic> toJson() => _$NativeViewToJson(this);

  @override
  List<Object?> get props => [
        className,
        text,
        contentDescription,
        focused,
        enabled,
        childCount,
        resourceName,
        applicationPackage,
        children,
      ];
}

@JsonSerializable()
class GetNativeViewsResponse with EquatableMixin {
  GetNativeViewsResponse({
    required this.nativeViews,
    required this.iosNativeViews,
    required this.androidNativeViews,
  });

  factory GetNativeViewsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetNativeViewsResponseFromJson(json);

  final List<NativeView> nativeViews;
  final List<IOSNativeView> iosNativeViews;
  final List<AndroidNativeView> androidNativeViews;

  Map<String, dynamic> toJson() => _$GetNativeViewsResponseToJson(this);

  @override
  List<Object?> get props => [
        nativeViews,
        iosNativeViews,
        androidNativeViews,
      ];
}

@JsonSerializable()
class TapRequest with EquatableMixin {
  TapRequest({
    this.selector,
    this.androidSelector,
    this.iosSelector,
    required this.appId,
    this.timeoutMillis,
    this.delayBetweenTapsMillis,
  });

  factory TapRequest.fromJson(Map<String, dynamic> json) =>
      _$TapRequestFromJson(json);

  final Selector? selector;
  final AndroidSelector? androidSelector;
  final IOSSelector? iosSelector;
  final String appId;
  final int? timeoutMillis;
  final int? delayBetweenTapsMillis;

  Map<String, dynamic> toJson() => _$TapRequestToJson(this);

  @override
  List<Object?> get props => [
        selector,
        androidSelector,
        iosSelector,
        appId,
        timeoutMillis,
        delayBetweenTapsMillis,
      ];
}

@JsonSerializable()
class TapAtRequest with EquatableMixin {
  TapAtRequest({
    required this.x,
    required this.y,
    required this.appId,
  });

  factory TapAtRequest.fromJson(Map<String, dynamic> json) =>
      _$TapAtRequestFromJson(json);

  final double x;
  final double y;
  final String appId;

  Map<String, dynamic> toJson() => _$TapAtRequestToJson(this);

  @override
  List<Object?> get props => [
        x,
        y,
        appId,
      ];
}

@JsonSerializable()
class EnterTextRequest with EquatableMixin {
  EnterTextRequest({
    required this.data,
    required this.appId,
    this.index,
    this.selector,
    this.androidSelector,
    this.iosSelector,
    required this.keyboardBehavior,
    this.timeoutMillis,
  });

  factory EnterTextRequest.fromJson(Map<String, dynamic> json) =>
      _$EnterTextRequestFromJson(json);

  final String data;
  final String appId;
  final int? index;
  final Selector? selector;
  final AndroidSelector? androidSelector;
  final IOSSelector? iosSelector;
  final KeyboardBehavior keyboardBehavior;
  final int? timeoutMillis;

  Map<String, dynamic> toJson() => _$EnterTextRequestToJson(this);

  @override
  List<Object?> get props => [
        data,
        appId,
        index,
        selector,
        androidSelector,
        iosSelector,
        keyboardBehavior,
        timeoutMillis,
      ];
}

@JsonSerializable()
class SwipeRequest with EquatableMixin {
  SwipeRequest({
    required this.appId,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.steps,
  });

  factory SwipeRequest.fromJson(Map<String, dynamic> json) =>
      _$SwipeRequestFromJson(json);

  final String appId;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final int steps;

  Map<String, dynamic> toJson() => _$SwipeRequestToJson(this);

  @override
  List<Object?> get props => [
        appId,
        startX,
        startY,
        endX,
        endY,
        steps,
      ];
}

@JsonSerializable()
class WaitUntilVisibleRequest with EquatableMixin {
  WaitUntilVisibleRequest({
    this.selector,
    this.androidSelector,
    this.iosSelector,
    required this.appId,
    this.timeoutMillis,
  });

  factory WaitUntilVisibleRequest.fromJson(Map<String, dynamic> json) =>
      _$WaitUntilVisibleRequestFromJson(json);

  final Selector? selector;
  final AndroidSelector? androidSelector;
  final IOSSelector? iosSelector;
  final String appId;
  final int? timeoutMillis;

  Map<String, dynamic> toJson() => _$WaitUntilVisibleRequestToJson(this);

  @override
  List<Object?> get props => [
        selector,
        androidSelector,
        iosSelector,
        appId,
        timeoutMillis,
      ];
}

@JsonSerializable()
class DarkModeRequest with EquatableMixin {
  DarkModeRequest({
    required this.appId,
  });

  factory DarkModeRequest.fromJson(Map<String, dynamic> json) =>
      _$DarkModeRequestFromJson(json);

  final String appId;

  Map<String, dynamic> toJson() => _$DarkModeRequestToJson(this);

  @override
  List<Object?> get props => [
        appId,
      ];
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
  List<Object?> get props => [
        appName,
        title,
        content,
        raw,
      ];
}

@JsonSerializable()
class GetNotificationsResponse with EquatableMixin {
  GetNotificationsResponse({
    required this.notifications,
  });

  factory GetNotificationsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetNotificationsResponseFromJson(json);

  final List<Notification> notifications;

  Map<String, dynamic> toJson() => _$GetNotificationsResponseToJson(this);

  @override
  List<Object?> get props => [
        notifications,
      ];
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
class TapOnNotificationRequest with EquatableMixin {
  TapOnNotificationRequest({
    this.index,
    this.selector,
    this.androidSelector,
    this.iosSelector,
    this.timeoutMillis,
  });

  factory TapOnNotificationRequest.fromJson(Map<String, dynamic> json) =>
      _$TapOnNotificationRequestFromJson(json);

  final int? index;
  final Selector? selector;
  final AndroidSelector? androidSelector;
  final IOSSelector? iosSelector;
  final int? timeoutMillis;

  Map<String, dynamic> toJson() => _$TapOnNotificationRequestToJson(this);

  @override
  List<Object?> get props => [
        index,
        selector,
        androidSelector,
        iosSelector,
        timeoutMillis,
      ];
}

@JsonSerializable()
class PermissionDialogVisibleResponse with EquatableMixin {
  PermissionDialogVisibleResponse({
    required this.visible,
  });

  factory PermissionDialogVisibleResponse.fromJson(Map<String, dynamic> json) =>
      _$PermissionDialogVisibleResponseFromJson(json);

  final bool visible;

  Map<String, dynamic> toJson() =>
      _$PermissionDialogVisibleResponseToJson(this);

  @override
  List<Object?> get props => [
        visible,
      ];
}

@JsonSerializable()
class PermissionDialogVisibleRequest with EquatableMixin {
  PermissionDialogVisibleRequest({
    required this.timeoutMillis,
  });

  factory PermissionDialogVisibleRequest.fromJson(Map<String, dynamic> json) =>
      _$PermissionDialogVisibleRequestFromJson(json);

  final int timeoutMillis;

  Map<String, dynamic> toJson() => _$PermissionDialogVisibleRequestToJson(this);

  @override
  List<Object?> get props => [
        timeoutMillis,
      ];
}

@JsonSerializable()
class HandlePermissionRequest with EquatableMixin {
  HandlePermissionRequest({
    required this.code,
  });

  factory HandlePermissionRequest.fromJson(Map<String, dynamic> json) =>
      _$HandlePermissionRequestFromJson(json);

  final HandlePermissionRequestCode code;

  Map<String, dynamic> toJson() => _$HandlePermissionRequestToJson(this);

  @override
  List<Object?> get props => [
        code,
      ];
}

@JsonSerializable()
class SetLocationAccuracyRequest with EquatableMixin {
  SetLocationAccuracyRequest({
    required this.locationAccuracy,
  });

  factory SetLocationAccuracyRequest.fromJson(Map<String, dynamic> json) =>
      _$SetLocationAccuracyRequestFromJson(json);

  final SetLocationAccuracyRequestLocationAccuracy locationAccuracy;

  Map<String, dynamic> toJson() => _$SetLocationAccuracyRequestToJson(this);

  @override
  List<Object?> get props => [
        locationAccuracy,
      ];
}

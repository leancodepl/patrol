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
  test,
}

enum RunDartTestResponseResult {
  @JsonValue('success')
  success,
  @JsonValue('skipped')
  skipped,
  @JsonValue('failure')
  failure,
}

enum KeyboardBehavior {
  @JsonValue('showAndDismiss')
  showAndDismiss,
  @JsonValue('alternative')
  alternative,
}

enum HandlePermissionRequestCode {
  @JsonValue('whileUsing')
  whileUsing,
  @JsonValue('onlyThisTime')
  onlyThisTime,
  @JsonValue('denied')
  denied,
}

enum SetLocationAccuracyRequestLocationAccuracy {
  @JsonValue('coarse')
  coarse,
  @JsonValue('fine')
  fine,
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
  statusItem,
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

  DartGroupEntry copyWith({
    String? name,
    GroupEntryType? type,
    List<DartGroupEntry>? entries,
    bool? skip,
    List<String>? tags,
  }) {
    return DartGroupEntry(
      name: name ?? this.name,
      type: type ?? this.type,
      entries: entries ?? this.entries,
      skip: skip ?? this.skip,
      tags: tags ?? this.tags,
    );
  }
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

  ListDartTestsResponse copyWith({DartGroupEntry? group}) {
    return ListDartTestsResponse(group: group ?? this.group);
  }
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

  RunDartTestRequest copyWith({String? name}) {
    return RunDartTestRequest(name: name ?? this.name);
  }
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

  RunDartTestResponse copyWith({
    RunDartTestResponseResult? result,
    String? details,
  }) {
    return RunDartTestResponse(
      result: result ?? this.result,
      details: details ?? this.details,
    );
  }
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

  ConfigureRequest copyWith({int? findTimeoutMillis}) {
    return ConfigureRequest(
      findTimeoutMillis: findTimeoutMillis ?? this.findTimeoutMillis,
    );
  }
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

  OpenAppRequest copyWith({String? appId}) {
    return OpenAppRequest(appId: appId ?? this.appId);
  }
}

@JsonSerializable()
class OpenQuickSettingsRequest with EquatableMixin {
  OpenQuickSettingsRequest();

  factory OpenQuickSettingsRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenQuickSettingsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OpenQuickSettingsRequestToJson(this);

  @override
  List<Object?> get props => const [];

  OpenQuickSettingsRequest copyWith() {
    return OpenQuickSettingsRequest();
  }
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

  OpenUrlRequest copyWith({String? url}) {
    return OpenUrlRequest(url: url ?? this.url);
  }
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

  AndroidSelector copyWith({
    String? className,
    bool? isCheckable,
    bool? isChecked,
    bool? isClickable,
    bool? isEnabled,
    bool? isFocusable,
    bool? isFocused,
    bool? isLongClickable,
    bool? isScrollable,
    bool? isSelected,
    String? applicationPackage,
    String? contentDescription,
    String? contentDescriptionStartsWith,
    String? contentDescriptionContains,
    String? text,
    String? textStartsWith,
    String? textContains,
    String? resourceName,
    int? instance,
  }) {
    return AndroidSelector(
      className: className ?? this.className,
      isCheckable: isCheckable ?? this.isCheckable,
      isChecked: isChecked ?? this.isChecked,
      isClickable: isClickable ?? this.isClickable,
      isEnabled: isEnabled ?? this.isEnabled,
      isFocusable: isFocusable ?? this.isFocusable,
      isFocused: isFocused ?? this.isFocused,
      isLongClickable: isLongClickable ?? this.isLongClickable,
      isScrollable: isScrollable ?? this.isScrollable,
      isSelected: isSelected ?? this.isSelected,
      applicationPackage: applicationPackage ?? this.applicationPackage,
      contentDescription: contentDescription ?? this.contentDescription,
      contentDescriptionStartsWith:
          contentDescriptionStartsWith ?? this.contentDescriptionStartsWith,
      contentDescriptionContains:
          contentDescriptionContains ?? this.contentDescriptionContains,
      text: text ?? this.text,
      textStartsWith: textStartsWith ?? this.textStartsWith,
      textContains: textContains ?? this.textContains,
      resourceName: resourceName ?? this.resourceName,
      instance: instance ?? this.instance,
    );
  }
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

  IOSSelector copyWith({
    String? value,
    int? instance,
    IOSElementType? elementType,
    String? identifier,
    String? text,
    String? textStartsWith,
    String? textContains,
    String? label,
    String? labelStartsWith,
    String? labelContains,
    String? title,
    String? titleStartsWith,
    String? titleContains,
    bool? hasFocus,
    bool? isEnabled,
    bool? isSelected,
    String? placeholderValue,
    String? placeholderValueStartsWith,
    String? placeholderValueContains,
  }) {
    return IOSSelector(
      value: value ?? this.value,
      instance: instance ?? this.instance,
      elementType: elementType ?? this.elementType,
      identifier: identifier ?? this.identifier,
      text: text ?? this.text,
      textStartsWith: textStartsWith ?? this.textStartsWith,
      textContains: textContains ?? this.textContains,
      label: label ?? this.label,
      labelStartsWith: labelStartsWith ?? this.labelStartsWith,
      labelContains: labelContains ?? this.labelContains,
      title: title ?? this.title,
      titleStartsWith: titleStartsWith ?? this.titleStartsWith,
      titleContains: titleContains ?? this.titleContains,
      hasFocus: hasFocus ?? this.hasFocus,
      isEnabled: isEnabled ?? this.isEnabled,
      isSelected: isSelected ?? this.isSelected,
      placeholderValue: placeholderValue ?? this.placeholderValue,
      placeholderValueStartsWith:
          placeholderValueStartsWith ?? this.placeholderValueStartsWith,
      placeholderValueContains:
          placeholderValueContains ?? this.placeholderValueContains,
    );
  }
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

  AndroidGetNativeViewsRequest copyWith({AndroidSelector? selector}) {
    return AndroidGetNativeViewsRequest(selector: selector ?? this.selector);
  }
}

@JsonSerializable()
class IOSGetNativeViewsRequest with EquatableMixin {
  IOSGetNativeViewsRequest({this.selector, required this.appId});

  factory IOSGetNativeViewsRequest.fromJson(Map<String, dynamic> json) =>
      _$IOSGetNativeViewsRequestFromJson(json);

  final IOSSelector? selector;
  final String appId;

  Map<String, dynamic> toJson() => _$IOSGetNativeViewsRequestToJson(this);

  @override
  List<Object?> get props => [selector, appId];

  IOSGetNativeViewsRequest copyWith({IOSSelector? selector, String? appId}) {
    return IOSGetNativeViewsRequest(
      selector: selector ?? this.selector,
      appId: appId ?? this.appId,
    );
  }
}

@JsonSerializable()
class IOSGetNativeUITreeRequest with EquatableMixin {
  IOSGetNativeUITreeRequest({this.iosInstalledApps});

  factory IOSGetNativeUITreeRequest.fromJson(Map<String, dynamic> json) =>
      _$IOSGetNativeUITreeRequestFromJson(json);

  final List<String>? iosInstalledApps;

  Map<String, dynamic> toJson() => _$IOSGetNativeUITreeRequestToJson(this);

  @override
  List<Object?> get props => [iosInstalledApps];

  IOSGetNativeUITreeRequest copyWith({List<String>? iosInstalledApps}) {
    return IOSGetNativeUITreeRequest(
      iosInstalledApps: iosInstalledApps ?? this.iosInstalledApps,
    );
  }
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

  AndroidNativeView copyWith({
    String? resourceName,
    String? text,
    String? className,
    String? contentDescription,
    String? applicationPackage,
    int? childCount,
    bool? isCheckable,
    bool? isChecked,
    bool? isClickable,
    bool? isEnabled,
    bool? isFocusable,
    bool? isFocused,
    bool? isLongClickable,
    bool? isScrollable,
    bool? isSelected,
    Rectangle? visibleBounds,
    Point2D? visibleCenter,
    List<AndroidNativeView>? children,
  }) {
    return AndroidNativeView(
      resourceName: resourceName ?? this.resourceName,
      text: text ?? this.text,
      className: className ?? this.className,
      contentDescription: contentDescription ?? this.contentDescription,
      applicationPackage: applicationPackage ?? this.applicationPackage,
      childCount: childCount ?? this.childCount,
      isCheckable: isCheckable ?? this.isCheckable,
      isChecked: isChecked ?? this.isChecked,
      isClickable: isClickable ?? this.isClickable,
      isEnabled: isEnabled ?? this.isEnabled,
      isFocusable: isFocusable ?? this.isFocusable,
      isFocused: isFocused ?? this.isFocused,
      isLongClickable: isLongClickable ?? this.isLongClickable,
      isScrollable: isScrollable ?? this.isScrollable,
      isSelected: isSelected ?? this.isSelected,
      visibleBounds: visibleBounds ?? this.visibleBounds,
      visibleCenter: visibleCenter ?? this.visibleCenter,
      children: children ?? this.children,
    );
  }
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
  ];

  IOSNativeView copyWith({
    List<IOSNativeView>? children,
    IOSElementType? elementType,
    String? identifier,
    String? label,
    String? title,
    bool? hasFocus,
    bool? isEnabled,
    bool? isSelected,
    Rectangle? frame,
    String? accessibilityLabel,
    String? placeholderValue,
    String? value,
  }) {
    return IOSNativeView(
      children: children ?? this.children,
      elementType: elementType ?? this.elementType,
      identifier: identifier ?? this.identifier,
      label: label ?? this.label,
      title: title ?? this.title,
      hasFocus: hasFocus ?? this.hasFocus,
      isEnabled: isEnabled ?? this.isEnabled,
      isSelected: isSelected ?? this.isSelected,
      frame: frame ?? this.frame,
      accessibilityLabel: accessibilityLabel ?? this.accessibilityLabel,
      placeholderValue: placeholderValue ?? this.placeholderValue,
      value: value ?? this.value,
    );
  }
}

@JsonSerializable()
class AndroidGetNativeUITreeResponse with EquatableMixin {
  AndroidGetNativeUITreeResponse({required this.roots});

  factory AndroidGetNativeUITreeResponse.fromJson(Map<String, dynamic> json) =>
      _$AndroidGetNativeUITreeResponseFromJson(json);

  final List<AndroidNativeView> roots;

  Map<String, dynamic> toJson() => _$AndroidGetNativeUITreeResponseToJson(this);

  @override
  List<Object?> get props => [roots];

  AndroidGetNativeUITreeResponse copyWith({List<AndroidNativeView>? roots}) {
    return AndroidGetNativeUITreeResponse(roots: roots ?? this.roots);
  }
}

@JsonSerializable()
class IOSGetNativeUITreeResponse with EquatableMixin {
  IOSGetNativeUITreeResponse({required this.roots});

  factory IOSGetNativeUITreeResponse.fromJson(Map<String, dynamic> json) =>
      _$IOSGetNativeUITreeResponseFromJson(json);

  final List<IOSNativeView> roots;

  Map<String, dynamic> toJson() => _$IOSGetNativeUITreeResponseToJson(this);

  @override
  List<Object?> get props => [roots];

  IOSGetNativeUITreeResponse copyWith({List<IOSNativeView>? roots}) {
    return IOSGetNativeUITreeResponse(roots: roots ?? this.roots);
  }
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

  Rectangle copyWith({double? minX, double? minY, double? maxX, double? maxY}) {
    return Rectangle(
      minX: minX ?? this.minX,
      minY: minY ?? this.minY,
      maxX: maxX ?? this.maxX,
      maxY: maxY ?? this.maxY,
    );
  }
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

  Point2D copyWith({double? x, double? y}) {
    return Point2D(x: x ?? this.x, y: y ?? this.y);
  }
}

@JsonSerializable()
class AndroidTapRequest with EquatableMixin {
  AndroidTapRequest({
    this.selector,
    this.timeoutMillis,
    this.delayBetweenTapsMillis,
  });

  factory AndroidTapRequest.fromJson(Map<String, dynamic> json) =>
      _$AndroidTapRequestFromJson(json);

  final AndroidSelector? selector;
  final int? timeoutMillis;
  final int? delayBetweenTapsMillis;

  Map<String, dynamic> toJson() => _$AndroidTapRequestToJson(this);

  @override
  List<Object?> get props => [selector, timeoutMillis, delayBetweenTapsMillis];

  AndroidTapRequest copyWith({
    AndroidSelector? selector,
    int? timeoutMillis,
    int? delayBetweenTapsMillis,
  }) {
    return AndroidTapRequest(
      selector: selector ?? this.selector,
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
      delayBetweenTapsMillis:
          delayBetweenTapsMillis ?? this.delayBetweenTapsMillis,
    );
  }
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

  IOSTapRequest copyWith({
    IOSSelector? selector,
    String? appId,
    int? timeoutMillis,
  }) {
    return IOSTapRequest(
      selector: selector ?? this.selector,
      appId: appId ?? this.appId,
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
    );
  }
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

  AndroidTapAtRequest copyWith({double? x, double? y}) {
    return AndroidTapAtRequest(x: x ?? this.x, y: y ?? this.y);
  }
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

  IOSTapAtRequest copyWith({double? x, double? y, String? appId}) {
    return IOSTapAtRequest(
      x: x ?? this.x,
      y: y ?? this.y,
      appId: appId ?? this.appId,
    );
  }
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

  AndroidEnterTextRequest copyWith({
    String? data,
    int? index,
    AndroidSelector? selector,
    KeyboardBehavior? keyboardBehavior,
    int? timeoutMillis,
    double? dx,
    double? dy,
  }) {
    return AndroidEnterTextRequest(
      data: data ?? this.data,
      index: index ?? this.index,
      selector: selector ?? this.selector,
      keyboardBehavior: keyboardBehavior ?? this.keyboardBehavior,
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
    );
  }
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

  IOSEnterTextRequest copyWith({
    String? data,
    String? appId,
    int? index,
    IOSSelector? selector,
    KeyboardBehavior? keyboardBehavior,
    int? timeoutMillis,
    double? dx,
    double? dy,
  }) {
    return IOSEnterTextRequest(
      data: data ?? this.data,
      appId: appId ?? this.appId,
      index: index ?? this.index,
      selector: selector ?? this.selector,
      keyboardBehavior: keyboardBehavior ?? this.keyboardBehavior,
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
    );
  }
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

  AndroidSwipeRequest copyWith({
    double? startX,
    double? startY,
    double? endX,
    double? endY,
    int? steps,
  }) {
    return AndroidSwipeRequest(
      startX: startX ?? this.startX,
      startY: startY ?? this.startY,
      endX: endX ?? this.endX,
      endY: endY ?? this.endY,
      steps: steps ?? this.steps,
    );
  }
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

  IOSSwipeRequest copyWith({
    String? appId,
    double? startX,
    double? startY,
    double? endX,
    double? endY,
  }) {
    return IOSSwipeRequest(
      appId: appId ?? this.appId,
      startX: startX ?? this.startX,
      startY: startY ?? this.startY,
      endX: endX ?? this.endX,
      endY: endY ?? this.endY,
    );
  }
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

  AndroidWaitUntilVisibleRequest copyWith({
    AndroidSelector? selector,
    int? timeoutMillis,
  }) {
    return AndroidWaitUntilVisibleRequest(
      selector: selector ?? this.selector,
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
    );
  }
}

@JsonSerializable()
class IOSTwaitUntilVisibleRequest with EquatableMixin {
  IOSTwaitUntilVisibleRequest({
    required this.selector,
    required this.appId,
    this.timeoutMillis,
  });

  factory IOSTwaitUntilVisibleRequest.fromJson(Map<String, dynamic> json) =>
      _$IOSTwaitUntilVisibleRequestFromJson(json);

  final IOSSelector selector;
  final String appId;
  final int? timeoutMillis;

  Map<String, dynamic> toJson() => _$IOSTwaitUntilVisibleRequestToJson(this);

  @override
  List<Object?> get props => [selector, appId, timeoutMillis];

  IOSTwaitUntilVisibleRequest copyWith({
    IOSSelector? selector,
    String? appId,
    int? timeoutMillis,
  }) {
    return IOSTwaitUntilVisibleRequest(
      selector: selector ?? this.selector,
      appId: appId ?? this.appId,
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
    );
  }
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

  DarkModeRequest copyWith({String? appId}) {
    return DarkModeRequest(appId: appId ?? this.appId);
  }
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

  Notification copyWith({
    String? appName,
    String? title,
    String? content,
    String? raw,
  }) {
    return Notification(
      appName: appName ?? this.appName,
      title: title ?? this.title,
      content: content ?? this.content,
      raw: raw ?? this.raw,
    );
  }
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

  GetNotificationsResponse copyWith({List<Notification>? notifications}) {
    return GetNotificationsResponse(
      notifications: notifications ?? this.notifications,
    );
  }
}

@JsonSerializable()
class GetNotificationsRequest with EquatableMixin {
  GetNotificationsRequest();

  factory GetNotificationsRequest.fromJson(Map<String, dynamic> json) =>
      _$GetNotificationsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GetNotificationsRequestToJson(this);

  @override
  List<Object?> get props => const [];

  GetNotificationsRequest copyWith() {
    return GetNotificationsRequest();
  }
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

  AndroidTapOnNotificationRequest copyWith({
    int? index,
    AndroidSelector? selector,
    int? timeoutMillis,
  }) {
    return AndroidTapOnNotificationRequest(
      index: index ?? this.index,
      selector: selector ?? this.selector,
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
    );
  }
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

  IOSTapOnNotificationRequest copyWith({
    int? index,
    IOSSelector? selector,
    int? timeoutMillis,
  }) {
    return IOSTapOnNotificationRequest(
      index: index ?? this.index,
      selector: selector ?? this.selector,
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
    );
  }
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

  PermissionDialogVisibleResponse copyWith({bool? visible}) {
    return PermissionDialogVisibleResponse(visible: visible ?? this.visible);
  }
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

  PermissionDialogVisibleRequest copyWith({int? timeoutMillis}) {
    return PermissionDialogVisibleRequest(
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
    );
  }
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

  HandlePermissionRequest copyWith({HandlePermissionRequestCode? code}) {
    return HandlePermissionRequest(code: code ?? this.code);
  }
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

  SetLocationAccuracyRequest copyWith({
    SetLocationAccuracyRequestLocationAccuracy? locationAccuracy,
  }) {
    return SetLocationAccuracyRequest(
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
    );
  }
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

  SetMockLocationRequest copyWith({
    double? latitude,
    double? longitude,
    String? packageName,
  }) {
    return SetMockLocationRequest(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      packageName: packageName ?? this.packageName,
    );
  }
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

  IsVirtualDeviceResponse copyWith({bool? isVirtualDevice}) {
    return IsVirtualDeviceResponse(
      isVirtualDevice: isVirtualDevice ?? this.isVirtualDevice,
    );
  }
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

  GetOsVersionResponse copyWith({int? osVersion}) {
    return GetOsVersionResponse(osVersion: osVersion ?? this.osVersion);
  }
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

  AndroidTakeCameraPhotoRequest copyWith({
    AndroidSelector? shutterButtonSelector,
    AndroidSelector? doneButtonSelector,
    int? timeoutMillis,
  }) {
    return AndroidTakeCameraPhotoRequest(
      shutterButtonSelector:
          shutterButtonSelector ?? this.shutterButtonSelector,
      doneButtonSelector: doneButtonSelector ?? this.doneButtonSelector,
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
    );
  }
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

  IOSTakeCameraPhotoRequest copyWith({
    IOSSelector? shutterButtonSelector,
    IOSSelector? doneButtonSelector,
    int? timeoutMillis,
    String? appId,
  }) {
    return IOSTakeCameraPhotoRequest(
      shutterButtonSelector:
          shutterButtonSelector ?? this.shutterButtonSelector,
      doneButtonSelector: doneButtonSelector ?? this.doneButtonSelector,
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
      appId: appId ?? this.appId,
    );
  }
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

  AndroidPickImageFromGalleryRequest copyWith({
    AndroidSelector? imageSelector,
    int? imageIndex,
    int? timeoutMillis,
  }) {
    return AndroidPickImageFromGalleryRequest(
      imageSelector: imageSelector ?? this.imageSelector,
      imageIndex: imageIndex ?? this.imageIndex,
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
    );
  }
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

  IOSPickImageFromGalleryRequest copyWith({
    IOSSelector? imageSelector,
    int? imageIndex,
    int? timeoutMillis,
    String? appId,
  }) {
    return IOSPickImageFromGalleryRequest(
      imageSelector: imageSelector ?? this.imageSelector,
      imageIndex: imageIndex ?? this.imageIndex,
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
      appId: appId ?? this.appId,
    );
  }
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

  AndroidPickMultipleImagesFromGalleryRequest copyWith({
    AndroidSelector? imageSelector,
    List<int>? imageIndexes,
    int? timeoutMillis,
  }) {
    return AndroidPickMultipleImagesFromGalleryRequest(
      imageSelector: imageSelector ?? this.imageSelector,
      imageIndexes: imageIndexes ?? this.imageIndexes,
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
    );
  }
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

  IOSPickMultipleImagesFromGalleryRequest copyWith({
    IOSSelector? imageSelector,
    List<int>? imageIndexes,
    int? timeoutMillis,
    String? appId,
  }) {
    return IOSPickMultipleImagesFromGalleryRequest(
      imageSelector: imageSelector ?? this.imageSelector,
      imageIndexes: imageIndexes ?? this.imageIndexes,
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
      appId: appId ?? this.appId,
    );
  }
}

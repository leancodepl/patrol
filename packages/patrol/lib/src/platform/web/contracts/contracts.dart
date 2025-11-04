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
class Selector with EquatableMixin {
  Selector({
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

  factory Selector.fromJson(Map<String, dynamic> json) =>
      _$SelectorFromJson(json);

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

  Map<String, dynamic> toJson() => _$SelectorToJson(this);

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

  Selector copyWith({
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
    return Selector(
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
class GetNativeViewsRequest with EquatableMixin {
  GetNativeViewsRequest({required this.selector, required this.appId});

  factory GetNativeViewsRequest.fromJson(Map<String, dynamic> json) =>
      _$GetNativeViewsRequestFromJson(json);

  final Selector selector;
  final String appId;

  Map<String, dynamic> toJson() => _$GetNativeViewsRequestToJson(this);

  @override
  List<Object?> get props => [selector, appId];

  GetNativeViewsRequest copyWith({Selector? selector, String? appId}) {
    return GetNativeViewsRequest(
      selector: selector ?? this.selector,
      appId: appId ?? this.appId,
    );
  }
}

@JsonSerializable()
class GetNativeUITreeRequest with EquatableMixin {
  GetNativeUITreeRequest({required this.useNativeViewHierarchy});

  factory GetNativeUITreeRequest.fromJson(Map<String, dynamic> json) =>
      _$GetNativeUITreeRequestFromJson(json);

  final bool useNativeViewHierarchy;

  Map<String, dynamic> toJson() => _$GetNativeUITreeRequestToJson(this);

  @override
  List<Object?> get props => [useNativeViewHierarchy];

  GetNativeUITreeRequest copyWith({bool? useNativeViewHierarchy}) {
    return GetNativeUITreeRequest(
      useNativeViewHierarchy:
          useNativeViewHierarchy ?? this.useNativeViewHierarchy,
    );
  }
}

@JsonSerializable()
class GetNativeUITreeRespone with EquatableMixin {
  GetNativeUITreeRespone({required this.roots});

  factory GetNativeUITreeRespone.fromJson(Map<String, dynamic> json) =>
      _$GetNativeUITreeResponeFromJson(json);

  final List<NativeView> roots;

  Map<String, dynamic> toJson() => _$GetNativeUITreeResponeToJson(this);

  @override
  List<Object?> get props => [roots];

  GetNativeUITreeRespone copyWith({List<NativeView>? roots}) {
    return GetNativeUITreeRespone(roots: roots ?? this.roots);
  }
}

@JsonSerializable()
class NativeView with EquatableMixin {
  NativeView({
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

  factory NativeView.fromJson(Map<String, dynamic> json) =>
      _$NativeViewFromJson(json);

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
  final List<NativeView> children;

  Map<String, dynamic> toJson() => _$NativeViewToJson(this);

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

  NativeView copyWith({
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
    List<NativeView>? children,
  }) {
    return NativeView(
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
class GetNativeViewsResponse with EquatableMixin {
  GetNativeViewsResponse({required this.nativeViews});

  factory GetNativeViewsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetNativeViewsResponseFromJson(json);

  final List<NativeView> nativeViews;

  Map<String, dynamic> toJson() => _$GetNativeViewsResponseToJson(this);

  @override
  List<Object?> get props => [nativeViews];

  GetNativeViewsResponse copyWith({List<NativeView>? nativeViews}) {
    return GetNativeViewsResponse(nativeViews: nativeViews ?? this.nativeViews);
  }
}

@JsonSerializable()
class TapRequest with EquatableMixin {
  TapRequest({
    required this.selector,
    required this.appId,
    this.timeoutMillis,
    this.delayBetweenTapsMillis,
  });

  factory TapRequest.fromJson(Map<String, dynamic> json) =>
      _$TapRequestFromJson(json);

  final Selector selector;
  final String appId;
  final int? timeoutMillis;
  final int? delayBetweenTapsMillis;

  Map<String, dynamic> toJson() => _$TapRequestToJson(this);

  @override
  List<Object?> get props => [
    selector,
    appId,
    timeoutMillis,
    delayBetweenTapsMillis,
  ];

  TapRequest copyWith({
    Selector? selector,
    String? appId,
    int? timeoutMillis,
    int? delayBetweenTapsMillis,
  }) {
    return TapRequest(
      selector: selector ?? this.selector,
      appId: appId ?? this.appId,
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
      delayBetweenTapsMillis:
          delayBetweenTapsMillis ?? this.delayBetweenTapsMillis,
    );
  }
}

@JsonSerializable()
class TapAtRequest with EquatableMixin {
  TapAtRequest({required this.x, required this.y, required this.appId});

  factory TapAtRequest.fromJson(Map<String, dynamic> json) =>
      _$TapAtRequestFromJson(json);

  final double x;
  final double y;
  final String appId;

  Map<String, dynamic> toJson() => _$TapAtRequestToJson(this);

  @override
  List<Object?> get props => [x, y, appId];

  TapAtRequest copyWith({double? x, double? y, String? appId}) {
    return TapAtRequest(
      x: x ?? this.x,
      y: y ?? this.y,
      appId: appId ?? this.appId,
    );
  }
}

@JsonSerializable()
class EnterTextRequest with EquatableMixin {
  EnterTextRequest({
    required this.data,
    required this.appId,
    this.index,
    this.selector,
    required this.keyboardBehavior,
    this.timeoutMillis,
    this.dx,
    this.dy,
  });

  factory EnterTextRequest.fromJson(Map<String, dynamic> json) =>
      _$EnterTextRequestFromJson(json);

  final String data;
  final String appId;
  final int? index;
  final Selector? selector;
  final KeyboardBehavior keyboardBehavior;
  final int? timeoutMillis;
  final double? dx;
  final double? dy;

  Map<String, dynamic> toJson() => _$EnterTextRequestToJson(this);

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

  EnterTextRequest copyWith({
    String? data,
    String? appId,
    int? index,
    Selector? selector,
    KeyboardBehavior? keyboardBehavior,
    int? timeoutMillis,
    double? dx,
    double? dy,
  }) {
    return EnterTextRequest(
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
  List<Object?> get props => [appId, startX, startY, endX, endY, steps];

  SwipeRequest copyWith({
    String? appId,
    double? startX,
    double? startY,
    double? endX,
    double? endY,
    int? steps,
  }) {
    return SwipeRequest(
      appId: appId ?? this.appId,
      startX: startX ?? this.startX,
      startY: startY ?? this.startY,
      endX: endX ?? this.endX,
      endY: endY ?? this.endY,
      steps: steps ?? this.steps,
    );
  }
}

@JsonSerializable()
class WaitUntilVisibleRequest with EquatableMixin {
  WaitUntilVisibleRequest({
    required this.selector,
    required this.appId,
    this.timeoutMillis,
  });

  factory WaitUntilVisibleRequest.fromJson(Map<String, dynamic> json) =>
      _$WaitUntilVisibleRequestFromJson(json);

  final Selector selector;
  final String appId;
  final int? timeoutMillis;

  Map<String, dynamic> toJson() => _$WaitUntilVisibleRequestToJson(this);

  @override
  List<Object?> get props => [selector, appId, timeoutMillis];

  WaitUntilVisibleRequest copyWith({
    Selector? selector,
    String? appId,
    int? timeoutMillis,
  }) {
    return WaitUntilVisibleRequest(
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
class TapOnNotificationRequest with EquatableMixin {
  TapOnNotificationRequest({this.index, this.selector, this.timeoutMillis});

  factory TapOnNotificationRequest.fromJson(Map<String, dynamic> json) =>
      _$TapOnNotificationRequestFromJson(json);

  final int? index;
  final Selector? selector;
  final int? timeoutMillis;

  Map<String, dynamic> toJson() => _$TapOnNotificationRequestToJson(this);

  @override
  List<Object?> get props => [index, selector, timeoutMillis];

  TapOnNotificationRequest copyWith({
    int? index,
    Selector? selector,
    int? timeoutMillis,
  }) {
    return TapOnNotificationRequest(
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
class TakeCameraPhotoRequest with EquatableMixin {
  TakeCameraPhotoRequest({
    this.shutterButtonSelector,
    this.doneButtonSelector,
    this.timeoutMillis,
    required this.appId,
  });

  factory TakeCameraPhotoRequest.fromJson(Map<String, dynamic> json) =>
      _$TakeCameraPhotoRequestFromJson(json);

  final Selector? shutterButtonSelector;
  final Selector? doneButtonSelector;
  final int? timeoutMillis;
  final String appId;

  Map<String, dynamic> toJson() => _$TakeCameraPhotoRequestToJson(this);

  @override
  List<Object?> get props => [
    shutterButtonSelector,
    doneButtonSelector,
    timeoutMillis,
    appId,
  ];

  TakeCameraPhotoRequest copyWith({
    Selector? shutterButtonSelector,
    Selector? doneButtonSelector,
    int? timeoutMillis,
    String? appId,
  }) {
    return TakeCameraPhotoRequest(
      shutterButtonSelector:
          shutterButtonSelector ?? this.shutterButtonSelector,
      doneButtonSelector: doneButtonSelector ?? this.doneButtonSelector,
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
      appId: appId ?? this.appId,
    );
  }
}

@JsonSerializable()
class PickImageFromGalleryRequest with EquatableMixin {
  PickImageFromGalleryRequest({
    this.imageSelector,
    this.imageIndex,
    this.timeoutMillis,
    required this.appId,
  });

  factory PickImageFromGalleryRequest.fromJson(Map<String, dynamic> json) =>
      _$PickImageFromGalleryRequestFromJson(json);

  final Selector? imageSelector;
  final int? imageIndex;
  final int? timeoutMillis;
  final String appId;

  Map<String, dynamic> toJson() => _$PickImageFromGalleryRequestToJson(this);

  @override
  List<Object?> get props => [imageSelector, imageIndex, timeoutMillis, appId];

  PickImageFromGalleryRequest copyWith({
    Selector? imageSelector,
    int? imageIndex,
    int? timeoutMillis,
    String? appId,
  }) {
    return PickImageFromGalleryRequest(
      imageSelector: imageSelector ?? this.imageSelector,
      imageIndex: imageIndex ?? this.imageIndex,
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
      appId: appId ?? this.appId,
    );
  }
}

@JsonSerializable()
class PickMultipleImagesFromGalleryRequest with EquatableMixin {
  PickMultipleImagesFromGalleryRequest({
    this.imageSelector,
    required this.imageIndexes,
    this.timeoutMillis,
    required this.appId,
  });

  factory PickMultipleImagesFromGalleryRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$PickMultipleImagesFromGalleryRequestFromJson(json);

  final Selector? imageSelector;
  final List<int> imageIndexes;
  final int? timeoutMillis;
  final String appId;

  Map<String, dynamic> toJson() =>
      _$PickMultipleImagesFromGalleryRequestToJson(this);

  @override
  List<Object?> get props => [
    imageSelector,
    imageIndexes,
    timeoutMillis,
    appId,
  ];

  PickMultipleImagesFromGalleryRequest copyWith({
    Selector? imageSelector,
    List<int>? imageIndexes,
    int? timeoutMillis,
    String? appId,
  }) {
    return PickMultipleImagesFromGalleryRequest(
      imageSelector: imageSelector ?? this.imageSelector,
      imageIndexes: imageIndexes ?? this.imageIndexes,
      timeoutMillis: timeoutMillis ?? this.timeoutMillis,
      appId: appId ?? this.appId,
    );
  }
}

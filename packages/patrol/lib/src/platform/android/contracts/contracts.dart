//
//  Generated code. Do not modify.
//  source: schema.dart
//
// ignore_for_file: public_member_api_docs

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
class GetNativeViewsResponse with EquatableMixin {
  GetNativeViewsResponse({required this.nativeViews});

  factory GetNativeViewsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetNativeViewsResponseFromJson(json);

  final List<NativeView> nativeViews;

  Map<String, dynamic> toJson() => _$GetNativeViewsResponseToJson(this);

  @override
  List<Object?> get props => [nativeViews];
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
}

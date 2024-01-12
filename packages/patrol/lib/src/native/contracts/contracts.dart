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

@JsonSerializable()
class DartGroupEntry with EquatableMixin {
  DartGroupEntry({
    required this.name,
    required this.type,
    required this.entries,
  });

  factory DartGroupEntry.fromJson(Map<String, dynamic> json) =>
      _$DartGroupEntryFromJson(json);

  final String name;
  final GroupEntryType type;
  final List<DartGroupEntry> entries;

  Map<String, dynamic> toJson() => _$DartGroupEntryToJson(this);

  @override
  List<Object?> get props => [
        name,
        type,
        entries,
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
    required this.selector,
    required this.appId,
  });

  factory GetNativeViewsRequest.fromJson(Map<String, dynamic> json) =>
      _$GetNativeViewsRequestFromJson(json);

  final Selector selector;
  final String appId;

  Map<String, dynamic> toJson() => _$GetNativeViewsRequestToJson(this);

  @override
  List<Object?> get props => [
        selector,
        appId,
      ];
}

@JsonSerializable()
class GetNativeUITreeRequest with EquatableMixin {
  GetNativeUITreeRequest({
    this.iosInstalledApps,
  });

  factory GetNativeUITreeRequest.fromJson(Map<String, dynamic> json) =>
      _$GetNativeUITreeRequestFromJson(json);

  final List<String>? iosInstalledApps;

  Map<String, dynamic> toJson() => _$GetNativeUITreeRequestToJson(this);

  @override
  List<Object?> get props => [
        iosInstalledApps,
      ];
}

@JsonSerializable()
class GetNativeUITreeRespone with EquatableMixin {
  GetNativeUITreeRespone({
    required this.roots,
  });

  factory GetNativeUITreeRespone.fromJson(Map<String, dynamic> json) =>
      _$GetNativeUITreeResponeFromJson(json);

  final List<NativeView> roots;

  Map<String, dynamic> toJson() => _$GetNativeUITreeResponeToJson(this);

  @override
  List<Object?> get props => [
        roots,
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
  });

  factory GetNativeViewsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetNativeViewsResponseFromJson(json);

  final List<NativeView> nativeViews;

  Map<String, dynamic> toJson() => _$GetNativeViewsResponseToJson(this);

  @override
  List<Object?> get props => [
        nativeViews,
      ];
}

@JsonSerializable()
class TapRequest with EquatableMixin {
  TapRequest({
    required this.selector,
    required this.appId,
    this.timeoutMillis,
  });

  factory TapRequest.fromJson(Map<String, dynamic> json) =>
      _$TapRequestFromJson(json);

  final Selector selector;
  final String appId;
  final int? timeoutMillis;

  Map<String, dynamic> toJson() => _$TapRequestToJson(this);

  @override
  List<Object?> get props => [
        selector,
        appId,
        timeoutMillis,
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
    required this.keyboardBehavior,
    this.timeoutMillis,
  });

  factory EnterTextRequest.fromJson(Map<String, dynamic> json) =>
      _$EnterTextRequestFromJson(json);

  final String data;
  final String appId;
  final int? index;
  final Selector? selector;
  final KeyboardBehavior keyboardBehavior;
  final int? timeoutMillis;

  Map<String, dynamic> toJson() => _$EnterTextRequestToJson(this);

  @override
  List<Object?> get props => [
        data,
        appId,
        index,
        selector,
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
  List<Object?> get props => [
        selector,
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
    this.timeoutMillis,
  });

  factory TapOnNotificationRequest.fromJson(Map<String, dynamic> json) =>
      _$TapOnNotificationRequestFromJson(json);

  final int? index;
  final Selector? selector;
  final int? timeoutMillis;

  Map<String, dynamic> toJson() => _$TapOnNotificationRequestToJson(this);

  @override
  List<Object?> get props => [
        index,
        selector,
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

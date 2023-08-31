//
//  Generated code. Do not modify.
//  source: schema.dart
//
// ignore_for_file: public_member_api_docs

import 'package:json_annotation/json_annotation.dart';

part 'contracts.g.dart';

enum RunDartTestResponseResult {
  @JsonValue('success')
  success,
  @JsonValue('skipped')
  skipped,
  @JsonValue('failure')
  failure
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
class DartTestCase {
  DartTestCase({
    required this.name,
  });

  factory DartTestCase.fromJson(Map<String, dynamic> json) =>
      _$DartTestCaseFromJson(json);

  final String name;

  Map<String, dynamic> toJson() => _$DartTestCaseToJson(this);
}

@JsonSerializable()
class DartTestGroup {
  DartTestGroup({
    required this.name,
    required this.tests,
    required this.groups,
  });

  factory DartTestGroup.fromJson(Map<String, dynamic> json) =>
      _$DartTestGroupFromJson(json);

  final String name;
  final List<DartTestCase> tests;
  final List<DartTestGroup> groups;

  Map<String, dynamic> toJson() => _$DartTestGroupToJson(this);
}

@JsonSerializable()
class ListDartTestsResponse {
  ListDartTestsResponse({
    required this.group,
  });

  factory ListDartTestsResponse.fromJson(Map<String, dynamic> json) =>
      _$ListDartTestsResponseFromJson(json);

  final DartTestGroup group;

  Map<String, dynamic> toJson() => _$ListDartTestsResponseToJson(this);
}

@JsonSerializable()
class RunDartTestRequest {
  RunDartTestRequest({
    required this.name,
  });

  factory RunDartTestRequest.fromJson(Map<String, dynamic> json) =>
      _$RunDartTestRequestFromJson(json);

  final String name;

  Map<String, dynamic> toJson() => _$RunDartTestRequestToJson(this);
}

@JsonSerializable()
class RunDartTestResponse {
  RunDartTestResponse({
    required this.result,
    this.details,
  });

  factory RunDartTestResponse.fromJson(Map<String, dynamic> json) =>
      _$RunDartTestResponseFromJson(json);

  final RunDartTestResponseResult result;
  final String? details;

  Map<String, dynamic> toJson() => _$RunDartTestResponseToJson(this);
}

@JsonSerializable()
class ConfigureRequest {
  ConfigureRequest({
    required this.findTimeoutMillis,
  });

  factory ConfigureRequest.fromJson(Map<String, dynamic> json) =>
      _$ConfigureRequestFromJson(json);

  final int findTimeoutMillis;

  Map<String, dynamic> toJson() => _$ConfigureRequestToJson(this);
}

@JsonSerializable()
class OpenAppRequest {
  OpenAppRequest({
    required this.appId,
  });

  factory OpenAppRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenAppRequestFromJson(json);

  final String appId;

  Map<String, dynamic> toJson() => _$OpenAppRequestToJson(this);
}

@JsonSerializable()
class OpenQuickSettingsRequest {
  OpenQuickSettingsRequest();

  factory OpenQuickSettingsRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenQuickSettingsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OpenQuickSettingsRequestToJson(this);
}

@JsonSerializable()
class Selector {
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
}

@JsonSerializable()
class GetNativeViewsRequest {
  GetNativeViewsRequest({
    required this.selector,
    required this.appId,
  });

  factory GetNativeViewsRequest.fromJson(Map<String, dynamic> json) =>
      _$GetNativeViewsRequestFromJson(json);

  final Selector selector;
  final String appId;

  Map<String, dynamic> toJson() => _$GetNativeViewsRequestToJson(this);
}

@JsonSerializable()
class NativeView {
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
}

@JsonSerializable()
class GetNativeViewsResponse {
  GetNativeViewsResponse({
    required this.nativeViews,
  });

  factory GetNativeViewsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetNativeViewsResponseFromJson(json);

  final List<NativeView> nativeViews;

  Map<String, dynamic> toJson() => _$GetNativeViewsResponseToJson(this);
}

@JsonSerializable()
class TapRequest {
  TapRequest({
    required this.selector,
    required this.appId,
  });

  factory TapRequest.fromJson(Map<String, dynamic> json) =>
      _$TapRequestFromJson(json);

  final Selector selector;
  final String appId;

  Map<String, dynamic> toJson() => _$TapRequestToJson(this);
}

@JsonSerializable()
class EnterTextRequest {
  EnterTextRequest({
    required this.data,
    required this.appId,
    this.index,
    this.selector,
    required this.showKeyboard,
  });

  factory EnterTextRequest.fromJson(Map<String, dynamic> json) =>
      _$EnterTextRequestFromJson(json);

  final String data;
  final String appId;
  final int? index;
  final Selector? selector;
  final bool showKeyboard;

  Map<String, dynamic> toJson() => _$EnterTextRequestToJson(this);
}

@JsonSerializable()
class SwipeRequest {
  SwipeRequest({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.steps,
  });

  factory SwipeRequest.fromJson(Map<String, dynamic> json) =>
      _$SwipeRequestFromJson(json);

  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final int steps;

  Map<String, dynamic> toJson() => _$SwipeRequestToJson(this);
}

@JsonSerializable()
class WaitUntilVisibleRequest {
  WaitUntilVisibleRequest({
    required this.selector,
    required this.appId,
  });

  factory WaitUntilVisibleRequest.fromJson(Map<String, dynamic> json) =>
      _$WaitUntilVisibleRequestFromJson(json);

  final Selector selector;
  final String appId;

  Map<String, dynamic> toJson() => _$WaitUntilVisibleRequestToJson(this);
}

@JsonSerializable()
class DarkModeRequest {
  DarkModeRequest({
    required this.appId,
  });

  factory DarkModeRequest.fromJson(Map<String, dynamic> json) =>
      _$DarkModeRequestFromJson(json);

  final String appId;

  Map<String, dynamic> toJson() => _$DarkModeRequestToJson(this);
}

@JsonSerializable()
class Notification {
  Notification({
    this.appName,
    required this.title,
    required this.content,
    required this.raw,
  });

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  final String? appName;
  final String title;
  final String content;
  final String raw;

  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}

@JsonSerializable()
class GetNotificationsResponse {
  GetNotificationsResponse({
    required this.notifications,
  });

  factory GetNotificationsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetNotificationsResponseFromJson(json);

  final List<Notification> notifications;

  Map<String, dynamic> toJson() => _$GetNotificationsResponseToJson(this);
}

@JsonSerializable()
class GetNotificationsRequest {
  GetNotificationsRequest();

  factory GetNotificationsRequest.fromJson(Map<String, dynamic> json) =>
      _$GetNotificationsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GetNotificationsRequestToJson(this);
}

@JsonSerializable()
class TapOnNotificationRequest {
  TapOnNotificationRequest({
    this.index,
    this.selector,
  });

  factory TapOnNotificationRequest.fromJson(Map<String, dynamic> json) =>
      _$TapOnNotificationRequestFromJson(json);

  final int? index;
  final Selector? selector;

  Map<String, dynamic> toJson() => _$TapOnNotificationRequestToJson(this);
}

@JsonSerializable()
class PermissionDialogVisibleResponse {
  PermissionDialogVisibleResponse({
    required this.visible,
  });

  factory PermissionDialogVisibleResponse.fromJson(Map<String, dynamic> json) =>
      _$PermissionDialogVisibleResponseFromJson(json);

  final bool visible;

  Map<String, dynamic> toJson() =>
      _$PermissionDialogVisibleResponseToJson(this);
}

@JsonSerializable()
class PermissionDialogVisibleRequest {
  PermissionDialogVisibleRequest({
    required this.timeoutMillis,
  });

  factory PermissionDialogVisibleRequest.fromJson(Map<String, dynamic> json) =>
      _$PermissionDialogVisibleRequestFromJson(json);

  final int timeoutMillis;

  Map<String, dynamic> toJson() => _$PermissionDialogVisibleRequestToJson(this);
}

@JsonSerializable()
class HandlePermissionRequest {
  HandlePermissionRequest({
    required this.code,
  });

  factory HandlePermissionRequest.fromJson(Map<String, dynamic> json) =>
      _$HandlePermissionRequestFromJson(json);

  final HandlePermissionRequestCode code;

  Map<String, dynamic> toJson() => _$HandlePermissionRequestToJson(this);
}

@JsonSerializable()
class SetLocationAccuracyRequest {
  SetLocationAccuracyRequest({
    required this.locationAccuracy,
  });

  factory SetLocationAccuracyRequest.fromJson(Map<String, dynamic> json) =>
      _$SetLocationAccuracyRequestFromJson(json);

  final SetLocationAccuracyRequestLocationAccuracy locationAccuracy;

  Map<String, dynamic> toJson() => _$SetLocationAccuracyRequestToJson(this);
}

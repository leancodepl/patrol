// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contracts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DartTestCase _$DartTestCaseFromJson(Map<String, dynamic> json) => DartTestCase(
      name: json['name'] as String,
    );

Map<String, dynamic> _$DartTestCaseToJson(DartTestCase instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

DartTestGroup _$DartTestGroupFromJson(Map<String, dynamic> json) =>
    DartTestGroup(
      name: json['name'] as String,
      tests: (json['tests'] as List<dynamic>)
          .map((e) => DartTestCase.fromJson(e as Map<String, dynamic>))
          .toList(),
      groups: (json['groups'] as List<dynamic>)
          .map((e) => DartTestGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DartTestGroupToJson(DartTestGroup instance) =>
    <String, dynamic>{
      'name': instance.name,
      'tests': instance.tests,
      'groups': instance.groups,
    };

ListDartTestsResponse _$ListDartTestsResponseFromJson(
        Map<String, dynamic> json) =>
    ListDartTestsResponse(
      group: DartTestGroup.fromJson(json['group'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ListDartTestsResponseToJson(
        ListDartTestsResponse instance) =>
    <String, dynamic>{
      'group': instance.group,
    };

RunDartTestRequest _$RunDartTestRequestFromJson(Map<String, dynamic> json) =>
    RunDartTestRequest(
      name: json['name'] as String,
    );

Map<String, dynamic> _$RunDartTestRequestToJson(RunDartTestRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

RunDartTestResponse _$RunDartTestResponseFromJson(Map<String, dynamic> json) =>
    RunDartTestResponse(
      result: $enumDecode(_$RunDartTestResponseResultEnumMap, json['result']),
      details: json['details'] as String?,
    );

Map<String, dynamic> _$RunDartTestResponseToJson(
        RunDartTestResponse instance) =>
    <String, dynamic>{
      'result': _$RunDartTestResponseResultEnumMap[instance.result]!,
      'details': instance.details,
    };

const _$RunDartTestResponseResultEnumMap = {
  RunDartTestResponseResult.success: 'success',
  RunDartTestResponseResult.skipped: 'skipped',
  RunDartTestResponseResult.failure: 'failure',
};

ConfigureRequest _$ConfigureRequestFromJson(Map<String, dynamic> json) =>
    ConfigureRequest(
      findTimeoutMillis: json['findTimeoutMillis'] as int,
    );

Map<String, dynamic> _$ConfigureRequestToJson(ConfigureRequest instance) =>
    <String, dynamic>{
      'findTimeoutMillis': instance.findTimeoutMillis,
    };

OpenAppRequest _$OpenAppRequestFromJson(Map<String, dynamic> json) =>
    OpenAppRequest(
      appId: json['appId'] as String,
    );

Map<String, dynamic> _$OpenAppRequestToJson(OpenAppRequest instance) =>
    <String, dynamic>{
      'appId': instance.appId,
    };

OpenQuickSettingsRequest _$OpenQuickSettingsRequestFromJson(
        Map<String, dynamic> json) =>
    OpenQuickSettingsRequest();

Map<String, dynamic> _$OpenQuickSettingsRequestToJson(
        OpenQuickSettingsRequest instance) =>
    <String, dynamic>{};

Selector _$SelectorFromJson(Map<String, dynamic> json) => Selector(
      text: json['text'] as String?,
      textStartsWith: json['textStartsWith'] as String?,
      textContains: json['textContains'] as String?,
      className: json['className'] as String?,
      contentDescription: json['contentDescription'] as String?,
      contentDescriptionStartsWith:
          json['contentDescriptionStartsWith'] as String?,
      contentDescriptionContains: json['contentDescriptionContains'] as String?,
      resourceId: json['resourceId'] as String?,
      instance: json['instance'] as int?,
      enabled: json['enabled'] as bool?,
      focused: json['focused'] as bool?,
      pkg: json['pkg'] as String?,
    );

Map<String, dynamic> _$SelectorToJson(Selector instance) => <String, dynamic>{
      'text': instance.text,
      'textStartsWith': instance.textStartsWith,
      'textContains': instance.textContains,
      'className': instance.className,
      'contentDescription': instance.contentDescription,
      'contentDescriptionStartsWith': instance.contentDescriptionStartsWith,
      'contentDescriptionContains': instance.contentDescriptionContains,
      'resourceId': instance.resourceId,
      'instance': instance.instance,
      'enabled': instance.enabled,
      'focused': instance.focused,
      'pkg': instance.pkg,
    };

GetNativeViewsRequest _$GetNativeViewsRequestFromJson(
        Map<String, dynamic> json) =>
    GetNativeViewsRequest(
      selector: Selector.fromJson(json['selector'] as Map<String, dynamic>),
      appId: json['appId'] as String,
    );

Map<String, dynamic> _$GetNativeViewsRequestToJson(
        GetNativeViewsRequest instance) =>
    <String, dynamic>{
      'selector': instance.selector,
      'appId': instance.appId,
    };

NativeView _$NativeViewFromJson(Map<String, dynamic> json) => NativeView(
      className: json['className'] as String,
      text: json['text'] as String,
      contentDescription: json['contentDescription'] as String,
      focused: json['focused'] as bool,
      enabled: json['enabled'] as bool,
      childCount: json['childCount'] as int,
      resourceName: json['resourceName'] as String,
      applicationPackage: json['applicationPackage'] as String,
      children: (json['children'] as List<dynamic>)
          .map((e) => NativeView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NativeViewToJson(NativeView instance) =>
    <String, dynamic>{
      'className': instance.className,
      'text': instance.text,
      'contentDescription': instance.contentDescription,
      'focused': instance.focused,
      'enabled': instance.enabled,
      'childCount': instance.childCount,
      'resourceName': instance.resourceName,
      'applicationPackage': instance.applicationPackage,
      'children': instance.children,
    };

GetNativeViewsResponse _$GetNativeViewsResponseFromJson(
        Map<String, dynamic> json) =>
    GetNativeViewsResponse(
      nativeViews: (json['nativeViews'] as List<dynamic>)
          .map((e) => NativeView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetNativeViewsResponseToJson(
        GetNativeViewsResponse instance) =>
    <String, dynamic>{
      'nativeViews': instance.nativeViews,
    };

TapRequest _$TapRequestFromJson(Map<String, dynamic> json) => TapRequest(
      selector: Selector.fromJson(json['selector'] as Map<String, dynamic>),
      appId: json['appId'] as String,
    );

Map<String, dynamic> _$TapRequestToJson(TapRequest instance) =>
    <String, dynamic>{
      'selector': instance.selector,
      'appId': instance.appId,
    };

EnterTextRequest _$EnterTextRequestFromJson(Map<String, dynamic> json) =>
    EnterTextRequest(
      data: json['data'] as String,
      appId: json['appId'] as String,
      index: json['index'] as int?,
      selector: json['selector'] == null
          ? null
          : Selector.fromJson(json['selector'] as Map<String, dynamic>),
      showKeyboard: json['showKeyboard'] as bool?,
    );

Map<String, dynamic> _$EnterTextRequestToJson(EnterTextRequest instance) =>
    <String, dynamic>{
      'data': instance.data,
      'appId': instance.appId,
      'index': instance.index,
      'selector': instance.selector,
      'showKeyboard': instance.showKeyboard,
    };

SwipeRequest _$SwipeRequestFromJson(Map<String, dynamic> json) => SwipeRequest(
      startX: (json['startX'] as num).toDouble(),
      startY: (json['startY'] as num).toDouble(),
      endX: (json['endX'] as num).toDouble(),
      endY: (json['endY'] as num).toDouble(),
      steps: json['steps'] as int,
      appId: json['appId'] as String,
    );

Map<String, dynamic> _$SwipeRequestToJson(SwipeRequest instance) =>
    <String, dynamic>{
      'startX': instance.startX,
      'startY': instance.startY,
      'endX': instance.endX,
      'endY': instance.endY,
      'steps': instance.steps,
      'appId': instance.appId,
    };

WaitUntilVisibleRequest _$WaitUntilVisibleRequestFromJson(
        Map<String, dynamic> json) =>
    WaitUntilVisibleRequest(
      selector: Selector.fromJson(json['selector'] as Map<String, dynamic>),
      appId: json['appId'] as String,
    );

Map<String, dynamic> _$WaitUntilVisibleRequestToJson(
        WaitUntilVisibleRequest instance) =>
    <String, dynamic>{
      'selector': instance.selector,
      'appId': instance.appId,
    };

DarkModeRequest _$DarkModeRequestFromJson(Map<String, dynamic> json) =>
    DarkModeRequest(
      appId: json['appId'] as String,
    );

Map<String, dynamic> _$DarkModeRequestToJson(DarkModeRequest instance) =>
    <String, dynamic>{
      'appId': instance.appId,
    };

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
      appName: json['appName'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      raw: json['raw'] as String,
    );

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'appName': instance.appName,
      'title': instance.title,
      'content': instance.content,
      'raw': instance.raw,
    };

GetNotificationsResponse _$GetNotificationsResponseFromJson(
        Map<String, dynamic> json) =>
    GetNotificationsResponse(
      notifications: (json['notifications'] as List<dynamic>)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetNotificationsResponseToJson(
        GetNotificationsResponse instance) =>
    <String, dynamic>{
      'notifications': instance.notifications,
    };

GetNotificationsRequest _$GetNotificationsRequestFromJson(
        Map<String, dynamic> json) =>
    GetNotificationsRequest();

Map<String, dynamic> _$GetNotificationsRequestToJson(
        GetNotificationsRequest instance) =>
    <String, dynamic>{};

TapOnNotificationRequest _$TapOnNotificationRequestFromJson(
        Map<String, dynamic> json) =>
    TapOnNotificationRequest(
      index: json['index'] as int?,
      selector: json['selector'] == null
          ? null
          : Selector.fromJson(json['selector'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TapOnNotificationRequestToJson(
        TapOnNotificationRequest instance) =>
    <String, dynamic>{
      'index': instance.index,
      'selector': instance.selector,
    };

PermissionDialogVisibleResponse _$PermissionDialogVisibleResponseFromJson(
        Map<String, dynamic> json) =>
    PermissionDialogVisibleResponse(
      visible: json['visible'] as bool,
    );

Map<String, dynamic> _$PermissionDialogVisibleResponseToJson(
        PermissionDialogVisibleResponse instance) =>
    <String, dynamic>{
      'visible': instance.visible,
    };

PermissionDialogVisibleRequest _$PermissionDialogVisibleRequestFromJson(
        Map<String, dynamic> json) =>
    PermissionDialogVisibleRequest(
      timeoutMillis: json['timeoutMillis'] as int,
    );

Map<String, dynamic> _$PermissionDialogVisibleRequestToJson(
        PermissionDialogVisibleRequest instance) =>
    <String, dynamic>{
      'timeoutMillis': instance.timeoutMillis,
    };

HandlePermissionRequest _$HandlePermissionRequestFromJson(
        Map<String, dynamic> json) =>
    HandlePermissionRequest(
      code: $enumDecode(_$HandlePermissionRequestCodeEnumMap, json['code']),
    );

Map<String, dynamic> _$HandlePermissionRequestToJson(
        HandlePermissionRequest instance) =>
    <String, dynamic>{
      'code': _$HandlePermissionRequestCodeEnumMap[instance.code]!,
    };

const _$HandlePermissionRequestCodeEnumMap = {
  HandlePermissionRequestCode.whileUsing: 'whileUsing',
  HandlePermissionRequestCode.onlyThisTime: 'onlyThisTime',
  HandlePermissionRequestCode.denied: 'denied',
};

SetLocationAccuracyRequest _$SetLocationAccuracyRequestFromJson(
        Map<String, dynamic> json) =>
    SetLocationAccuracyRequest(
      locationAccuracy: $enumDecode(
          _$SetLocationAccuracyRequestLocationAccuracyEnumMap,
          json['locationAccuracy']),
    );

Map<String, dynamic> _$SetLocationAccuracyRequestToJson(
        SetLocationAccuracyRequest instance) =>
    <String, dynamic>{
      'locationAccuracy': _$SetLocationAccuracyRequestLocationAccuracyEnumMap[
          instance.locationAccuracy]!,
    };

const _$SetLocationAccuracyRequestLocationAccuracyEnumMap = {
  SetLocationAccuracyRequestLocationAccuracy.coarse: 'coarse',
  SetLocationAccuracyRequestLocationAccuracy.fine: 'fine',
};

///
//  Generated code. Do not modify.
//  source: contracts.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'contracts.pb.dart' as $0;
export 'contracts.pb.dart';

class PatrolAppServiceClient extends $grpc.Client {
  static final _$listDartTests =
      $grpc.ClientMethod<$0.Empty, $0.ListDartTestsResponse>(
          '/patrol.PatrolAppService/listDartTests',
          ($0.Empty value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.ListDartTestsResponse.fromBuffer(value));
  static final _$runDartTest =
      $grpc.ClientMethod<$0.RunDartTestRequest, $0.Empty>(
          '/patrol.PatrolAppService/runDartTest',
          ($0.RunDartTestRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));

  PatrolAppServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.ListDartTestsResponse> listDartTests($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listDartTests, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> runDartTest($0.RunDartTestRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$runDartTest, request, options: options);
  }
}

abstract class PatrolAppServiceBase extends $grpc.Service {
  $core.String get $name => 'patrol.PatrolAppService';

  PatrolAppServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ListDartTestsResponse>(
        'listDartTests',
        listDartTests_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ListDartTestsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RunDartTestRequest, $0.Empty>(
        'runDartTest',
        runDartTest_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RunDartTestRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$0.ListDartTestsResponse> listDartTests_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return listDartTests(call, await request);
  }

  $async.Future<$0.Empty> runDartTest_Pre($grpc.ServiceCall call,
      $async.Future<$0.RunDartTestRequest> request) async {
    return runDartTest(call, await request);
  }

  $async.Future<$0.ListDartTestsResponse> listDartTests(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> runDartTest(
      $grpc.ServiceCall call, $0.RunDartTestRequest request);
}

class NativeAutomatorClient extends $grpc.Client {
  static final _$configure = $grpc.ClientMethod<$0.ConfigureRequest, $0.Empty>(
      '/patrol.NativeAutomator/configure',
      ($0.ConfigureRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$pressHome = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/patrol.NativeAutomator/pressHome',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$pressBack = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/patrol.NativeAutomator/pressBack',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$pressRecentApps = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/patrol.NativeAutomator/pressRecentApps',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$doublePressRecentApps = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/patrol.NativeAutomator/doublePressRecentApps',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$openApp = $grpc.ClientMethod<$0.OpenAppRequest, $0.Empty>(
      '/patrol.NativeAutomator/openApp',
      ($0.OpenAppRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$openQuickSettings =
      $grpc.ClientMethod<$0.OpenQuickSettingsRequest, $0.Empty>(
          '/patrol.NativeAutomator/openQuickSettings',
          ($0.OpenQuickSettingsRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$getNativeViews =
      $grpc.ClientMethod<$0.GetNativeViewsRequest, $0.GetNativeViewsResponse>(
          '/patrol.NativeAutomator/getNativeViews',
          ($0.GetNativeViewsRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.GetNativeViewsResponse.fromBuffer(value));
  static final _$tap = $grpc.ClientMethod<$0.TapRequest, $0.Empty>(
      '/patrol.NativeAutomator/tap',
      ($0.TapRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$doubleTap = $grpc.ClientMethod<$0.TapRequest, $0.Empty>(
      '/patrol.NativeAutomator/doubleTap',
      ($0.TapRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$enterText = $grpc.ClientMethod<$0.EnterTextRequest, $0.Empty>(
      '/patrol.NativeAutomator/enterText',
      ($0.EnterTextRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$swipe = $grpc.ClientMethod<$0.SwipeRequest, $0.Empty>(
      '/patrol.NativeAutomator/swipe',
      ($0.SwipeRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$enableAirplaneMode = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/patrol.NativeAutomator/enableAirplaneMode',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$disableAirplaneMode = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/patrol.NativeAutomator/disableAirplaneMode',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$enableWiFi = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/patrol.NativeAutomator/enableWiFi',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$disableWiFi = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/patrol.NativeAutomator/disableWiFi',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$enableCellular = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/patrol.NativeAutomator/enableCellular',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$disableCellular = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/patrol.NativeAutomator/disableCellular',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$enableBluetooth = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/patrol.NativeAutomator/enableBluetooth',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$disableBluetooth = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/patrol.NativeAutomator/disableBluetooth',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$enableDarkMode =
      $grpc.ClientMethod<$0.DarkModeRequest, $0.Empty>(
          '/patrol.NativeAutomator/enableDarkMode',
          ($0.DarkModeRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$disableDarkMode =
      $grpc.ClientMethod<$0.DarkModeRequest, $0.Empty>(
          '/patrol.NativeAutomator/disableDarkMode',
          ($0.DarkModeRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$openNotifications = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/patrol.NativeAutomator/openNotifications',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$closeNotifications = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/patrol.NativeAutomator/closeNotifications',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$closeHeadsUpNotification =
      $grpc.ClientMethod<$0.Empty, $0.Empty>(
          '/patrol.NativeAutomator/closeHeadsUpNotification',
          ($0.Empty value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$getNotifications = $grpc.ClientMethod<
          $0.GetNotificationsRequest, $0.GetNotificationsResponse>(
      '/patrol.NativeAutomator/getNotifications',
      ($0.GetNotificationsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.GetNotificationsResponse.fromBuffer(value));
  static final _$tapOnNotification =
      $grpc.ClientMethod<$0.TapOnNotificationRequest, $0.Empty>(
          '/patrol.NativeAutomator/tapOnNotification',
          ($0.TapOnNotificationRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$isPermissionDialogVisible = $grpc.ClientMethod<
          $0.PermissionDialogVisibleRequest,
          $0.PermissionDialogVisibleResponse>(
      '/patrol.NativeAutomator/isPermissionDialogVisible',
      ($0.PermissionDialogVisibleRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.PermissionDialogVisibleResponse.fromBuffer(value));
  static final _$handlePermissionDialog =
      $grpc.ClientMethod<$0.HandlePermissionRequest, $0.Empty>(
          '/patrol.NativeAutomator/handlePermissionDialog',
          ($0.HandlePermissionRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$setLocationAccuracy =
      $grpc.ClientMethod<$0.SetLocationAccuracyRequest, $0.Empty>(
          '/patrol.NativeAutomator/setLocationAccuracy',
          ($0.SetLocationAccuracyRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$debug = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/patrol.NativeAutomator/debug',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$markPatrolAppServiceReady =
      $grpc.ClientMethod<$0.Empty, $0.Empty>(
          '/patrol.NativeAutomator/markPatrolAppServiceReady',
          ($0.Empty value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));

  NativeAutomatorClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.Empty> configure($0.ConfigureRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$configure, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> pressHome($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$pressHome, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> pressBack($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$pressBack, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> pressRecentApps($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$pressRecentApps, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> doublePressRecentApps($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$doublePressRecentApps, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> openApp($0.OpenAppRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$openApp, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> openQuickSettings(
      $0.OpenQuickSettingsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$openQuickSettings, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetNativeViewsResponse> getNativeViews(
      $0.GetNativeViewsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getNativeViews, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> tap($0.TapRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$tap, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> doubleTap($0.TapRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$doubleTap, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> enterText($0.EnterTextRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$enterText, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> swipe($0.SwipeRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$swipe, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> enableAirplaneMode($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$enableAirplaneMode, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> disableAirplaneMode($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$disableAirplaneMode, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> enableWiFi($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$enableWiFi, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> disableWiFi($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$disableWiFi, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> enableCellular($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$enableCellular, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> disableCellular($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$disableCellular, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> enableBluetooth($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$enableBluetooth, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> disableBluetooth($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$disableBluetooth, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> enableDarkMode($0.DarkModeRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$enableDarkMode, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> disableDarkMode($0.DarkModeRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$disableDarkMode, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> openNotifications($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$openNotifications, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> closeNotifications($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$closeNotifications, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> closeHeadsUpNotification($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$closeHeadsUpNotification, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.GetNotificationsResponse> getNotifications(
      $0.GetNotificationsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getNotifications, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> tapOnNotification(
      $0.TapOnNotificationRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$tapOnNotification, request, options: options);
  }

  $grpc.ResponseFuture<$0.PermissionDialogVisibleResponse>
      isPermissionDialogVisible($0.PermissionDialogVisibleRequest request,
          {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$isPermissionDialogVisible, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.Empty> handlePermissionDialog(
      $0.HandlePermissionRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$handlePermissionDialog, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.Empty> setLocationAccuracy(
      $0.SetLocationAccuracyRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setLocationAccuracy, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> debug($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$debug, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> markPatrolAppServiceReady($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$markPatrolAppServiceReady, request,
        options: options);
  }
}

abstract class NativeAutomatorServiceBase extends $grpc.Service {
  $core.String get $name => 'patrol.NativeAutomator';

  NativeAutomatorServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ConfigureRequest, $0.Empty>(
        'configure',
        configure_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ConfigureRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'pressHome',
        pressHome_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'pressBack',
        pressBack_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'pressRecentApps',
        pressRecentApps_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'doublePressRecentApps',
        doublePressRecentApps_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.OpenAppRequest, $0.Empty>(
        'openApp',
        openApp_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.OpenAppRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.OpenQuickSettingsRequest, $0.Empty>(
        'openQuickSettings',
        openQuickSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.OpenQuickSettingsRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetNativeViewsRequest,
            $0.GetNativeViewsResponse>(
        'getNativeViews',
        getNativeViews_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetNativeViewsRequest.fromBuffer(value),
        ($0.GetNativeViewsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TapRequest, $0.Empty>(
        'tap',
        tap_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TapRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TapRequest, $0.Empty>(
        'doubleTap',
        doubleTap_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TapRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EnterTextRequest, $0.Empty>(
        'enterText',
        enterText_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EnterTextRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SwipeRequest, $0.Empty>(
        'swipe',
        swipe_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SwipeRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'enableAirplaneMode',
        enableAirplaneMode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'disableAirplaneMode',
        disableAirplaneMode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'enableWiFi',
        enableWiFi_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'disableWiFi',
        disableWiFi_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'enableCellular',
        enableCellular_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'disableCellular',
        disableCellular_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'enableBluetooth',
        enableBluetooth_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'disableBluetooth',
        disableBluetooth_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DarkModeRequest, $0.Empty>(
        'enableDarkMode',
        enableDarkMode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DarkModeRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DarkModeRequest, $0.Empty>(
        'disableDarkMode',
        disableDarkMode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DarkModeRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'openNotifications',
        openNotifications_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'closeNotifications',
        closeNotifications_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'closeHeadsUpNotification',
        closeHeadsUpNotification_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetNotificationsRequest,
            $0.GetNotificationsResponse>(
        'getNotifications',
        getNotifications_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetNotificationsRequest.fromBuffer(value),
        ($0.GetNotificationsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TapOnNotificationRequest, $0.Empty>(
        'tapOnNotification',
        tapOnNotification_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TapOnNotificationRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PermissionDialogVisibleRequest,
            $0.PermissionDialogVisibleResponse>(
        'isPermissionDialogVisible',
        isPermissionDialogVisible_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.PermissionDialogVisibleRequest.fromBuffer(value),
        ($0.PermissionDialogVisibleResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HandlePermissionRequest, $0.Empty>(
        'handlePermissionDialog',
        handlePermissionDialog_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.HandlePermissionRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetLocationAccuracyRequest, $0.Empty>(
        'setLocationAccuracy',
        setLocationAccuracy_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetLocationAccuracyRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'debug',
        debug_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'markPatrolAppServiceReady',
        markPatrolAppServiceReady_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$0.Empty> configure_Pre($grpc.ServiceCall call,
      $async.Future<$0.ConfigureRequest> request) async {
    return configure(call, await request);
  }

  $async.Future<$0.Empty> pressHome_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return pressHome(call, await request);
  }

  $async.Future<$0.Empty> pressBack_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return pressBack(call, await request);
  }

  $async.Future<$0.Empty> pressRecentApps_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return pressRecentApps(call, await request);
  }

  $async.Future<$0.Empty> doublePressRecentApps_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return doublePressRecentApps(call, await request);
  }

  $async.Future<$0.Empty> openApp_Pre(
      $grpc.ServiceCall call, $async.Future<$0.OpenAppRequest> request) async {
    return openApp(call, await request);
  }

  $async.Future<$0.Empty> openQuickSettings_Pre($grpc.ServiceCall call,
      $async.Future<$0.OpenQuickSettingsRequest> request) async {
    return openQuickSettings(call, await request);
  }

  $async.Future<$0.GetNativeViewsResponse> getNativeViews_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.GetNativeViewsRequest> request) async {
    return getNativeViews(call, await request);
  }

  $async.Future<$0.Empty> tap_Pre(
      $grpc.ServiceCall call, $async.Future<$0.TapRequest> request) async {
    return tap(call, await request);
  }

  $async.Future<$0.Empty> doubleTap_Pre(
      $grpc.ServiceCall call, $async.Future<$0.TapRequest> request) async {
    return doubleTap(call, await request);
  }

  $async.Future<$0.Empty> enterText_Pre($grpc.ServiceCall call,
      $async.Future<$0.EnterTextRequest> request) async {
    return enterText(call, await request);
  }

  $async.Future<$0.Empty> swipe_Pre(
      $grpc.ServiceCall call, $async.Future<$0.SwipeRequest> request) async {
    return swipe(call, await request);
  }

  $async.Future<$0.Empty> enableAirplaneMode_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return enableAirplaneMode(call, await request);
  }

  $async.Future<$0.Empty> disableAirplaneMode_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return disableAirplaneMode(call, await request);
  }

  $async.Future<$0.Empty> enableWiFi_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return enableWiFi(call, await request);
  }

  $async.Future<$0.Empty> disableWiFi_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return disableWiFi(call, await request);
  }

  $async.Future<$0.Empty> enableCellular_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return enableCellular(call, await request);
  }

  $async.Future<$0.Empty> disableCellular_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return disableCellular(call, await request);
  }

  $async.Future<$0.Empty> enableBluetooth_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return enableBluetooth(call, await request);
  }

  $async.Future<$0.Empty> disableBluetooth_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return disableBluetooth(call, await request);
  }

  $async.Future<$0.Empty> enableDarkMode_Pre(
      $grpc.ServiceCall call, $async.Future<$0.DarkModeRequest> request) async {
    return enableDarkMode(call, await request);
  }

  $async.Future<$0.Empty> disableDarkMode_Pre(
      $grpc.ServiceCall call, $async.Future<$0.DarkModeRequest> request) async {
    return disableDarkMode(call, await request);
  }

  $async.Future<$0.Empty> openNotifications_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return openNotifications(call, await request);
  }

  $async.Future<$0.Empty> closeNotifications_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return closeNotifications(call, await request);
  }

  $async.Future<$0.Empty> closeHeadsUpNotification_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return closeHeadsUpNotification(call, await request);
  }

  $async.Future<$0.GetNotificationsResponse> getNotifications_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.GetNotificationsRequest> request) async {
    return getNotifications(call, await request);
  }

  $async.Future<$0.Empty> tapOnNotification_Pre($grpc.ServiceCall call,
      $async.Future<$0.TapOnNotificationRequest> request) async {
    return tapOnNotification(call, await request);
  }

  $async.Future<$0.PermissionDialogVisibleResponse>
      isPermissionDialogVisible_Pre($grpc.ServiceCall call,
          $async.Future<$0.PermissionDialogVisibleRequest> request) async {
    return isPermissionDialogVisible(call, await request);
  }

  $async.Future<$0.Empty> handlePermissionDialog_Pre($grpc.ServiceCall call,
      $async.Future<$0.HandlePermissionRequest> request) async {
    return handlePermissionDialog(call, await request);
  }

  $async.Future<$0.Empty> setLocationAccuracy_Pre($grpc.ServiceCall call,
      $async.Future<$0.SetLocationAccuracyRequest> request) async {
    return setLocationAccuracy(call, await request);
  }

  $async.Future<$0.Empty> debug_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return debug(call, await request);
  }

  $async.Future<$0.Empty> markPatrolAppServiceReady_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return markPatrolAppServiceReady(call, await request);
  }

  $async.Future<$0.Empty> configure(
      $grpc.ServiceCall call, $0.ConfigureRequest request);
  $async.Future<$0.Empty> pressHome($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> pressBack($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> pressRecentApps(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> doublePressRecentApps(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> openApp(
      $grpc.ServiceCall call, $0.OpenAppRequest request);
  $async.Future<$0.Empty> openQuickSettings(
      $grpc.ServiceCall call, $0.OpenQuickSettingsRequest request);
  $async.Future<$0.GetNativeViewsResponse> getNativeViews(
      $grpc.ServiceCall call, $0.GetNativeViewsRequest request);
  $async.Future<$0.Empty> tap($grpc.ServiceCall call, $0.TapRequest request);
  $async.Future<$0.Empty> doubleTap(
      $grpc.ServiceCall call, $0.TapRequest request);
  $async.Future<$0.Empty> enterText(
      $grpc.ServiceCall call, $0.EnterTextRequest request);
  $async.Future<$0.Empty> swipe(
      $grpc.ServiceCall call, $0.SwipeRequest request);
  $async.Future<$0.Empty> enableAirplaneMode(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> disableAirplaneMode(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> enableWiFi($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> disableWiFi($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> enableCellular(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> disableCellular(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> enableBluetooth(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> disableBluetooth(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> enableDarkMode(
      $grpc.ServiceCall call, $0.DarkModeRequest request);
  $async.Future<$0.Empty> disableDarkMode(
      $grpc.ServiceCall call, $0.DarkModeRequest request);
  $async.Future<$0.Empty> openNotifications(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> closeNotifications(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> closeHeadsUpNotification(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.GetNotificationsResponse> getNotifications(
      $grpc.ServiceCall call, $0.GetNotificationsRequest request);
  $async.Future<$0.Empty> tapOnNotification(
      $grpc.ServiceCall call, $0.TapOnNotificationRequest request);
  $async.Future<$0.PermissionDialogVisibleResponse> isPermissionDialogVisible(
      $grpc.ServiceCall call, $0.PermissionDialogVisibleRequest request);
  $async.Future<$0.Empty> handlePermissionDialog(
      $grpc.ServiceCall call, $0.HandlePermissionRequest request);
  $async.Future<$0.Empty> setLocationAccuracy(
      $grpc.ServiceCall call, $0.SetLocationAccuracyRequest request);
  $async.Future<$0.Empty> debug($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> markPatrolAppServiceReady(
      $grpc.ServiceCall call, $0.Empty request);
}

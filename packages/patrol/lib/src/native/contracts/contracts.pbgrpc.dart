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

class NativeAutomatorClient extends $grpc.Client {
  static final _$pressHome = $grpc.ClientMethod<$0.Empty, $0.DefaultResponse>(
      '/patrol.NativeAutomator/pressHome',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.DefaultResponse.fromBuffer(value));
  static final _$pressBack = $grpc.ClientMethod<$0.Empty, $0.DefaultResponse>(
      '/patrol.NativeAutomator/pressBack',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.DefaultResponse.fromBuffer(value));
  static final _$pressRecentApps =
      $grpc.ClientMethod<$0.Empty, $0.DefaultResponse>(
          '/patrol.NativeAutomator/pressRecentApps',
          ($0.Empty value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$doublePressRecentApps =
      $grpc.ClientMethod<$0.Empty, $0.DefaultResponse>(
          '/patrol.NativeAutomator/doublePressRecentApps',
          ($0.Empty value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$openApp =
      $grpc.ClientMethod<$0.OpenAppRequest, $0.DefaultResponse>(
          '/patrol.NativeAutomator/openApp',
          ($0.OpenAppRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$openQuickSettings =
      $grpc.ClientMethod<$0.OpenQuickSettingsRequest, $0.DefaultResponse>(
          '/patrol.NativeAutomator/openQuickSettings',
          ($0.OpenQuickSettingsRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$getNativeViews =
      $grpc.ClientMethod<$0.GetNativeViewsRequest, $0.GetNativeViewsResponse>(
          '/patrol.NativeAutomator/getNativeViews',
          ($0.GetNativeViewsRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.GetNativeViewsResponse.fromBuffer(value));
  static final _$tap = $grpc.ClientMethod<$0.TapRequest, $0.DefaultResponse>(
      '/patrol.NativeAutomator/tap',
      ($0.TapRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.DefaultResponse.fromBuffer(value));
  static final _$doubleTap =
      $grpc.ClientMethod<$0.TapRequest, $0.DefaultResponse>(
          '/patrol.NativeAutomator/doubleTap',
          ($0.TapRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$enterText =
      $grpc.ClientMethod<$0.EnterTextRequest, $0.DefaultResponse>(
          '/patrol.NativeAutomator/enterText',
          ($0.EnterTextRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$swipe =
      $grpc.ClientMethod<$0.SwipeRequest, $0.DefaultResponse>(
          '/patrol.NativeAutomator/swipe',
          ($0.SwipeRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$enableAirplaneMode =
      $grpc.ClientMethod<$0.Empty, $0.DefaultResponse>(
          '/patrol.NativeAutomator/enableAirplaneMode',
          ($0.Empty value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$disableAirplaneMode =
      $grpc.ClientMethod<$0.Empty, $0.DefaultResponse>(
          '/patrol.NativeAutomator/disableAirplaneMode',
          ($0.Empty value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$enableWiFi = $grpc.ClientMethod<$0.Empty, $0.DefaultResponse>(
      '/patrol.NativeAutomator/enableWiFi',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.DefaultResponse.fromBuffer(value));
  static final _$disableWiFi = $grpc.ClientMethod<$0.Empty, $0.DefaultResponse>(
      '/patrol.NativeAutomator/disableWiFi',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.DefaultResponse.fromBuffer(value));
  static final _$enableCellular =
      $grpc.ClientMethod<$0.Empty, $0.DefaultResponse>(
          '/patrol.NativeAutomator/enableCellular',
          ($0.Empty value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$disableCellular =
      $grpc.ClientMethod<$0.Empty, $0.DefaultResponse>(
          '/patrol.NativeAutomator/disableCellular',
          ($0.Empty value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$enableBluetooth =
      $grpc.ClientMethod<$0.Empty, $0.DefaultResponse>(
          '/patrol.NativeAutomator/enableBluetooth',
          ($0.Empty value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$disableBluetooth =
      $grpc.ClientMethod<$0.Empty, $0.DefaultResponse>(
          '/patrol.NativeAutomator/disableBluetooth',
          ($0.Empty value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$enableDarkMode =
      $grpc.ClientMethod<$0.DarkModeRequest, $0.DefaultResponse>(
          '/patrol.NativeAutomator/enableDarkMode',
          ($0.DarkModeRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$disableDarkMode =
      $grpc.ClientMethod<$0.DarkModeRequest, $0.DefaultResponse>(
          '/patrol.NativeAutomator/disableDarkMode',
          ($0.DarkModeRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$openNotifications =
      $grpc.ClientMethod<$0.Empty, $0.DefaultResponse>(
          '/patrol.NativeAutomator/openNotifications',
          ($0.Empty value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$closeNotifications =
      $grpc.ClientMethod<$0.Empty, $0.DefaultResponse>(
          '/patrol.NativeAutomator/closeNotifications',
          ($0.Empty value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$closeHeadsUpNotification =
      $grpc.ClientMethod<$0.Empty, $0.DefaultResponse>(
          '/patrol.NativeAutomator/closeHeadsUpNotification',
          ($0.Empty value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$getNotifications = $grpc.ClientMethod<
          $0.GetNotificationsRequest, $0.GetNotificationsResponse>(
      '/patrol.NativeAutomator/getNotifications',
      ($0.GetNotificationsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.GetNotificationsResponse.fromBuffer(value));
  static final _$tapOnNotification =
      $grpc.ClientMethod<$0.TapOnNotificationRequest, $0.DefaultResponse>(
          '/patrol.NativeAutomator/tapOnNotification',
          ($0.TapOnNotificationRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$handlePermissionDialog =
      $grpc.ClientMethod<$0.HandlePermissionRequest, $0.DefaultResponse>(
          '/patrol.NativeAutomator/handlePermissionDialog',
          ($0.HandlePermissionRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$setLocationAccuracy =
      $grpc.ClientMethod<$0.SetLocationAccuracyRequest, $0.DefaultResponse>(
          '/patrol.NativeAutomator/setLocationAccuracy',
          ($0.SetLocationAccuracyRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DefaultResponse.fromBuffer(value));
  static final _$debug = $grpc.ClientMethod<$0.Empty, $0.DefaultResponse>(
      '/patrol.NativeAutomator/debug',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.DefaultResponse.fromBuffer(value));

  NativeAutomatorClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.DefaultResponse> pressHome($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$pressHome, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> pressBack($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$pressBack, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> pressRecentApps($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$pressRecentApps, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> doublePressRecentApps(
      $0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$doublePressRecentApps, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> openApp($0.OpenAppRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$openApp, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> openQuickSettings(
      $0.OpenQuickSettingsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$openQuickSettings, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetNativeViewsResponse> getNativeViews(
      $0.GetNativeViewsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getNativeViews, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> tap($0.TapRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$tap, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> doubleTap($0.TapRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$doubleTap, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> enterText(
      $0.EnterTextRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$enterText, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> swipe($0.SwipeRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$swipe, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> enableAirplaneMode($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$enableAirplaneMode, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> disableAirplaneMode($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$disableAirplaneMode, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> enableWiFi($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$enableWiFi, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> disableWiFi($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$disableWiFi, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> enableCellular($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$enableCellular, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> disableCellular($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$disableCellular, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> enableBluetooth($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$enableBluetooth, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> disableBluetooth($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$disableBluetooth, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> enableDarkMode(
      $0.DarkModeRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$enableDarkMode, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> disableDarkMode(
      $0.DarkModeRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$disableDarkMode, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> openNotifications($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$openNotifications, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> closeNotifications($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$closeNotifications, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> closeHeadsUpNotification(
      $0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$closeHeadsUpNotification, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.GetNotificationsResponse> getNotifications(
      $0.GetNotificationsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getNotifications, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> tapOnNotification(
      $0.TapOnNotificationRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$tapOnNotification, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> handlePermissionDialog(
      $0.HandlePermissionRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$handlePermissionDialog, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> setLocationAccuracy(
      $0.SetLocationAccuracyRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setLocationAccuracy, request, options: options);
  }

  $grpc.ResponseFuture<$0.DefaultResponse> debug($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$debug, request, options: options);
  }
}

abstract class NativeAutomatorServiceBase extends $grpc.Service {
  $core.String get $name => 'patrol.NativeAutomator';

  NativeAutomatorServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.DefaultResponse>(
        'pressHome',
        pressHome_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.DefaultResponse>(
        'pressBack',
        pressBack_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.DefaultResponse>(
        'pressRecentApps',
        pressRecentApps_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.DefaultResponse>(
        'doublePressRecentApps',
        doublePressRecentApps_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.OpenAppRequest, $0.DefaultResponse>(
        'openApp',
        openApp_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.OpenAppRequest.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.OpenQuickSettingsRequest, $0.DefaultResponse>(
            'openQuickSettings',
            openQuickSettings_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.OpenQuickSettingsRequest.fromBuffer(value),
            ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetNativeViewsRequest,
            $0.GetNativeViewsResponse>(
        'getNativeViews',
        getNativeViews_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetNativeViewsRequest.fromBuffer(value),
        ($0.GetNativeViewsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TapRequest, $0.DefaultResponse>(
        'tap',
        tap_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TapRequest.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TapRequest, $0.DefaultResponse>(
        'doubleTap',
        doubleTap_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TapRequest.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EnterTextRequest, $0.DefaultResponse>(
        'enterText',
        enterText_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EnterTextRequest.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SwipeRequest, $0.DefaultResponse>(
        'swipe',
        swipe_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SwipeRequest.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.DefaultResponse>(
        'enableAirplaneMode',
        enableAirplaneMode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.DefaultResponse>(
        'disableAirplaneMode',
        disableAirplaneMode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.DefaultResponse>(
        'enableWiFi',
        enableWiFi_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.DefaultResponse>(
        'disableWiFi',
        disableWiFi_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.DefaultResponse>(
        'enableCellular',
        enableCellular_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.DefaultResponse>(
        'disableCellular',
        disableCellular_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.DefaultResponse>(
        'enableBluetooth',
        enableBluetooth_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.DefaultResponse>(
        'disableBluetooth',
        disableBluetooth_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DarkModeRequest, $0.DefaultResponse>(
        'enableDarkMode',
        enableDarkMode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DarkModeRequest.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DarkModeRequest, $0.DefaultResponse>(
        'disableDarkMode',
        disableDarkMode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DarkModeRequest.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.DefaultResponse>(
        'openNotifications',
        openNotifications_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.DefaultResponse>(
        'closeNotifications',
        closeNotifications_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.DefaultResponse>(
        'closeHeadsUpNotification',
        closeHeadsUpNotification_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetNotificationsRequest,
            $0.GetNotificationsResponse>(
        'getNotifications',
        getNotifications_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetNotificationsRequest.fromBuffer(value),
        ($0.GetNotificationsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.TapOnNotificationRequest, $0.DefaultResponse>(
            'tapOnNotification',
            tapOnNotification_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.TapOnNotificationRequest.fromBuffer(value),
            ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.HandlePermissionRequest, $0.DefaultResponse>(
            'handlePermissionDialog',
            handlePermissionDialog_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.HandlePermissionRequest.fromBuffer(value),
            ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SetLocationAccuracyRequest, $0.DefaultResponse>(
            'setLocationAccuracy',
            setLocationAccuracy_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SetLocationAccuracyRequest.fromBuffer(value),
            ($0.DefaultResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.DefaultResponse>(
        'debug',
        debug_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.DefaultResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.DefaultResponse> pressHome_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return pressHome(call, await request);
  }

  $async.Future<$0.DefaultResponse> pressBack_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return pressBack(call, await request);
  }

  $async.Future<$0.DefaultResponse> pressRecentApps_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return pressRecentApps(call, await request);
  }

  $async.Future<$0.DefaultResponse> doublePressRecentApps_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return doublePressRecentApps(call, await request);
  }

  $async.Future<$0.DefaultResponse> openApp_Pre(
      $grpc.ServiceCall call, $async.Future<$0.OpenAppRequest> request) async {
    return openApp(call, await request);
  }

  $async.Future<$0.DefaultResponse> openQuickSettings_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.OpenQuickSettingsRequest> request) async {
    return openQuickSettings(call, await request);
  }

  $async.Future<$0.GetNativeViewsResponse> getNativeViews_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.GetNativeViewsRequest> request) async {
    return getNativeViews(call, await request);
  }

  $async.Future<$0.DefaultResponse> tap_Pre(
      $grpc.ServiceCall call, $async.Future<$0.TapRequest> request) async {
    return tap(call, await request);
  }

  $async.Future<$0.DefaultResponse> doubleTap_Pre(
      $grpc.ServiceCall call, $async.Future<$0.TapRequest> request) async {
    return doubleTap(call, await request);
  }

  $async.Future<$0.DefaultResponse> enterText_Pre($grpc.ServiceCall call,
      $async.Future<$0.EnterTextRequest> request) async {
    return enterText(call, await request);
  }

  $async.Future<$0.DefaultResponse> swipe_Pre(
      $grpc.ServiceCall call, $async.Future<$0.SwipeRequest> request) async {
    return swipe(call, await request);
  }

  $async.Future<$0.DefaultResponse> enableAirplaneMode_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return enableAirplaneMode(call, await request);
  }

  $async.Future<$0.DefaultResponse> disableAirplaneMode_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return disableAirplaneMode(call, await request);
  }

  $async.Future<$0.DefaultResponse> enableWiFi_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return enableWiFi(call, await request);
  }

  $async.Future<$0.DefaultResponse> disableWiFi_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return disableWiFi(call, await request);
  }

  $async.Future<$0.DefaultResponse> enableCellular_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return enableCellular(call, await request);
  }

  $async.Future<$0.DefaultResponse> disableCellular_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return disableCellular(call, await request);
  }

  $async.Future<$0.DefaultResponse> enableBluetooth_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return enableBluetooth(call, await request);
  }

  $async.Future<$0.DefaultResponse> disableBluetooth_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return disableBluetooth(call, await request);
  }

  $async.Future<$0.DefaultResponse> enableDarkMode_Pre(
      $grpc.ServiceCall call, $async.Future<$0.DarkModeRequest> request) async {
    return enableDarkMode(call, await request);
  }

  $async.Future<$0.DefaultResponse> disableDarkMode_Pre(
      $grpc.ServiceCall call, $async.Future<$0.DarkModeRequest> request) async {
    return disableDarkMode(call, await request);
  }

  $async.Future<$0.DefaultResponse> openNotifications_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return openNotifications(call, await request);
  }

  $async.Future<$0.DefaultResponse> closeNotifications_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return closeNotifications(call, await request);
  }

  $async.Future<$0.DefaultResponse> closeHeadsUpNotification_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return closeHeadsUpNotification(call, await request);
  }

  $async.Future<$0.GetNotificationsResponse> getNotifications_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.GetNotificationsRequest> request) async {
    return getNotifications(call, await request);
  }

  $async.Future<$0.DefaultResponse> tapOnNotification_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.TapOnNotificationRequest> request) async {
    return tapOnNotification(call, await request);
  }

  $async.Future<$0.DefaultResponse> handlePermissionDialog_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.HandlePermissionRequest> request) async {
    return handlePermissionDialog(call, await request);
  }

  $async.Future<$0.DefaultResponse> setLocationAccuracy_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.SetLocationAccuracyRequest> request) async {
    return setLocationAccuracy(call, await request);
  }

  $async.Future<$0.DefaultResponse> debug_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return debug(call, await request);
  }

  $async.Future<$0.DefaultResponse> pressHome(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.DefaultResponse> pressBack(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.DefaultResponse> pressRecentApps(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.DefaultResponse> doublePressRecentApps(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.DefaultResponse> openApp(
      $grpc.ServiceCall call, $0.OpenAppRequest request);
  $async.Future<$0.DefaultResponse> openQuickSettings(
      $grpc.ServiceCall call, $0.OpenQuickSettingsRequest request);
  $async.Future<$0.GetNativeViewsResponse> getNativeViews(
      $grpc.ServiceCall call, $0.GetNativeViewsRequest request);
  $async.Future<$0.DefaultResponse> tap(
      $grpc.ServiceCall call, $0.TapRequest request);
  $async.Future<$0.DefaultResponse> doubleTap(
      $grpc.ServiceCall call, $0.TapRequest request);
  $async.Future<$0.DefaultResponse> enterText(
      $grpc.ServiceCall call, $0.EnterTextRequest request);
  $async.Future<$0.DefaultResponse> swipe(
      $grpc.ServiceCall call, $0.SwipeRequest request);
  $async.Future<$0.DefaultResponse> enableAirplaneMode(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.DefaultResponse> disableAirplaneMode(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.DefaultResponse> enableWiFi(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.DefaultResponse> disableWiFi(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.DefaultResponse> enableCellular(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.DefaultResponse> disableCellular(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.DefaultResponse> enableBluetooth(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.DefaultResponse> disableBluetooth(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.DefaultResponse> enableDarkMode(
      $grpc.ServiceCall call, $0.DarkModeRequest request);
  $async.Future<$0.DefaultResponse> disableDarkMode(
      $grpc.ServiceCall call, $0.DarkModeRequest request);
  $async.Future<$0.DefaultResponse> openNotifications(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.DefaultResponse> closeNotifications(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.DefaultResponse> closeHeadsUpNotification(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.GetNotificationsResponse> getNotifications(
      $grpc.ServiceCall call, $0.GetNotificationsRequest request);
  $async.Future<$0.DefaultResponse> tapOnNotification(
      $grpc.ServiceCall call, $0.TapOnNotificationRequest request);
  $async.Future<$0.DefaultResponse> handlePermissionDialog(
      $grpc.ServiceCall call, $0.HandlePermissionRequest request);
  $async.Future<$0.DefaultResponse> setLocationAccuracy(
      $grpc.ServiceCall call, $0.SetLocationAccuracyRequest request);
  $async.Future<$0.DefaultResponse> debug(
      $grpc.ServiceCall call, $0.Empty request);
}

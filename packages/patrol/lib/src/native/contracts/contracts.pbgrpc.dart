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
  static final _$pressHome =
      $grpc.ClientMethod<$0.PressHomeRequest, $0.PressHomeResponse>(
          '/patrol.NativeAutomator/pressHome',
          ($0.PressHomeRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.PressHomeResponse.fromBuffer(value));
  static final _$pressBack =
      $grpc.ClientMethod<$0.PressBackRequest, $0.PressBackResponse>(
          '/patrol.NativeAutomator/pressBack',
          ($0.PressBackRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.PressBackResponse.fromBuffer(value));
  static final _$pressRecentApps =
      $grpc.ClientMethod<$0.PressRecentAppsRequest, $0.PressRecentAppsResponse>(
          '/patrol.NativeAutomator/pressRecentApps',
          ($0.PressRecentAppsRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.PressRecentAppsResponse.fromBuffer(value));
  static final _$doublePressRecentApps = $grpc.ClientMethod<
          $0.DoublePressRecentAppsRequest, $0.DoublePressRecentAppsResponse>(
      '/patrol.NativeAutomator/doublePressRecentApps',
      ($0.DoublePressRecentAppsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.DoublePressRecentAppsResponse.fromBuffer(value));
  static final _$openApp =
      $grpc.ClientMethod<$0.OpenAppRequest, $0.OpenAppResponse>(
          '/patrol.NativeAutomator/openApp',
          ($0.OpenAppRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.OpenAppResponse.fromBuffer(value));
  static final _$openNotifications = $grpc.ClientMethod<
          $0.OpenNotificationsRequest, $0.OpenNotificationsResponse>(
      '/patrol.NativeAutomator/openNotifications',
      ($0.OpenNotificationsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.OpenNotificationsResponse.fromBuffer(value));
  static final _$openQuickSettings = $grpc.ClientMethod<
          $0.OpenQuickSettingsRequest, $0.OpenQuickSettingsResponse>(
      '/patrol.NativeAutomator/openQuickSettings',
      ($0.OpenQuickSettingsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.OpenQuickSettingsResponse.fromBuffer(value));
  static final _$enableDarkMode =
      $grpc.ClientMethod<$0.DarkModeRequest, $0.DarkModeResponse>(
          '/patrol.NativeAutomator/enableDarkMode',
          ($0.DarkModeRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DarkModeResponse.fromBuffer(value));
  static final _$disableDarkMode =
      $grpc.ClientMethod<$0.DarkModeRequest, $0.DarkModeResponse>(
          '/patrol.NativeAutomator/disableDarkMode',
          ($0.DarkModeRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DarkModeResponse.fromBuffer(value));
  static final _$enableWiFi =
      $grpc.ClientMethod<$0.WiFiRequest, $0.WiFiResponse>(
          '/patrol.NativeAutomator/enableWiFi',
          ($0.WiFiRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.WiFiResponse.fromBuffer(value));
  static final _$disableWiFi =
      $grpc.ClientMethod<$0.WiFiRequest, $0.WiFiResponse>(
          '/patrol.NativeAutomator/disableWiFi',
          ($0.WiFiRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.WiFiResponse.fromBuffer(value));
  static final _$enableCellular =
      $grpc.ClientMethod<$0.CellularRequest, $0.CellularResponse>(
          '/patrol.NativeAutomator/enableCellular',
          ($0.CellularRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.CellularResponse.fromBuffer(value));
  static final _$disableCellular =
      $grpc.ClientMethod<$0.CellularRequest, $0.CellularResponse>(
          '/patrol.NativeAutomator/disableCellular',
          ($0.CellularRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.CellularResponse.fromBuffer(value));
  static final _$getNativeWidgets = $grpc.ClientMethod<
          $0.GetNativeWidgetsRequest, $0.GetNativeWidgetsResponse>(
      '/patrol.NativeAutomator/getNativeWidgets',
      ($0.GetNativeWidgetsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.GetNativeWidgetsResponse.fromBuffer(value));
  static final _$getNotifications = $grpc.ClientMethod<
          $0.GetNotificationsRequest, $0.GetNotificationsResponse>(
      '/patrol.NativeAutomator/getNotifications',
      ($0.GetNotificationsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.GetNotificationsResponse.fromBuffer(value));
  static final _$tap = $grpc.ClientMethod<$0.TapRequest, $0.TapResponse>(
      '/patrol.NativeAutomator/tap',
      ($0.TapRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.TapResponse.fromBuffer(value));
  static final _$doubleTap = $grpc.ClientMethod<$0.TapRequest, $0.TapResponse>(
      '/patrol.NativeAutomator/doubleTap',
      ($0.TapRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.TapResponse.fromBuffer(value));
  static final _$enterText =
      $grpc.ClientMethod<$0.EnterTextRequest, $0.EnterTextResponse>(
          '/patrol.NativeAutomator/enterText',
          ($0.EnterTextRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.EnterTextResponse.fromBuffer(value));
  static final _$swipe = $grpc.ClientMethod<$0.SwipeRequest, $0.SwipeResponse>(
      '/patrol.NativeAutomator/swipe',
      ($0.SwipeRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.SwipeResponse.fromBuffer(value));
  static final _$handlePermissionDialog = $grpc.ClientMethod<
          $0.HandlePermissionRequest, $0.HandlePermissionResponse>(
      '/patrol.NativeAutomator/handlePermissionDialog',
      ($0.HandlePermissionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.HandlePermissionResponse.fromBuffer(value));
  static final _$setLocationAccuracy = $grpc.ClientMethod<
          $0.SetLocationAccuracyRequest, $0.SetLocationAccuracyResponse>(
      '/patrol.NativeAutomator/setLocationAccuracy',
      ($0.SetLocationAccuracyRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.SetLocationAccuracyResponse.fromBuffer(value));
  static final _$tapOnNotification = $grpc.ClientMethod<
          $0.TapOnNotificationRequest, $0.TapOnNotificationResponse>(
      '/patrol.NativeAutomator/tapOnNotification',
      ($0.TapOnNotificationRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.TapOnNotificationResponse.fromBuffer(value));

  NativeAutomatorClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.PressHomeResponse> pressHome(
      $0.PressHomeRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$pressHome, request, options: options);
  }

  $grpc.ResponseFuture<$0.PressBackResponse> pressBack(
      $0.PressBackRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$pressBack, request, options: options);
  }

  $grpc.ResponseFuture<$0.PressRecentAppsResponse> pressRecentApps(
      $0.PressRecentAppsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$pressRecentApps, request, options: options);
  }

  $grpc.ResponseFuture<$0.DoublePressRecentAppsResponse> doublePressRecentApps(
      $0.DoublePressRecentAppsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$doublePressRecentApps, request, options: options);
  }

  $grpc.ResponseFuture<$0.OpenAppResponse> openApp($0.OpenAppRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$openApp, request, options: options);
  }

  $grpc.ResponseFuture<$0.OpenNotificationsResponse> openNotifications(
      $0.OpenNotificationsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$openNotifications, request, options: options);
  }

  $grpc.ResponseFuture<$0.OpenQuickSettingsResponse> openQuickSettings(
      $0.OpenQuickSettingsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$openQuickSettings, request, options: options);
  }

  $grpc.ResponseFuture<$0.DarkModeResponse> enableDarkMode(
      $0.DarkModeRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$enableDarkMode, request, options: options);
  }

  $grpc.ResponseFuture<$0.DarkModeResponse> disableDarkMode(
      $0.DarkModeRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$disableDarkMode, request, options: options);
  }

  $grpc.ResponseFuture<$0.WiFiResponse> enableWiFi($0.WiFiRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$enableWiFi, request, options: options);
  }

  $grpc.ResponseFuture<$0.WiFiResponse> disableWiFi($0.WiFiRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$disableWiFi, request, options: options);
  }

  $grpc.ResponseFuture<$0.CellularResponse> enableCellular(
      $0.CellularRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$enableCellular, request, options: options);
  }

  $grpc.ResponseFuture<$0.CellularResponse> disableCellular(
      $0.CellularRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$disableCellular, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetNativeWidgetsResponse> getNativeWidgets(
      $0.GetNativeWidgetsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getNativeWidgets, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetNotificationsResponse> getNotifications(
      $0.GetNotificationsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getNotifications, request, options: options);
  }

  $grpc.ResponseFuture<$0.TapResponse> tap($0.TapRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$tap, request, options: options);
  }

  $grpc.ResponseFuture<$0.TapResponse> doubleTap($0.TapRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$doubleTap, request, options: options);
  }

  $grpc.ResponseFuture<$0.EnterTextResponse> enterText(
      $0.EnterTextRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$enterText, request, options: options);
  }

  $grpc.ResponseFuture<$0.SwipeResponse> swipe($0.SwipeRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$swipe, request, options: options);
  }

  $grpc.ResponseFuture<$0.HandlePermissionResponse> handlePermissionDialog(
      $0.HandlePermissionRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$handlePermissionDialog, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.SetLocationAccuracyResponse> setLocationAccuracy(
      $0.SetLocationAccuracyRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setLocationAccuracy, request, options: options);
  }

  $grpc.ResponseFuture<$0.TapOnNotificationResponse> tapOnNotification(
      $0.TapOnNotificationRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$tapOnNotification, request, options: options);
  }
}

abstract class NativeAutomatorServiceBase extends $grpc.Service {
  $core.String get $name => 'patrol.NativeAutomator';

  NativeAutomatorServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.PressHomeRequest, $0.PressHomeResponse>(
        'pressHome',
        pressHome_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PressHomeRequest.fromBuffer(value),
        ($0.PressHomeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PressBackRequest, $0.PressBackResponse>(
        'pressBack',
        pressBack_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PressBackRequest.fromBuffer(value),
        ($0.PressBackResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PressRecentAppsRequest,
            $0.PressRecentAppsResponse>(
        'pressRecentApps',
        pressRecentApps_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.PressRecentAppsRequest.fromBuffer(value),
        ($0.PressRecentAppsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DoublePressRecentAppsRequest,
            $0.DoublePressRecentAppsResponse>(
        'doublePressRecentApps',
        doublePressRecentApps_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DoublePressRecentAppsRequest.fromBuffer(value),
        ($0.DoublePressRecentAppsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.OpenAppRequest, $0.OpenAppResponse>(
        'openApp',
        openApp_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.OpenAppRequest.fromBuffer(value),
        ($0.OpenAppResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.OpenNotificationsRequest,
            $0.OpenNotificationsResponse>(
        'openNotifications',
        openNotifications_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.OpenNotificationsRequest.fromBuffer(value),
        ($0.OpenNotificationsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.OpenQuickSettingsRequest,
            $0.OpenQuickSettingsResponse>(
        'openQuickSettings',
        openQuickSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.OpenQuickSettingsRequest.fromBuffer(value),
        ($0.OpenQuickSettingsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DarkModeRequest, $0.DarkModeResponse>(
        'enableDarkMode',
        enableDarkMode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DarkModeRequest.fromBuffer(value),
        ($0.DarkModeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DarkModeRequest, $0.DarkModeResponse>(
        'disableDarkMode',
        disableDarkMode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DarkModeRequest.fromBuffer(value),
        ($0.DarkModeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WiFiRequest, $0.WiFiResponse>(
        'enableWiFi',
        enableWiFi_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.WiFiRequest.fromBuffer(value),
        ($0.WiFiResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WiFiRequest, $0.WiFiResponse>(
        'disableWiFi',
        disableWiFi_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.WiFiRequest.fromBuffer(value),
        ($0.WiFiResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CellularRequest, $0.CellularResponse>(
        'enableCellular',
        enableCellular_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CellularRequest.fromBuffer(value),
        ($0.CellularResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CellularRequest, $0.CellularResponse>(
        'disableCellular',
        disableCellular_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CellularRequest.fromBuffer(value),
        ($0.CellularResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetNativeWidgetsRequest,
            $0.GetNativeWidgetsResponse>(
        'getNativeWidgets',
        getNativeWidgets_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetNativeWidgetsRequest.fromBuffer(value),
        ($0.GetNativeWidgetsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetNotificationsRequest,
            $0.GetNotificationsResponse>(
        'getNotifications',
        getNotifications_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetNotificationsRequest.fromBuffer(value),
        ($0.GetNotificationsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TapRequest, $0.TapResponse>(
        'tap',
        tap_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TapRequest.fromBuffer(value),
        ($0.TapResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TapRequest, $0.TapResponse>(
        'doubleTap',
        doubleTap_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TapRequest.fromBuffer(value),
        ($0.TapResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EnterTextRequest, $0.EnterTextResponse>(
        'enterText',
        enterText_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EnterTextRequest.fromBuffer(value),
        ($0.EnterTextResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SwipeRequest, $0.SwipeResponse>(
        'swipe',
        swipe_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SwipeRequest.fromBuffer(value),
        ($0.SwipeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HandlePermissionRequest,
            $0.HandlePermissionResponse>(
        'handlePermissionDialog',
        handlePermissionDialog_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.HandlePermissionRequest.fromBuffer(value),
        ($0.HandlePermissionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetLocationAccuracyRequest,
            $0.SetLocationAccuracyResponse>(
        'setLocationAccuracy',
        setLocationAccuracy_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetLocationAccuracyRequest.fromBuffer(value),
        ($0.SetLocationAccuracyResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TapOnNotificationRequest,
            $0.TapOnNotificationResponse>(
        'tapOnNotification',
        tapOnNotification_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TapOnNotificationRequest.fromBuffer(value),
        ($0.TapOnNotificationResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.PressHomeResponse> pressHome_Pre($grpc.ServiceCall call,
      $async.Future<$0.PressHomeRequest> request) async {
    return pressHome(call, await request);
  }

  $async.Future<$0.PressBackResponse> pressBack_Pre($grpc.ServiceCall call,
      $async.Future<$0.PressBackRequest> request) async {
    return pressBack(call, await request);
  }

  $async.Future<$0.PressRecentAppsResponse> pressRecentApps_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.PressRecentAppsRequest> request) async {
    return pressRecentApps(call, await request);
  }

  $async.Future<$0.DoublePressRecentAppsResponse> doublePressRecentApps_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.DoublePressRecentAppsRequest> request) async {
    return doublePressRecentApps(call, await request);
  }

  $async.Future<$0.OpenAppResponse> openApp_Pre(
      $grpc.ServiceCall call, $async.Future<$0.OpenAppRequest> request) async {
    return openApp(call, await request);
  }

  $async.Future<$0.OpenNotificationsResponse> openNotifications_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.OpenNotificationsRequest> request) async {
    return openNotifications(call, await request);
  }

  $async.Future<$0.OpenQuickSettingsResponse> openQuickSettings_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.OpenQuickSettingsRequest> request) async {
    return openQuickSettings(call, await request);
  }

  $async.Future<$0.DarkModeResponse> enableDarkMode_Pre(
      $grpc.ServiceCall call, $async.Future<$0.DarkModeRequest> request) async {
    return enableDarkMode(call, await request);
  }

  $async.Future<$0.DarkModeResponse> disableDarkMode_Pre(
      $grpc.ServiceCall call, $async.Future<$0.DarkModeRequest> request) async {
    return disableDarkMode(call, await request);
  }

  $async.Future<$0.WiFiResponse> enableWiFi_Pre(
      $grpc.ServiceCall call, $async.Future<$0.WiFiRequest> request) async {
    return enableWiFi(call, await request);
  }

  $async.Future<$0.WiFiResponse> disableWiFi_Pre(
      $grpc.ServiceCall call, $async.Future<$0.WiFiRequest> request) async {
    return disableWiFi(call, await request);
  }

  $async.Future<$0.CellularResponse> enableCellular_Pre(
      $grpc.ServiceCall call, $async.Future<$0.CellularRequest> request) async {
    return enableCellular(call, await request);
  }

  $async.Future<$0.CellularResponse> disableCellular_Pre(
      $grpc.ServiceCall call, $async.Future<$0.CellularRequest> request) async {
    return disableCellular(call, await request);
  }

  $async.Future<$0.GetNativeWidgetsResponse> getNativeWidgets_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.GetNativeWidgetsRequest> request) async {
    return getNativeWidgets(call, await request);
  }

  $async.Future<$0.GetNotificationsResponse> getNotifications_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.GetNotificationsRequest> request) async {
    return getNotifications(call, await request);
  }

  $async.Future<$0.TapResponse> tap_Pre(
      $grpc.ServiceCall call, $async.Future<$0.TapRequest> request) async {
    return tap(call, await request);
  }

  $async.Future<$0.TapResponse> doubleTap_Pre(
      $grpc.ServiceCall call, $async.Future<$0.TapRequest> request) async {
    return doubleTap(call, await request);
  }

  $async.Future<$0.EnterTextResponse> enterText_Pre($grpc.ServiceCall call,
      $async.Future<$0.EnterTextRequest> request) async {
    return enterText(call, await request);
  }

  $async.Future<$0.SwipeResponse> swipe_Pre(
      $grpc.ServiceCall call, $async.Future<$0.SwipeRequest> request) async {
    return swipe(call, await request);
  }

  $async.Future<$0.HandlePermissionResponse> handlePermissionDialog_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.HandlePermissionRequest> request) async {
    return handlePermissionDialog(call, await request);
  }

  $async.Future<$0.SetLocationAccuracyResponse> setLocationAccuracy_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.SetLocationAccuracyRequest> request) async {
    return setLocationAccuracy(call, await request);
  }

  $async.Future<$0.TapOnNotificationResponse> tapOnNotification_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.TapOnNotificationRequest> request) async {
    return tapOnNotification(call, await request);
  }

  $async.Future<$0.PressHomeResponse> pressHome(
      $grpc.ServiceCall call, $0.PressHomeRequest request);
  $async.Future<$0.PressBackResponse> pressBack(
      $grpc.ServiceCall call, $0.PressBackRequest request);
  $async.Future<$0.PressRecentAppsResponse> pressRecentApps(
      $grpc.ServiceCall call, $0.PressRecentAppsRequest request);
  $async.Future<$0.DoublePressRecentAppsResponse> doublePressRecentApps(
      $grpc.ServiceCall call, $0.DoublePressRecentAppsRequest request);
  $async.Future<$0.OpenAppResponse> openApp(
      $grpc.ServiceCall call, $0.OpenAppRequest request);
  $async.Future<$0.OpenNotificationsResponse> openNotifications(
      $grpc.ServiceCall call, $0.OpenNotificationsRequest request);
  $async.Future<$0.OpenQuickSettingsResponse> openQuickSettings(
      $grpc.ServiceCall call, $0.OpenQuickSettingsRequest request);
  $async.Future<$0.DarkModeResponse> enableDarkMode(
      $grpc.ServiceCall call, $0.DarkModeRequest request);
  $async.Future<$0.DarkModeResponse> disableDarkMode(
      $grpc.ServiceCall call, $0.DarkModeRequest request);
  $async.Future<$0.WiFiResponse> enableWiFi(
      $grpc.ServiceCall call, $0.WiFiRequest request);
  $async.Future<$0.WiFiResponse> disableWiFi(
      $grpc.ServiceCall call, $0.WiFiRequest request);
  $async.Future<$0.CellularResponse> enableCellular(
      $grpc.ServiceCall call, $0.CellularRequest request);
  $async.Future<$0.CellularResponse> disableCellular(
      $grpc.ServiceCall call, $0.CellularRequest request);
  $async.Future<$0.GetNativeWidgetsResponse> getNativeWidgets(
      $grpc.ServiceCall call, $0.GetNativeWidgetsRequest request);
  $async.Future<$0.GetNotificationsResponse> getNotifications(
      $grpc.ServiceCall call, $0.GetNotificationsRequest request);
  $async.Future<$0.TapResponse> tap(
      $grpc.ServiceCall call, $0.TapRequest request);
  $async.Future<$0.TapResponse> doubleTap(
      $grpc.ServiceCall call, $0.TapRequest request);
  $async.Future<$0.EnterTextResponse> enterText(
      $grpc.ServiceCall call, $0.EnterTextRequest request);
  $async.Future<$0.SwipeResponse> swipe(
      $grpc.ServiceCall call, $0.SwipeRequest request);
  $async.Future<$0.HandlePermissionResponse> handlePermissionDialog(
      $grpc.ServiceCall call, $0.HandlePermissionRequest request);
  $async.Future<$0.SetLocationAccuracyResponse> setLocationAccuracy(
      $grpc.ServiceCall call, $0.SetLocationAccuracyRequest request);
  $async.Future<$0.TapOnNotificationResponse> tapOnNotification(
      $grpc.ServiceCall call, $0.TapOnNotificationRequest request);
}

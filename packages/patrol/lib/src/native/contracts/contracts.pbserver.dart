///
//  Generated code. Do not modify.
//  source: contracts.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'package:protobuf/protobuf.dart' as $pb;

import 'dart:core' as $core;
import 'contracts.pb.dart' as $0;
import 'contracts.pbjson.dart';

export 'contracts.pb.dart';

abstract class NativeAutomatorServiceBase extends $pb.GeneratedService {
  $async.Future<$0.PressHomeResponse> pressHome($pb.ServerContext ctx, $0.PressHomeRequest request);
  $async.Future<$0.PressBackResponse> pressBack($pb.ServerContext ctx, $0.PressBackRequest request);
  $async.Future<$0.PressRecentAppsResponse> pressRecentApps($pb.ServerContext ctx, $0.PressRecentAppsRequest request);
  $async.Future<$0.OpenAppResponse> openApp($pb.ServerContext ctx, $0.OpenAppRequest request);
  $async.Future<$0.OpenNotificationsResponse> openNotifications($pb.ServerContext ctx, $0.OpenNotificationsRequest request);
  $async.Future<$0.OpenQuickSettingsResponse> openQuickSettings($pb.ServerContext ctx, $0.OpenQuickSettingsRequest request);
  $async.Future<$0.DarkModeResponse> enableDarkMode($pb.ServerContext ctx, $0.DarkModeRequest request);
  $async.Future<$0.DarkModeResponse> disableDarkMoed($pb.ServerContext ctx, $0.DarkModeRequest request);
  $async.Future<$0.WiFiResponse> enableWiFi($pb.ServerContext ctx, $0.WiFiRequest request);
  $async.Future<$0.WiFiResponse> disableWiFi($pb.ServerContext ctx, $0.WiFiRequest request);
  $async.Future<$0.CellularResponse> enableCellular($pb.ServerContext ctx, $0.CellularRequest request);
  $async.Future<$0.CellularResponse> disableCellular($pb.ServerContext ctx, $0.CellularRequest request);
  $async.Future<$0.GetNativeWidgetsResponse> getNativeWidgets($pb.ServerContext ctx, $0.GetNativeWidgetsRequest request);
  $async.Future<$0.GetNotificationsResponse> getNotifications($pb.ServerContext ctx, $0.GetNotificationsRequest request);
  $async.Future<$0.TapResponse> tap($pb.ServerContext ctx, $0.TapRequest request);
  $async.Future<$0.TapResponse> doubleTap($pb.ServerContext ctx, $0.TapRequest request);
  $async.Future<$0.EnterTextResponse> enterText($pb.ServerContext ctx, $0.EnterTextRequest request);
  $async.Future<$0.SwipeResponse> swipe($pb.ServerContext ctx, $0.SwipeRequest request);
  $async.Future<$0.HandlePermissionResponse> handlePermissionDialog($pb.ServerContext ctx, $0.HandlePermissionRequest request);
  $async.Future<$0.TapOnNotificationResponse> tapOnNotification($pb.ServerContext ctx, $0.TapOnNotificationRequest request);

  $pb.GeneratedMessage createRequest($core.String method) {
    switch (method) {
      case 'pressHome': return $0.PressHomeRequest();
      case 'pressBack': return $0.PressBackRequest();
      case 'pressRecentApps': return $0.PressRecentAppsRequest();
      case 'openApp': return $0.OpenAppRequest();
      case 'openNotifications': return $0.OpenNotificationsRequest();
      case 'OpenQuickSettings': return $0.OpenQuickSettingsRequest();
      case 'enableDarkMode': return $0.DarkModeRequest();
      case 'disableDarkMoed': return $0.DarkModeRequest();
      case 'enableWiFi': return $0.WiFiRequest();
      case 'disableWiFi': return $0.WiFiRequest();
      case 'enableCellular': return $0.CellularRequest();
      case 'disableCellular': return $0.CellularRequest();
      case 'getNativeWidgets': return $0.GetNativeWidgetsRequest();
      case 'getNotifications': return $0.GetNotificationsRequest();
      case 'tap': return $0.TapRequest();
      case 'doubleTap': return $0.TapRequest();
      case 'enterText': return $0.EnterTextRequest();
      case 'swipe': return $0.SwipeRequest();
      case 'handlePermissionDialog': return $0.HandlePermissionRequest();
      case 'tapOnNotification': return $0.TapOnNotificationRequest();
      default: throw $core.ArgumentError('Unknown method: $method');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String method, $pb.GeneratedMessage request) {
    switch (method) {
      case 'pressHome': return this.pressHome(ctx, request as $0.PressHomeRequest);
      case 'pressBack': return this.pressBack(ctx, request as $0.PressBackRequest);
      case 'pressRecentApps': return this.pressRecentApps(ctx, request as $0.PressRecentAppsRequest);
      case 'openApp': return this.openApp(ctx, request as $0.OpenAppRequest);
      case 'openNotifications': return this.openNotifications(ctx, request as $0.OpenNotificationsRequest);
      case 'OpenQuickSettings': return this.openQuickSettings(ctx, request as $0.OpenQuickSettingsRequest);
      case 'enableDarkMode': return this.enableDarkMode(ctx, request as $0.DarkModeRequest);
      case 'disableDarkMoed': return this.disableDarkMoed(ctx, request as $0.DarkModeRequest);
      case 'enableWiFi': return this.enableWiFi(ctx, request as $0.WiFiRequest);
      case 'disableWiFi': return this.disableWiFi(ctx, request as $0.WiFiRequest);
      case 'enableCellular': return this.enableCellular(ctx, request as $0.CellularRequest);
      case 'disableCellular': return this.disableCellular(ctx, request as $0.CellularRequest);
      case 'getNativeWidgets': return this.getNativeWidgets(ctx, request as $0.GetNativeWidgetsRequest);
      case 'getNotifications': return this.getNotifications(ctx, request as $0.GetNotificationsRequest);
      case 'tap': return this.tap(ctx, request as $0.TapRequest);
      case 'doubleTap': return this.doubleTap(ctx, request as $0.TapRequest);
      case 'enterText': return this.enterText(ctx, request as $0.EnterTextRequest);
      case 'swipe': return this.swipe(ctx, request as $0.SwipeRequest);
      case 'handlePermissionDialog': return this.handlePermissionDialog(ctx, request as $0.HandlePermissionRequest);
      case 'tapOnNotification': return this.tapOnNotification(ctx, request as $0.TapOnNotificationRequest);
      default: throw $core.ArgumentError('Unknown method: $method');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => NativeAutomatorServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => NativeAutomatorServiceBase$messageJson;
}


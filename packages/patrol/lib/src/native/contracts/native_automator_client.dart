//
//  Generated code. Do not modify.
//  source: schema.dart
//
// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'contracts.dart';

class NativeAutomatorClientException implements Exception {
  NativeAutomatorClientException(this.statusCode, this.responseBody);

  final String responseBody;
  final int statusCode;

  @override
  String toString() {
    return 'Invalid response: $statusCode $responseBody';
  }
}

class NativeAutomatorClient {
  const NativeAutomatorClient(
    this._client,
    this._apiUri, {
    Duration timeout = const Duration(seconds: 30),
  }) : _timeout = timeout;

  final Duration _timeout;
  final http.Client _client;
  final Uri _apiUri;

  Future<void> initialize() {
    return _sendRequest(
      'initialize',
    );
  }

  Future<void> configure(
    ConfigureRequest request,
  ) {
    return _sendRequest(
      'configure',
      request.toJson(),
    );
  }

  Future<void> pressHome() {
    return _sendRequest(
      'pressHome',
    );
  }

  Future<void> pressBack() {
    return _sendRequest(
      'pressBack',
    );
  }

  Future<void> pressRecentApps() {
    return _sendRequest(
      'pressRecentApps',
    );
  }

  Future<void> doublePressRecentApps() {
    return _sendRequest(
      'doublePressRecentApps',
    );
  }

  Future<void> openApp(
    OpenAppRequest request,
  ) {
    return _sendRequest(
      'openApp',
      request.toJson(),
    );
  }

  Future<void> openQuickSettings(
    OpenQuickSettingsRequest request,
  ) {
    return _sendRequest(
      'openQuickSettings',
      request.toJson(),
    );
  }

  Future<GetNativeViewsResponse> getNativeViews(
    GetNativeViewsRequest request,
  ) async {
    final json = await _sendRequest(
      'getNativeViews',
      request.toJson(),
    );
    return GetNativeViewsResponse.fromJson(json);
  }

  Future<void> tap(
    TapRequest request,
  ) {
    return _sendRequest(
      'tap',
      request.toJson(),
    );
  }

  Future<void> doubleTap(
    TapRequest request,
  ) {
    return _sendRequest(
      'doubleTap',
      request.toJson(),
    );
  }

  Future<void> enterText(
    EnterTextRequest request,
  ) {
    return _sendRequest(
      'enterText',
      request.toJson(),
    );
  }

  Future<void> swipe(
    SwipeRequest request,
  ) {
    return _sendRequest(
      'swipe',
      request.toJson(),
    );
  }

  Future<void> waitUntilVisible(
    WaitUntilVisibleRequest request,
  ) {
    return _sendRequest(
      'waitUntilVisible',
      request.toJson(),
    );
  }

  Future<void> enableAirplaneMode() {
    return _sendRequest(
      'enableAirplaneMode',
    );
  }

  Future<void> disableAirplaneMode() {
    return _sendRequest(
      'disableAirplaneMode',
    );
  }

  Future<void> enableWiFi() {
    return _sendRequest(
      'enableWiFi',
    );
  }

  Future<void> disableWiFi() {
    return _sendRequest(
      'disableWiFi',
    );
  }

  Future<void> enableCellular() {
    return _sendRequest(
      'enableCellular',
    );
  }

  Future<void> disableCellular() {
    return _sendRequest(
      'disableCellular',
    );
  }

  Future<void> enableBluetooth() {
    return _sendRequest(
      'enableBluetooth',
    );
  }

  Future<void> disableBluetooth() {
    return _sendRequest(
      'disableBluetooth',
    );
  }

  Future<void> enableDarkMode(
    DarkModeRequest request,
  ) {
    return _sendRequest(
      'enableDarkMode',
      request.toJson(),
    );
  }

  Future<void> disableDarkMode(
    DarkModeRequest request,
  ) {
    return _sendRequest(
      'disableDarkMode',
      request.toJson(),
    );
  }

  Future<void> openNotifications() {
    return _sendRequest(
      'openNotifications',
    );
  }

  Future<void> closeNotifications() {
    return _sendRequest(
      'closeNotifications',
    );
  }

  Future<void> closeHeadsUpNotification() {
    return _sendRequest(
      'closeHeadsUpNotification',
    );
  }

  Future<GetNotificationsResponse> getNotifications(
    GetNotificationsRequest request,
  ) async {
    final json = await _sendRequest(
      'getNotifications',
      request.toJson(),
    );
    return GetNotificationsResponse.fromJson(json);
  }

  Future<void> tapOnNotification(
    TapOnNotificationRequest request,
  ) {
    return _sendRequest(
      'tapOnNotification',
      request.toJson(),
    );
  }

  Future<PermissionDialogVisibleResponse> isPermissionDialogVisible(
    PermissionDialogVisibleRequest request,
  ) async {
    final json = await _sendRequest(
      'isPermissionDialogVisible',
      request.toJson(),
    );
    return PermissionDialogVisibleResponse.fromJson(json);
  }

  Future<void> handlePermissionDialog(
    HandlePermissionRequest request,
  ) {
    return _sendRequest(
      'handlePermissionDialog',
      request.toJson(),
    );
  }

  Future<void> setLocationAccuracy(
    SetLocationAccuracyRequest request,
  ) {
    return _sendRequest(
      'setLocationAccuracy',
      request.toJson(),
    );
  }

  Future<void> debug() {
    return _sendRequest(
      'debug',
    );
  }

  Future<void> markPatrolAppServiceReady() {
    return _sendRequest(
      'markPatrolAppServiceReady',
    );
  }

  Future<Map<String, dynamic>> _sendRequest(
    String requestName, [
    Map<String, dynamic>? request,
  ]) async {
    final response = await _client
        .post(_apiUri.resolve(requestName), body: jsonEncode(request))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw NativeAutomatorClientException(response.statusCode, response.body);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

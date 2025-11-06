//
//  Generated code. Do not modify.
//  source: schema.dart
//
// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'contracts.dart';

class MobileAutomatorClientException implements Exception {
  MobileAutomatorClientException(this.statusCode, this.responseBody);

  final String responseBody;
  final int statusCode;

  @override
  String toString() {
    return 'Invalid response: $statusCode $responseBody';
  }
}

class MobileAutomatorClient {
  MobileAutomatorClient(
    this._client,
    this._apiUri, {
    Duration timeout = const Duration(seconds: 30),
  }) : _timeout = timeout,
       _headers = {
         'Connection': 'keep-alive',
         'Keep-Alive': 'timeout=${timeout.inSeconds}',
       };

  final Duration _timeout;
  final http.Client _client;
  final Uri _apiUri;
  final Map<String, String> _headers;

  Future<void> configure(ConfigureRequest request) {
    return _sendRequest('configure', request.toJson());
  }

  Future<void> pressHome() {
    return _sendRequest('pressHome');
  }

  Future<void> pressRecentApps() {
    return _sendRequest('pressRecentApps');
  }

  Future<void> openApp(OpenAppRequest request) {
    return _sendRequest('openApp', request.toJson());
  }

  Future<void> openPlatformApp(OpenPlatformAppRequest request) {
    return _sendRequest('openPlatformApp', request.toJson());
  }

  Future<void> openQuickSettings(OpenQuickSettingsRequest request) {
    return _sendRequest('openQuickSettings', request.toJson());
  }

  Future<void> openUrl(OpenUrlRequest request) {
    return _sendRequest('openUrl', request.toJson());
  }

  Future<void> pressVolumeUp() {
    return _sendRequest('pressVolumeUp');
  }

  Future<void> pressVolumeDown() {
    return _sendRequest('pressVolumeDown');
  }

  Future<void> enableAirplaneMode() {
    return _sendRequest('enableAirplaneMode');
  }

  Future<void> disableAirplaneMode() {
    return _sendRequest('disableAirplaneMode');
  }

  Future<void> enableWiFi() {
    return _sendRequest('enableWiFi');
  }

  Future<void> disableWiFi() {
    return _sendRequest('disableWiFi');
  }

  Future<void> enableCellular() {
    return _sendRequest('enableCellular');
  }

  Future<void> disableCellular() {
    return _sendRequest('disableCellular');
  }

  Future<void> enableBluetooth() {
    return _sendRequest('enableBluetooth');
  }

  Future<void> disableBluetooth() {
    return _sendRequest('disableBluetooth');
  }

  Future<void> enableDarkMode(DarkModeRequest request) {
    return _sendRequest('enableDarkMode', request.toJson());
  }

  Future<void> disableDarkMode(DarkModeRequest request) {
    return _sendRequest('disableDarkMode', request.toJson());
  }

  Future<void> openNotifications() {
    return _sendRequest('openNotifications');
  }

  Future<void> closeNotifications() {
    return _sendRequest('closeNotifications');
  }

  Future<GetNotificationsResponse> getNotifications(
    GetNotificationsRequest request,
  ) async {
    final json = await _sendRequest('getNotifications', request.toJson());
    return GetNotificationsResponse.fromJson(json);
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

  Future<void> handlePermissionDialog(HandlePermissionRequest request) {
    return _sendRequest('handlePermissionDialog', request.toJson());
  }

  Future<void> setLocationAccuracy(SetLocationAccuracyRequest request) {
    return _sendRequest('setLocationAccuracy', request.toJson());
  }

  Future<void> setMockLocation(SetMockLocationRequest request) {
    return _sendRequest('setMockLocation', request.toJson());
  }

  Future<void> markPatrolAppServiceReady() {
    return _sendRequest('markPatrolAppServiceReady');
  }

  Future<IsVirtualDeviceResponse> isVirtualDevice() async {
    final json = await _sendRequest('isVirtualDevice');
    return IsVirtualDeviceResponse.fromJson(json);
  }

  Future<GetOsVersionResponse> getOsVersion() async {
    final json = await _sendRequest('getOsVersion');
    return GetOsVersionResponse.fromJson(json);
  }

  Future<Map<String, dynamic>> _sendRequest(
    String requestName, [
    Map<String, dynamic>? request,
  ]) async {
    final response = await _client
        .post(
          _apiUri.resolve(requestName),
          body: jsonEncode(request),
          headers: _headers,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw MobileAutomatorClientException(response.statusCode, response.body);
    }

    return response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>
        : {};
  }
}

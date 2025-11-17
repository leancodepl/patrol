//
//  Generated code. Do not modify.
//  source: schema.dart
//
// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'contracts.dart';

class IosAutomatorClientException implements Exception {
  IosAutomatorClientException(this.statusCode, this.responseBody);

  final String responseBody;
  final int statusCode;

  @override
  String toString() {
    return 'Invalid response: $statusCode $responseBody';
  }
}

class IosAutomatorClient {
  IosAutomatorClient(
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

  Future<IOSGetNativeViewsResponse> getNativeViews(
    IOSGetNativeViewsRequest request,
  ) async {
    final json = await _sendRequest('getNativeViews', request.toJson());
    return IOSGetNativeViewsResponse.fromJson(json);
  }

  Future<void> tap(IOSTapRequest request) {
    return _sendRequest('tap', request.toJson());
  }

  Future<void> doubleTap(IOSTapRequest request) {
    return _sendRequest('doubleTap', request.toJson());
  }

  Future<void> enterText(IOSEnterTextRequest request) {
    return _sendRequest('enterText', request.toJson());
  }

  Future<void> tapAt(IOSTapAtRequest request) {
    return _sendRequest('tapAt', request.toJson());
  }

  Future<void> waitUntilVisible(IOSWaitUntilVisibleRequest request) {
    return _sendRequest('waitUntilVisible', request.toJson());
  }

  Future<void> swipe(IOSSwipeRequest request) {
    return _sendRequest('swipe', request.toJson());
  }

  Future<void> closeHeadsUpNotification() {
    return _sendRequest('closeHeadsUpNotification');
  }

  Future<void> tapOnNotification(IOSTapOnNotificationRequest request) {
    return _sendRequest('tapOnNotification', request.toJson());
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

  Future<void> takeCameraPhoto(IOSTakeCameraPhotoRequest request) {
    return _sendRequest('takeCameraPhoto', request.toJson());
  }

  Future<void> pickImageFromGallery(IOSPickImageFromGalleryRequest request) {
    return _sendRequest('pickImageFromGallery', request.toJson());
  }

  Future<void> pickMultipleImagesFromGallery(
    IOSPickMultipleImagesFromGalleryRequest request,
  ) {
    return _sendRequest('pickMultipleImagesFromGallery', request.toJson());
  }

  Future<void> debug() {
    return _sendRequest('debug');
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
      throw IosAutomatorClientException(response.statusCode, response.body);
    }

    return response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>
        : {};
  }
}

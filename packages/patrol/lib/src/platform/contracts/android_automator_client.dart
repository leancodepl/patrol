//
//  Generated code. Do not modify.
//  source: schema.dart
//
// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'contracts.dart';

class AndroidAutomatorClientException implements Exception {
  AndroidAutomatorClientException(this.statusCode, this.responseBody);

  final String responseBody;
  final int statusCode;

  @override
  String toString() {
    return 'Invalid response: $statusCode $responseBody';
  }
}

class AndroidAutomatorClient {
  AndroidAutomatorClient(
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

  Future<void> initialize() {
    return _sendRequest('initialize');
  }

  Future<void> pressBack() {
    return _sendRequest('pressBack');
  }

  Future<void> doublePressRecentApps() {
    return _sendRequest('doublePressRecentApps');
  }

  Future<AndroidGetNativeViewsResponse> getNativeViews(
    AndroidGetNativeViewsRequest request,
  ) async {
    final json = await _sendRequest('getNativeViews', request.toJson());
    return AndroidGetNativeViewsResponse.fromJson(json);
  }

  Future<void> tap(AndroidTapRequest request) {
    return _sendRequest('tap', request.toJson());
  }

  Future<void> doubleTap(AndroidTapRequest request) {
    return _sendRequest('doubleTap', request.toJson());
  }

  Future<void> tapAt(AndroidTapAtRequest request) {
    return _sendRequest('tapAt', request.toJson());
  }

  Future<void> enterText(AndroidEnterTextRequest request) {
    return _sendRequest('enterText', request.toJson());
  }

  Future<void> waitUntilVisible(AndroidWaitUntilVisibleRequest request) {
    return _sendRequest('waitUntilVisible', request.toJson());
  }

  Future<void> swipe(AndroidSwipeRequest request) {
    return _sendRequest('swipe', request.toJson());
  }

  Future<void> enableLocation() {
    return _sendRequest('enableLocation');
  }

  Future<void> disableLocation() {
    return _sendRequest('disableLocation');
  }

  Future<void> tapOnNotification(AndroidTapOnNotificationRequest request) {
    return _sendRequest('tapOnNotification', request.toJson());
  }

  Future<void> takeCameraPhoto(AndroidTakeCameraPhotoRequest request) {
    return _sendRequest('takeCameraPhoto', request.toJson());
  }

  Future<void> pickImageFromGallery(
    AndroidPickImageFromGalleryRequest request,
  ) {
    return _sendRequest('pickImageFromGallery', request.toJson());
  }

  Future<void> pickMultipleImagesFromGallery(
    AndroidPickMultipleImagesFromGalleryRequest request,
  ) {
    return _sendRequest('pickMultipleImagesFromGallery', request.toJson());
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
      throw AndroidAutomatorClientException(response.statusCode, response.body);
    }

    return response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>
        : {};
  }
}

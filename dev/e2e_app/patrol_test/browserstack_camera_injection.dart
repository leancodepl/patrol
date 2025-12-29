import 'package:flutter/services.dart';

/// Service for injecting camera images on BrowserStack.
///
/// This only works when running on BrowserStack infrastructure.
/// On local devices/simulators, it will return a failure response but won't crash.
class BrowserStackCameraInjection {
  static const _channel = MethodChannel('com.browserstack.camera_injection');

  /// Inject an image to simulate camera input (e.g., for QR code scanning).
  ///
  /// [imageName] - The name of the image file uploaded to BrowserStack media
  ///               (e.g., "qr_code.png")
  ///
  /// Returns a [CameraInjectionResult] with the status of the injection.
  ///
  /// Example:
  /// ```dart
  /// final result = await BrowserStackCameraInjection.injectImage('my_qr_code.png');
  /// if (result.success) {
  ///   // Image injected, proceed with camera interaction
  /// }
  /// ```
  static Future<CameraInjectionResult> injectImage(String imageName) async {
    try {
      final response = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'injectImage',
        {'imageName': imageName},
      );

      if (response == null) {
        return CameraInjectionResult(
          success: false,
          statusCode: -1,
          message: 'No response from native side',
        );
      }

      return CameraInjectionResult(
        success: response['success'] as bool? ?? false,
        statusCode: response['statusCode'] as int? ?? -1,
        message: response['message'] as String? ?? 'Unknown',
      );
    } on PlatformException catch (e) {
      return CameraInjectionResult(
        success: false,
        statusCode: -1,
        message: 'Platform error: ${e.message}',
      );
    } on MissingPluginException {
      // Method channel not available (e.g., running on Android or local iOS)
      return CameraInjectionResult(
        success: false,
        statusCode: -1,
        message: 'Camera injection not available on this platform',
      );
    }
  }
}

/// Result of a camera injection attempt.
class CameraInjectionResult {
  CameraInjectionResult({
    required this.success,
    required this.statusCode,
    required this.message,
  });
  final bool success;
  final int statusCode;
  final String message;

  @override
  String toString() =>
      'CameraInjectionResult(success: $success, statusCode: $statusCode, message: $message)';
}

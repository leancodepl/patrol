import 'dart:convert';
import 'dart:io' as io;

import 'package:http/http.dart' as http;
import 'package:patrol/src/extensions.dart';
import 'package:patrol/src/native/binding.dart';
import 'package:patrol/src/native/models/models.dart';

typedef _LoggerCallback = void Function(String);

// ignore: avoid_print
void _defaultPrintLogger(String message) => print('Patrol: $message');

/// Thrown when a native action fails.
class PatrolActionException implements Exception {
  /// Creates a new [PatrolActionException].
  PatrolActionException(this.message);

  /// Message that the native part returned.
  String message;

  @override
  String toString() => 'Patrol action failed: $message';
}

/// Provides functionality to interact with the host OS that the app under test
/// is running on.
///
/// Communicates over HTTP with the Patrol automator server running on the
/// target device.
class NativeAutomator {
  /// Creates a new [NativeAutomator] instance for use in testing environment
  /// (on the target device).
  NativeAutomator.forTest({
    this.timeout = const Duration(seconds: 10),
    _LoggerCallback logger = _defaultPrintLogger,
    this.packageName = const String.fromEnvironment('PATROL_APP_PACKAGE_NAME'),
    this.bundleId = const String.fromEnvironment('PATROL_APP_BUNDLE_ID'),
  })  : _logger = logger,
        host = const String.fromEnvironment(
          'PATROL_HOST',
          defaultValue: 'localhost',
        ),
        port = const String.fromEnvironment(
          'PATROL_PORT',
          defaultValue: '8081',
        ) {
    _logger('creating NativeAutomator, host: $host, port: $port');

    PatrolBinding.ensureInitialized();
  }

  final _LoggerCallback _logger;

  /// Host on which Patrol server instrumentation is running.
  final String host;

  /// Port on [host] on which Patrol server instrumentation is running.
  final String port;

  /// Timeout for HTTP requests to Patrol automation server.
  final Duration timeout;

  /// Unique identifier of the app under test on Android.
  final String packageName;

  /// Unique identifier of the app under test on iOS.
  final String bundleId;

  final _client = http.Client();

  String get _baseUri => 'http://$host:$port';

  /// Returns the platform-dependent unique identifier of the app under test.
  String get resolvedAppId {
    if (io.Platform.isAndroid) {
      return packageName;
    } else if (io.Platform.isIOS) {
      return bundleId;
    }

    throw StateError('unsupported platform');
  }

  Future<http.Response> _wrapGet(String action) async {
    _logger('action $action executing');

    final response = await _client.get(
      Uri.parse('$_baseUri/$action'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(timeout);

    if (!response.successful) {
      _handleErrorResponse(action, response);
    } else {
      _logger('action $action succeeded');
    }

    return response;
  }

  Future<http.Response> _wrapPost(
    String action, [
    Map<String, dynamic> body = const <String, dynamic>{},
  ]) async {
    if (body.isNotEmpty) {
      _logger('action $action executing with $body');
    } else {
      _logger('action $action executing');
    }

    final response = await _client.post(
      Uri.parse('$_baseUri/$action'),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    ).timeout(timeout);

    if (!response.successful) {
      _handleErrorResponse(action, response);
    } else {
      _logger('action $action succeeded');
    }

    return response;
  }

  void _handleErrorResponse(String action, http.Response response) {
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>?;
    final message = responseBody?['message'] as String? ?? 'no message';

    final log = 'action $action failed with code ${response.statusCode} '
        '($message)';
    _logger(log);

    throw PatrolActionException(message);
  }

  /// Returns whether the Patrol automation server is running on the target
  /// device.
  Future<bool> isRunning() async {
    try {
      final res = await _client.get(Uri.parse('$_baseUri/isRunning'));
      _logger('status code: ${res.statusCode}, response body: ${res.body}');
      return res.successful;
    } catch (err, st) {
      _logger('failed to call isRunning()\n$err\n$st');
      return false;
    }
  }

  /// Presses the back button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressback>,
  ///    which is used on Android.
  Future<void> pressBack() => _wrapPost('pressBack');

  /// Presses the home button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#presshome>,
  ///    which is used on Android
  ///
  /// * <https://developer.apple.com/documentation/xctest/xcuidevice/button/home>,
  ///   which is used on iOS
  Future<void> pressHome() => _wrapPost('pressHome');

  /// Opens the app specified by [id].
  ///
  /// On Android [id] is the package name. On iOS [id] is the bundle name.
  Future<void> openApp({required String id}) => _wrapPost(
        'openApp',
        <String, dynamic>{'appId': id},
      );

  /// Presses the recent apps button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressrecentapps>,
  ///    which is used on Android
  Future<void> pressRecentApps() => _wrapPost('pressRecentApps');

  /// Double presses the recent apps button.
  Future<void> pressDoubleRecentApps() => _wrapPost('pressDoubleRecentApps');

  /// Opens the notification shade.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#opennotification>,
  ///    which is used on Android
  Future<void> openNotifications() => _wrapPost('openNotifications');

  /// Opens the quick settings shade.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#openquicksettings>,
  ///    which is used on Android
  Future<void> openQuickSettings() => _wrapPost('openQuickSettings');

  /// Returns the first, topmost visible notification.
  ///
  /// Notification shade will be opened automatically.
  Future<Notification> getFirstNotification() async {
    final notifications = await getNotifications();
    return notifications[0];
  }

  /// Returns notifications that are visible in the notification shade.
  ///
  /// Notification shade will be opened automatically.
  Future<List<Notification>> getNotifications() async {
    final response = await _wrapGet('getNotifications');

    final notifications = json.decode(response.body) as List<dynamic>;
    return notifications
        .map((dynamic e) => Notification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Taps on the [index]-th visible notification.
  ///
  /// Notification shade will be opened automatically.
  Future<void> tapOnNotificationByIndex(int index) async {
    await _wrapPost(
      'tapOnNotificationByIndex',
      <String, dynamic>{'index': index},
    );
  }

  /// Taps on the visible notification using [selector].
  ///
  /// Notification shade will be opened automatically.
  Future<void> tapOnNotificationBySelector(Selector selector) async {
    await _wrapPost('tapOnNotificationBySelector', selector.toJson());
  }

  /// Enables dark mode.
  Future<void> enableDarkMode() => _wrapPost('enableDarkMode');

  /// Disables dark mode.
  Future<void> disableDarkMode() => _wrapPost('disableDarkMode');

  /// Enables WiFi.
  Future<void> enableWifi() => _wrapPost('enableWifi');

  /// Disables WiFi.
  Future<void> disableWifi() => _wrapPost('disableWifi');

  /// Enables cellular (aka mobile data connection).
  Future<void> enableCellular() => _wrapPost('enableCellular');

  /// Disables cellular (aka mobile data connection).
  Future<void> disableCellular() => _wrapPost('disableCellular');

  /// Taps on the native widget specified by [selector].
  ///
  /// If the native widget is not found, an exception is thrown.
  Future<void> tap(Selector selector, {String? appId}) {
    return _wrapPost(
      'tap',
      <String, dynamic>{
        'appId': appId ?? resolvedAppId,
        'selector': selector.toJson(),
      },
    );
  }

  /// Double taps on the native widget specified by [selector].
  ///
  /// If the native widget is not found, an exception is thrown.
  Future<void> doubleTap(Selector selector, {String? appId}) {
    return _wrapPost('doubleTap', <String, dynamic>{
      'appId': appId ?? resolvedAppId,
      'selector': selector.toJson(),
    });
  }

  /// Enters text to the native widget specified by [selector].
  ///
  /// The native widget specified by selector must be an EditText on Android.
  Future<void> enterText(
    Selector selector, {
    required String text,
    String? appId,
  }) {
    return _wrapPost(
      'enterTextBySelector',
      <String, dynamic>{
        'appId': appId ?? resolvedAppId,
        'data': text,
        'selector': selector.toJson(),
      },
    );
  }

  /// Enters text to the [index]-th visible text field.
  Future<void> enterTextByIndex(
    String text, {
    required int index,
    String? appId,
  }) {
    return _wrapPost(
      'enterTextByIndex',
      <String, dynamic>{
        'appId': appId ?? resolvedAppId,
        'data': text,
        'index': index,
      },
    );
  }

  /// Returns a list of native UI controls, specified by [selector], which are
  /// currently visible on screen.
  Future<List<NativeWidget>> getNativeWidgets(Selector selector) async {
    final response = await _wrapPost('getNativeWidgets', selector.toJson());

    final nativeWidgets = json.decode(response.body) as List<dynamic>;
    return nativeWidgets
        .map((dynamic e) => NativeWidget.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Grants the permission that the currently visible native permission request
  /// dialog is asking for.
  ///
  /// Throws an exception if no permission request dialog is present.
  Future<void> grantPermissionWhenInUse() async {
    // Wait for the dialog to appear await
    // Future<void>.delayed(Duration(milliseconds: 500));
    await _wrapPost(
      'handlePermission',
      <String, String>{'code': 'WHILE_USING'},
    );
  }

  /// Grants the permission that the currently visible native permission request
  /// dialog is asking for.
  ///
  /// Throws an exception if no permission request dialog is present.
  ///
  /// On iOS, this can only be used when granting the location permission.
  /// Otherwise it will crash.
  Future<void> grantPermissionOnlyThisTime() {
    return _wrapPost(
      'handlePermission',
      <String, String>{'code': 'ONLY_THIS_TIME'},
    );
  }

  /// Denies the permission that the currently visible native permission request
  /// dialog is asking for.
  ///
  /// Throws an exception if no permission request dialog is present.
  Future<void> denyPermission() {
    return _wrapPost(
      'handlePermission',
      <String, String>{'code': 'DENIED'},
    );
  }

  /// Select the "fine location" (aka "precise") setting on the currently
  /// visible native permission request dialog.
  ///
  /// Throws an exception if no permission request dialog is present.
  Future<void> selectFineLocation() => _wrapPost('selectFineLocation');

  /// Select the "coarse location" (aka "approximate") setting on the currently
  /// visible native permission request dialog.
  ///
  /// Throws an exception if no permission request dialog is present.
  Future<void> selectCoarseLocation() => _wrapPost('selectCoarseLocation');
}

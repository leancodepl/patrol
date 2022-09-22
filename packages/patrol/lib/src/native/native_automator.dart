import 'dart:convert';
import 'dart:io' as io;

import 'package:http/http.dart' as http;
import 'package:patrol/src/extensions.dart';
import 'package:patrol/src/native/binding.dart';

import 'contracts/contracts.dart';

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

  Future<http.Response> _wrapPost({
    required String action,
    Map<String, dynamic>? body = const <String, dynamic>{},
  }) async {
    if (body?.isNotEmpty ?? false) {
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
    var message = 'no message';
    try {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>?;
      message = responseBody?['message'] as String? ?? 'no message';
    } catch (_) {
      // it's okay to do nothing
    }

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
  Future<void> pressBack() => _wrapPost(action: 'pressBack');

  /// Presses the home button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#presshome>,
  ///    which is used on Android
  ///
  /// * <https://developer.apple.com/documentation/xctest/xcuidevice/button/home>,
  ///   which is used on iOS
  Future<void> pressHome() => _wrapPost(action: 'pressHome');

  /// Opens the app specified by [id].
  ///
  /// On Android [id] is the package name. On iOS [id] is the bundle name.
  Future<void> openApp({required String id}) {
    return _wrapPost(
      action: 'openApp',
      body: OpenAppCommand(appId: id).toProto3Json() as Map<String, dynamic>?,
    );
  }

  /// Presses the recent apps button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressrecentapps>,
  ///    which is used on Android
  Future<void> pressRecentApps() => _wrapPost(action: 'pressRecentApps');

  /// Double presses the recent apps button.
  Future<void> pressDoubleRecentApps() =>
      _wrapPost(action: 'pressDoubleRecentApps');

  /// Opens the notification shade.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#opennotification>,
  ///    which is used on Android
  Future<void> openNotifications() => _wrapPost(action: 'openNotifications');

  /// Opens the quick settings shade.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#openquicksettings>,
  ///    which is used on Android
  Future<void> openQuickSettings() => _wrapPost(action: 'openQuickSettings');

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
    final queryResponse = NotificationsQueryResponse.create()
      ..mergeFromProto3Json(jsonDecode(response.body));

    return queryResponse.notifications;
  }

  /// Taps on the [index]-th visible notification.
  ///
  /// Notification shade will be opened automatically.
  Future<void> tapOnNotificationByIndex(int index) async {
    await _wrapPost(
      action: 'tapOnNotificationByIndex',
      body: TapOnNotificationByIndexCommand(index: index).toProto3Json()
          as Map<String, dynamic>?,
    );
  }

  /// Taps on the visible notification using [selector].
  ///
  /// Notification shade will be opened automatically.
  Future<void> tapOnNotificationBySelector(Selector selector) async {
    await _wrapPost(
      action: 'tapOnNotificationBySelector',
      body: TapOnNotificationBySelectorCommand(selector: selector)
          .toProto3Json() as Map<String, dynamic>?,
    );
  }

  /// Enables dark mode.
  Future<void> enableDarkMode() => _wrapPost(action: 'enableDarkMode');

  /// Disables dark mode.
  Future<void> disableDarkMode() => _wrapPost(action: 'disableDarkMode');

  /// Enables WiFi.
  Future<void> enableWifi() => _wrapPost(action: 'enableWifi');

  /// Disables WiFi.
  Future<void> disableWifi() => _wrapPost(action: 'disableWifi');

  /// Enables celluar (aka mobile data connection).
  Future<void> enableCelluar() => _wrapPost(action: 'enableCelluar');

  /// Disables celluar (aka mobile data connection).
  Future<void> disableCelluar() => _wrapPost(action: 'disableCelluar');

  /// Taps on the native widget specified by [selector].
  ///
  /// If the native widget is not found, an exception is thrown.
  Future<void> tap(Selector selector, {String? appId}) {
    return _wrapPost(
      action: 'tap',
      body: TapCommand(selector: selector).toProto3Json()
          as Map<String, dynamic>?,
    );
  }

  /// Double taps on the native widget specified by [selector].
  ///
  /// If the native widget is not found, an exception is thrown.
  Future<void> doubleTap(Selector selector, {String? appId}) {
    return _wrapPost(
      action: 'doubleTap',
      body: DoubleTapCommand(selector: selector, appId: appId).toProto3Json()
          as Map<String, dynamic>?,
    );
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
      action: 'enterTextBySelector',
      body: EnterTextBySelectorCommand(
        appId: appId,
        data: text,
        selector: selector,
      ).toProto3Json() as Map<String, dynamic>?,
    );
  }

  /// Enters text to the [index]-th visible text field.
  Future<void> enterTextByIndex(
    String text, {
    required int index,
    String? appId,
  }) {
    return _wrapPost(
      action: 'enterTextByIndex',
      body: EnterTextByIndexCommand(
        appId: appId,
        data: text,
        index: index,
      ).toProto3Json() as Map<String, dynamic>?,
    );
  }

  /// Returns a list of currently visible native UI controls, specified by
  /// [selector], which are currently visible on screen.
  Future<List<NativeWidget>> getNativeWidgets(Selector selector) async {
    final response = await _wrapGet('getNativeWidgets');
    final queryResponse = NativeWidgetsQueryResponse.create()
      ..mergeFromProto3Json(jsonDecode(response.body));

    return queryResponse.nativeWidgets;
  }

  /// Grants the permission that the currently visible native permission request
  /// dialog is asking for.
  ///
  /// Throws an exception if no permission request dialog is present.
  Future<void> grantPermissionWhenInUse() async {
    await _wrapPost(
      action: 'handlePermission',
      body: HandlePermissionCommand(
        code: HandlePermissionCommand_Code.WHILE_USING,
      ).toProto3Json() as Map<String, dynamic>?,
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
      action: 'handlePermission',
      body: HandlePermissionCommand(
        code: HandlePermissionCommand_Code.ONLY_THIS_TIME,
      ).toProto3Json() as Map<String, dynamic>?,
    );
  }

  /// Denies the permission that the currently visible native permission request
  /// dialog is asking for.
  ///
  /// Throws an exception if no permission request dialog is present.
  Future<void> denyPermission() {
    return _wrapPost(
      action: 'handlePermission',
      body: HandlePermissionCommand(
        code: HandlePermissionCommand_Code.DENIED,
      ).toProto3Json() as Map<String, dynamic>?,
    );
  }

  /// Select the "fine location" (aka "precise") setting on the currently
  /// visible native permission request dialog.
  ///
  /// Throws an exception if no permission request dialog is present.
  Future<void> selectFineLocation() => _wrapPost(action: 'selectFineLocation');

  /// Select the "coarse location" (aka "approximate") setting on the currently
  /// visible native permission request dialog.
  ///
  /// Throws an exception if no permission request dialog is present.
  Future<void> selectCoarseLocation() {
    return _wrapPost(action: 'selectCoarseLocation');
  }
}

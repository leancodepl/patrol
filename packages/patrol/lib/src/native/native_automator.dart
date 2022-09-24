import 'dart:convert';
import 'dart:io' as io;

import 'package:grpc/grpc.dart';
import 'package:http/http.dart' as http;
import 'package:patrol/src/native/binding.dart';
import 'package:patrol/src/native/contracts/contracts.pbgrpc.dart';

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
    String? packageName,
    String? bundleId,
  })  : _logger = logger,
        host = const String.fromEnvironment(
          'PATROL_HOST',
          defaultValue: 'localhost',
        ),
        port = const String.fromEnvironment(
          'PATROL_PORT',
          defaultValue: '8081',
        ) {
    this.packageName =
        packageName ?? const String.fromEnvironment('PATROL_APP_PACKAGE_NAME');

    this.bundleId =
        bundleId ?? const String.fromEnvironment('PATROL_APP_BUNDLE_ID');

    _logger(
      'creating NativeAutomator, host: $host, port: $port, '
      'packageName: $packageName, bundleId: $bundleId',
    );

    final channel = ClientChannel(
      host,
      port: int.parse(port),
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );

    _client = NativeAutomatorClient(channel);

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
  late final String packageName;

  /// Unique identifier of the app under test on iOS.
  late final String bundleId;

  late final NativeAutomatorClient _client;

  /// Returns the platform-dependent unique identifier of the app under test.
  String get resolvedAppId {
    if (io.Platform.isAndroid) {
      return packageName;
    } else if (io.Platform.isIOS) {
      return bundleId;
    }

    throw StateError('unsupported platform');
  }

/*   Future<http.Response> _wrapPost({
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
  } */

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

  /// Presses the back button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressback>,
  ///    which is used on Android.
  Future<void> pressBack() => _client.pressBack(PressBackRequest());

  /// Presses the home button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#presshome>,
  ///    which is used on Android
  ///
  /// * <https://developer.apple.com/documentation/xctest/xcuidevice/button/home>,
  ///   which is used on iOS
  Future<void> pressHome() => _client.pressHome(PressHomeRequest());

  /// Opens the app specified by [appId].
  ///
  /// On Android [appId] is the package name. On iOS [appId] is the bundle name.
  Future<void> openApp({required String appId}) async {
    await _client.openApp(OpenAppRequest(appId: appId));
  }

  /// Presses the recent apps button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressrecentapps>,
  ///    which is used on Android
  Future<void> pressRecentApps() async {
    await _client.pressRecentApps(PressRecentAppsRequest());
  }

  /// Double presses the recent apps button.
  Future<void> pressDoubleRecentApps() async {
    await _client.doublePressRecentApps(DoublePressRecentAppsRequest());
  }

  /// Opens the notification shade.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#opennotification>,
  ///    which is used on Android
  Future<void> openNotifications() async {
    await _client.openNotifications(OpenNotificationsRequest());
  }

  /// Opens the quick settings shade.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#openquicksettings>,
  ///    which is used on Android
  Future<void> openQuickSettings() async {
    await _client.openQuickSettings(OpenQuickSettingsRequest());
  }

  /// Returns the first, topmost visible notification.
  ///
  /// Notification shade will be opened automatically.
  Future<Notification> getFirstNotification() async {
    final response = await _client.getNotifications(
      GetNotificationsRequest(),
    );

    return response.notifications.first;
  }

  /// Returns notifications that are visible in the notification shade.
  ///
  /// Notification shade will be opened automatically.
  Future<List<Notification>> getNotifications() async {
    final response = await _client.getNotifications(
      GetNotificationsRequest(),
    );

    return response.notifications;
  }

  /// Taps on the [index]-th visible notification.
  ///
  /// Notification shade will be opened automatically.
  Future<void> tapOnNotificationByIndex(int index) async {
    await _client.tapOnNotification(TapOnNotificationRequest(index: index));
  }

  /// Taps on the visible notification using [selector].
  ///
  /// Notification shade will be opened automatically.
  Future<void> tapOnNotificationBySelector(Selector selector) async {
    await _client.tapOnNotification(
      TapOnNotificationRequest(selector: selector),
    );
  }

  /// Enables dark mode.
  Future<void> enableDarkMode({String? appId}) async {
    await _client
        .enableDarkMode(DarkModeRequest(appId: appId ?? resolvedAppId));
  }

  /// Disables dark mode.
  Future<void> disableDarkMode({String? appId}) async {
    await _client
        .disableDarkMode(DarkModeRequest(appId: appId ?? resolvedAppId));
  }

  /// Enables WiFi.
  Future<void> enableWifi({String? appId}) async {
    await _client.enableWiFi(WiFiRequest(appId: appId ?? resolvedAppId));
  }

  /// Disables WiFi.
  Future<void> disableWifi({String? appId}) async {
    await _client.disableWiFi(WiFiRequest(appId: appId ?? resolvedAppId));
  }

  /// Enables cellular (aka mobile data connection).
  Future<void> enableCellular() => _client.enableCellular(CellularRequest());

  /// Disables cellular (aka mobile data connection).
  Future<void> disableCellular() => _client.disableCellular(CellularRequest());

  /// Taps on the native widget specified by [selector].
  ///
  /// If the native widget is not found, an exception is thrown.
  Future<void> tap(Selector selector, {String? appId}) async {
    await _client.tap(
      TapRequest(
        selector: selector,
        appId: appId ?? resolvedAppId,
      ),
    );
  }

  /// Double taps on the native widget specified by [selector].
  ///
  /// If the native widget is not found, an exception is thrown.
  Future<void> doubleTap(Selector selector, {String? appId}) async {
    await _client.doubleTap(
      TapRequest(
        selector: selector,
        appId: appId ?? resolvedAppId,
      ),
    );
  }

  /// Enters text to the native widget specified by [selector].
  ///
  /// The native widget specified by selector must be an EditText on Android.
  Future<void> enterText(
    Selector selector, {
    required String text,
    String? appId,
  }) async {
    await _client.enterText(
      EnterTextRequest(
        data: text,
        selector: selector,
        appId: appId ?? resolvedAppId,
      ),
    );
  }

  /// Enters text to the [index]-th visible text field.
  Future<void> enterTextByIndex(
    String text, {
    required int index,
    String? appId,
  }) async {
    await _client.enterText(
      EnterTextRequest(
        data: text,
        index: index,
        appId: appId ?? resolvedAppId,
      ),
    );
  }

  /// Returns a list of currently visible native UI controls, specified by
  /// [selector], which are currently visible on screen.
  Future<List<NativeWidget>> getNativeWidgets(Selector selector) async {
    final response = await _client.getNativeWidgets(
      GetNativeWidgetsRequest(selector: selector),
    );

    return response.nativeWidgets;
  }

  /// Grants the permission that the currently visible native permission request
  /// dialog is asking for.
  ///
  /// Throws an exception if no permission request dialog is present.
  Future<void> grantPermissionWhenInUse() async {
    await _client.handlePermissionDialog(
      HandlePermissionRequest(code: HandlePermissionRequest_Code.WHILE_USING),
    );
  }

  /// Grants the permission that the currently visible native permission request
  /// dialog is asking for.
  ///
  /// Throws an exception if no permission request dialog is present.
  ///
  /// On iOS, this can only be used when granting the location permission.
  /// Otherwise it will crash.
  Future<void> grantPermissionOnlyThisTime() async {
    await _client.handlePermissionDialog(
      HandlePermissionRequest(
        code: HandlePermissionRequest_Code.ONLY_THIS_TIME,
      ),
    );
  }

  /// Denies the permission that the currently visible native permission request
  /// dialog is asking for.
  ///
  /// Throws an exception if no permission request dialog is present.
  Future<void> denyPermission() async {
    await _client.handlePermissionDialog(
      HandlePermissionRequest(code: HandlePermissionRequest_Code.DENIED),
    );
  }

  /// Select the "coarse location" (aka "approximate") setting on the currently
  /// visible native permission request dialog.
  ///
  /// Throws an exception if no permission request dialog is present.
  Future<void> selectCoarseLocation() async {
    await _client.setLocationAccuracy(
      SetLocationAccuracyRequest(
        locationAccuracy: SetLocationAccuracyRequest_LocationAccuracy.COARSE,
      ),
    );
  }

  /// Select the "fine location" (aka "precise") setting on the currently
  /// visible native permission request dialog.
  ///
  /// Throws an exception if no permission request dialog is present.
  Future<void> selectFineLocation() async {
    await _client.setLocationAccuracy(
      SetLocationAccuracyRequest(
        locationAccuracy: SetLocationAccuracyRequest_LocationAccuracy.FINE,
      ),
    );
  }
}

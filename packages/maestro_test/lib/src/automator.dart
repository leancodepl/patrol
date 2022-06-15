import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart' as logging;
import 'package:maestro_test/maestro_test.dart';
import 'package:maestro_test/src/extensions.dart';

/// Provides functionality to control the device.
///
/// Communicates over HTTP with the Maestro server app running on the target
/// device.
class Automator {
  Automator._();

  static Automator? _instance;

  // ignore: prefer_constructors_over_static_methods
  static Automator get instance => _instance ??= Automator._();

  static void init({int port = 8081, bool verbose = false}) {
    instance._port = port;

    logging.Logger.root.onRecord.listen((event) {
      // ignore: avoid_print
      print('${event.loggerName}: ${event.message}');
    });

    logging.hierarchicalLoggingEnabled = true;
    if (verbose) {
      instance._logger.level = logging.Level.ALL;
    } else {
      instance._logger.level = logging.Level.INFO;
    }
  }

  final _client = http.Client();
  final _logger = logging.Logger('Automator');

  late final int _port;
  String get _baseUri => 'http://localhost:$_port';

  Future<http.Response> _wrapPost(
    String action, [
    Map<String, dynamic> body = const <String, dynamic>{},
  ]) async {
    _logger.fine('executing action "$action"');

    final response = await _client.post(
      Uri.parse('$_baseUri/$action'),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 5));

    if (!response.successful) {
      final msg = 'action "$action" failed with code ${response.statusCode}';
      throw Exception('$msg\n${response.body}');
    } else {
      _logger.fine('action "$action" succeeded');
    }

    return response;
  }

  /// Returns whether the Maestro automation server is running on target device.
  Future<bool> isRunning() async {
    try {
      final res = await _client.get(Uri.parse('$_baseUri/healthCheck'));
      _logger.info(
        'status code: ${res.statusCode}, response body:\n ${res.body}',
      );
      return res.successful;
    } catch (err, st) {
      _logger.warning('failed to call isRunning()', err, st);
      return false;
    }
  }

  /// Stops the instrumentation server.
  Future<void> stop() async {
    try {
      _logger.info('stopping instrumentation server...');
      await _client.post(Uri.parse('$_baseUri/stop'));
    } catch (err, st) {
      _logger.warning('failed to call stop()', err, st);
    } finally {
      _logger.info('instrumentation server stopped');
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
  Future<void> pressHome() => _wrapPost('pressHome');

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

  /// Enables dark mode.
  Future<void> enableDarkMode() => _wrapPost('enableDarkMode');

  /// Disables dark mode.
  Future<void> disableDarkMode() => _wrapPost('disableDarkMode');

  /// Enables WiFi.
  Future<void> enableWifi() => _wrapPost('enableWifi');

  /// Disables WiFi.
  Future<void> disableWifi() => _wrapPost('disableWifi');

  /// Enables celluar (aka mobile data connection).
  Future<void> enableCelluar() => _wrapPost('enableCelluar');

  /// Disables celluar (aka mobile data connection).
  Future<void> disableCelluar() => _wrapPost('disableCelluar');

  /// Taps at the [index]-th visible button.
  Future<void> tap(int index) {
    return _wrapPost('tap', <String, dynamic>{'index': index});
  }

  /// Enters text to the [index]-th visible text field.
  Future<void> enterText(int index, String text) {
    return _wrapPost(
      'enterText',
      <String, dynamic>{'index': index, 'text': text},
    );
  }

  /// Returns a list of native UI controls that are currently visible on screen.
  Future<List<NativeWidget>> getNativeWidgets({
    required Conditions conditions,
  }) async {
    final response = await _wrapPost('getNativeWidgets', conditions.toJson());

    final nativeWidgets = json.decode(response.body) as List<dynamic>;
    return nativeWidgets
        .map((dynamic e) => NativeWidget.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

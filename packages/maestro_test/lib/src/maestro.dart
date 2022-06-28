import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart' as logging;
import 'package:logging/logging.dart';
import 'package:maestro_test/maestro_test.dart';
import 'package:maestro_test/src/extensions.dart';
import 'package:maestro_test/src/notification.dart';

/// Provides functionality to control the device.
///
/// Communicates over HTTP with the Maestro server app running on the target
/// device.
class Maestro {
  /// Creates a new [Maestro] instance for use in the driver file (on test
  /// host).
  Maestro.forDriver()
      : host = Platform.environment['MAESTRO_HOST']!,
        port = Platform.environment['MAESTRO_PORT']!,
        verbose = Platform.environment['MAESTRO_VERBOSE'] == 'true' {
    _setUpLogger();
    _logger.info(
      'Creating Maestro driver instance. Host: $host, port: $port, verbose: $verbose',
    );
  }

  /// Creates a new [Maestro] instance for use in testing environment (on target
  /// device).
  Maestro.forTest()
      : host = const String.fromEnvironment('MAESTRO_HOST'),
        port = const String.fromEnvironment('MAESTRO_PORT'),
        verbose = const String.fromEnvironment('MAESTRO_VERBOSE') == 'true' {
    _logger.info(
      'Creating Maestro test instance. Host: $host, port: $port, verbose: $verbose',
    );
    _setUpLogger();
  }

  /// Host on which Maestro server instrumentation is running.
  final String host;

  /// Port on [host] on which Maestro server instrumentation is running.
  final String port;

  /// Whether to print more logs.
  final bool verbose;

  /// Timeout for HTTP requests to Maestro automation server.
  final timeout = const Duration(seconds: 10);

  final _client = http.Client();
  final _logger = logging.Logger('Maestro');

  String get _baseUri => 'http://$host:$port';

  /// Sets up the global logger.
  ///
  /// We use 4 log levels:
  /// - [Level.SEVERE], printed in red
  /// - [Level.WARNING], printed in yellow
  /// - [Level.INFO], printed in white
  /// - [Level.FINE], printed in grey and only when [verbose] is true
  Future<void> _setUpLogger({bool verbose = false}) async {
    if (verbose) {
      // ignore: avoid_print
      print('Verbose mode enabled. More logs will be printed.');
    }

    Logger.root.level = Level.ALL;

    // ignore: avoid_print
    Logger.root.onRecord.listen((log) => print(_formatLog(log)));
  }

  /// Copied from
  /// https://github.com/leancodepl/logging_bugfender/blob/master/lib/src/print_strategy.dart.
  String _formatLog(LogRecord record) {
    final hasName = record.loggerName.isNotEmpty;
    final hasMessage = record.message != 'null' && record.message.isNotEmpty;

    final hasTopLine = hasName || hasMessage;
    final hasError = record.error != null;
    final hasStackTrace = record.stackTrace != null;

    final log = StringBuffer();

    if (hasTopLine) {
      log.writeAll(
        <String>[
          if (hasName) '${record.loggerName}: ',
          if (hasMessage) record.message,
        ],
      );
    }

    if (hasTopLine && hasError) {
      log.write('\n');
    }

    if (hasError) {
      log.write(record.error);
    }

    if (hasError && hasStackTrace) {
      log.write('\n');
    }

    if (hasStackTrace) {
      log.write(record.stackTrace);
    }

    return log.toString();
  }

  Future<http.Response> _wrapGet(String action) async {
    _logger.fine('$action: executing...');

    final response = await _client.get(
      Uri.parse('$_baseUri/$action'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(timeout);

    if (!response.successful) {
      final msg = '$action: failed with code ${response.statusCode}';
      throw Exception('$msg\n${response.body}');
    } else {
      _logger.fine('$action: succeeded');
    }

    return response;
  }

  Future<http.Response> _wrapPost(
    String action, [
    Map<String, dynamic> body = const <String, dynamic>{},
  ]) async {
    _logger.fine('$action: executing...');

    final response = await _client.post(
      Uri.parse('$_baseUri/$action'),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    ).timeout(timeout);

    if (!response.successful) {
      final msg = '$action: failed with code ${response.statusCode}';
      throw Exception('$msg\n${response.body}');
    } else {
      _logger.fine('$action: succeeded');
    }

    return response;
  }

  /// Performs a simple system health check.
  ///
  /// Returns whether the Maestro automation server is running on target device.
  Future<bool> healthCheck() async {
    try {
      final res = await _client.get(Uri.parse('$_baseUri/healthCheck'));
      _logger.info(
        'status code: ${res.statusCode}, response body: ${res.body}',
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
  Future<void> tapOnNotification({int index = 0}) async {
    await _wrapPost('tapOnNotification', <String, dynamic>{'index': index});
  }

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

  /// Enables bluetooth.
  Future<void> enableBluetooth() => _wrapPost('enableBluetooth');

  /// Disables bluetooth.
  Future<void> disableBluetooth() => _wrapPost('disableBluetooth');

  /// Taps on the native widget specified by [selector].
  ///
  /// If the native widget is not found, an exception is thrown.
  Future<void> tap(Selector selector) {
    return _wrapPost('tap', selector.toJson());
  }

  Future<void> enterText(Selector selector, {required String text}) {
    return _wrapPost(
      'enterTextBySelector',
      <String, dynamic>{'selector': selector.toJson(), 'text': text},
    );
  }

  /// Enters text to the [index]-th visible text field.
  Future<void> enterTextByIndex(String text, {required int index}) {
    return _wrapPost(
      'enterTextByIndex',
      <String, dynamic>{'index': index, 'text': text},
    );
  }

  /// Returns a list of native UI controls that are currently visible on screen.
  Future<List<NativeWidget>> getNativeWidgets({
    required Selector selector,
  }) async {
    final response = await _wrapPost('getNativeWidgets', selector.toJson());

    final nativeWidgets = json.decode(response.body) as List<dynamic>;
    return nativeWidgets
        .map((dynamic e) => NativeWidget.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:logging/logging.dart' as logging;
import 'package:logging/logging.dart';
import 'package:maestro_test/src/extensions.dart';
import 'package:maestro_test/src/native/native_widget.dart';
import 'package:maestro_test/src/native/notification.dart';
import 'package:maestro_test/src/native/selector.dart';

/// Provides functionality to control the device.
///
/// Communicates over HTTP with the Maestro server app running on the target
/// device.
class Maestro {
  /// Creates a new [Maestro] instance for use in testing environment (on the
  /// target device).
  Maestro.forTest()
      : host = const String.fromEnvironment('MAESTRO_HOST'),
        port = const String.fromEnvironment('MAESTRO_PORT'),
        verbose = const String.fromEnvironment('MAESTRO_VERBOSE') == 'true' {
    _logger.info(
      'Creating Maestro test instance. Host: $host, port: $port, verbose: $verbose',
    );
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
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

    Logger.root.onRecord.listen((log) {
      final fmtLog = _formatLog(log);

      // ignore: avoid_print
      print(fmtLog);
    });
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
    _logger.info('action $action executing');

    final response = await _client.get(
      Uri.parse('$_baseUri/$action'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(timeout);

    if (!response.successful) {
      final msg = 'action $action failed with code ${response.statusCode}';
      _handleErrorResponse(msg, response);
    } else {
      _logger.info('action $action succeeded');
    }

    return response;
  }

  Future<http.Response> _wrapPost(
    String action, [
    Map<String, dynamic> body = const <String, dynamic>{},
  ]) async {
    if (body.isNotEmpty) {
      _logger.info('action $action executing with $body');
    } else {
      _logger.info('action $action executing');
    }

    final response = await _client.post(
      Uri.parse('$_baseUri/$action'),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    ).timeout(timeout);

    if (!response.successful) {
      final msg = 'action $action failed with code ${response.statusCode}';
      _handleErrorResponse(msg, response);
    } else {
      _logger.info('action $action succeeded');
    }

    return response;
  }

  void _handleErrorResponse(String msg, http.Response response) {
    if (response.statusCode == 404) {
      _logger
        ..severe(msg)
        ..severe('Matching UI object could not be found');
    }

    throw Exception('$msg\n${response.body}');
  }

  /// Returns whether the Maestro automation server is running on the target
  /// device.
  Future<bool> isRunning() async {
    try {
      final res = await _client.get(Uri.parse('$_baseUri/isRunning'));
      _logger.info(
        'status code: ${res.statusCode}, response body: ${res.body}',
      );
      return res.successful;
    } catch (err, st) {
      _logger.warning('failed to call isRunning()', err, st);
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
  Future<void> openHalfNotificationShade() =>
      _wrapPost('openHalfNotificationShade');

  /// Opens the notification shade (equivalent of by swiping down 2 times).
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#opennotification>,
  ///    which is used on Android
  Future<void> openFullNotificationShade() =>
      _wrapPost('openFullNotificationShade');

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

  /// Enables celluar (aka mobile data connection).
  Future<void> enableCelluar() => _wrapPost('enableCelluar');

  /// Disables celluar (aka mobile data connection).
  Future<void> disableCelluar() => _wrapPost('disableCelluar');

  /// Taps on the native widget specified by [selector].
  ///
  /// If the native widget is not found, an exception is thrown.
  Future<void> tap(Selector selector) {
    return _wrapPost('tap', selector.toJson());
  }

  /// Double taps on the native widget specified by [selector].
  ///
  /// If the native widget is not found, an exception is thrown.
  Future<void> doubleTap(Selector selector) {
    return _wrapPost('doubleTap', selector.toJson());
  }

  /// Enters text to the native widget specified by [selector].
  ///
  /// The native widget specified by selector must be an EditText on Android.
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

  /// Returns a list of native UI controls, specified by [selector], which are
  /// currently visible on screen.
  Future<List<NativeWidget>> getNativeWidgets(Selector selector) async {
    final response = await _wrapPost('getNativeWidgets', selector.toJson());

    final nativeWidgets = json.decode(response.body) as List<dynamic>;
    return nativeWidgets
        .map((dynamic e) => NativeWidget.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

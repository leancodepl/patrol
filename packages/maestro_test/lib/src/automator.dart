import 'package:http/http.dart' as http;
import 'package:logging/logging.dart' as logging;

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

  Future<bool> isRunning() async {
    try {
      final res = await _client.get(Uri.parse('$_baseUri/healthCheck'));
      _logger.info(
        'status code: ${res.statusCode}, response body:\n ${res.body}',
      );
      return res.statusCode == 200;
    } catch (err, st) {
      _logger.warning("failed to call isRunning()", err, st);
      return false;
    }
  }

  /// Stops the instrumentation server.
  Future<void> stop() async {
    try {
      _logger.info('stopping instrumentation server...');
      await _client.post(Uri.parse('$_baseUri/stop'));
    } catch (err, st) {
      _logger.warning("failed to call stop()", err, st);
    } finally {
      _logger.info('instrumentation server stopped');
    }
  }

  /// Presses the home button.
  ///
  /// See also:
  /// * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#presshome>, which is used on Android
  Future<void> pressHome() => _wrap('pressHome');

  /// Presses the recent apps button.
  ///
  /// See also:
  /// * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressrecentapps>, which is used on Android
  Future<void> pressRecentApps() => _wrap('pressRecentApps');

  /// Double presses the recent apps button.
  Future<void> pressDoubleRecentApps() => _wrap('pressDoubleRecentApps');

  Future<void> openNotifications() => _wrap('openNotifications');

  Future<void> _wrap(String action) async {
    _logger.fine('executing action $action');

    final response = await _client.post(Uri.parse('$_baseUri/$action'));

    if (response.statusCode != 200) {
      _logger.warning(
        'action $action failed with status code ${response.statusCode}',
      );
    }
  }
}

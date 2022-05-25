import 'package:http/http.dart' as http;

class Automator {
  Automator._();

  static Automator? _instance;
  static Automator get instance => _instance ??= Automator._();

  static void init([int port = 8081]) => instance._port = port;

  final _client = http.Client();
  late final int _port;
  String get _baseUri => 'http://localhost:$_port';

  Future<bool> isRunning() async {
    try {
      final res = await _client.get(Uri.parse('$_baseUri/healthCheck'));
      print(res.body);
      print(res.statusCode);
      return res.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> stop() async {
    try {
      print('Stopping instrumentation server...');
      await _client.post(Uri.parse('$_baseUri/stop'));
    } catch (e) {
      print(e);
    } finally {
      print('Instrumentation server stopped');
    }
  }

  Future<void> pressHome() async =>
      _client.post(Uri.parse('$_baseUri/pressHome'));

  Future<void> pressRecentApps() async =>
      _client.post(Uri.parse('$_baseUri/pressRecentApps'));

  Future<void> pressDoubleRecentApps() async =>
      _client.post(Uri.parse('$_baseUri/pressDoubleRecentApps'));
}

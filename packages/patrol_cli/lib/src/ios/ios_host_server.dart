import 'dart:convert';
import 'dart:io';

import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/ios/simulator_hinge.dart';

/// Server on the host for actions a simulator can't do itself, such as folding.
class IOSHostServer {
  IOSHostServer._(this._server, this._hinge, this._logger);

  final HttpServer _server;
  final SimulatorHinge _hinge;
  final Logger _logger;

  static const setHingeAnglePath = '/setHingeAngle';

  static Future<IOSHostServer> start({
    required SimulatorHinge hinge,
    required Logger logger,
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final hostServer = IOSHostServer._(server, hinge, logger);
    server.listen(hostServer._handleRequest);
    logger.detail('iOS host server listening on port ${server.port}');

    return hostServer;
  }

  int get port => _server.port;

  Future<void> _handleRequest(HttpRequest request) async {
    final response = request.response;
    if (request.method != 'POST' || request.uri.path != setHingeAnglePath) {
      response.statusCode = HttpStatus.notFound;
      await response.close();
      return;
    }

    try {
      final body = jsonDecode(await utf8.decodeStream(request));
      final degrees = switch (body) {
        {'degrees': final num degrees} => degrees.toDouble(),
        _ => throw FormatException('Expected {"degrees": <number>}', body),
      };

      final previousDegrees = _hinge.angle;
      await _hinge.setAngle(degrees);

      response.write(jsonEncode({'previousDegrees': previousDegrees}));
    } on Exception catch (err) {
      _logger.detail('$setHingeAnglePath failed: $err');

      response
        ..statusCode = HttpStatus.internalServerError
        ..write('$err');
    }

    await response.close();
  }

  Future<void> close() async {
    await _server.close(force: true);
    await _hinge.close();
  }
}

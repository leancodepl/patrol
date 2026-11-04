import 'dart:convert';
import 'dart:io';

import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/ios/simulator_biometrics.dart';
import 'package:patrol_cli/src/ios/simulator_hinge.dart';

/// Server on the host for actions a simulator can't do itself, such as folding.
class IOSHostServer {
  IOSHostServer._(this._server, this._hinge, this._biometrics, this._logger);

  final HttpServer _server;
  final SimulatorHinge _hinge;
  final SimulatorBiometrics _biometrics;
  final Logger _logger;

  static const setHingeAnglePath = '/setHingeAngle';
  static const setBiometricEnrollmentPath = '/setBiometricEnrollment';
  static const sendBiometricMatchPath = '/sendBiometricMatch';

  static Future<IOSHostServer> start({
    required SimulatorHinge hinge,
    required SimulatorBiometrics biometrics,
    required Logger logger,
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final hostServer = IOSHostServer._(server, hinge, biometrics, logger);
    server.asyncMap(hostServer._handleRequest).listen((_) {});
    logger.detail('iOS host server listening on port ${server.port}');

    return hostServer;
  }

  int get port => _server.port;

  Future<void> _handleRequest(HttpRequest request) async {
    final response = request.response;
    final path = request.uri.path;
    final handler = switch (path) {
      setHingeAnglePath => _setHingeAngle,
      setBiometricEnrollmentPath => _setBiometricEnrollment,
      sendBiometricMatchPath => _sendBiometricMatch,
      _ => null,
    };
    if (request.method != 'POST' || handler == null) {
      response.statusCode = HttpStatus.notFound;
      await response.close();
      return;
    }

    try {
      final body = jsonDecode(await utf8.decodeStream(request));
      final result = await handler(body);
      response.write(jsonEncode(result));
    } on Exception catch (err) {
      _logger.detail('$path failed: $err');

      response
        ..statusCode = HttpStatus.internalServerError
        ..write('$err');
    }

    await response.close();
  }

  Future<Map<String, Object?>> _setHingeAngle(Object? body) async {
    final degrees = switch (body) {
      {'degrees': final num degrees} => degrees.toDouble(),
      _ => throw FormatException('Expected {"degrees": <number>}', body),
    };

    final previousDegrees = _hinge.angle;
    await _hinge.setAngle(degrees);

    return {'previousDegrees': previousDegrees};
  }

  Future<Map<String, Object?>> _setBiometricEnrollment(Object? body) async {
    final enrolled = switch (body) {
      {'enrolled': final bool enrolled} => enrolled,
      _ => throw FormatException('Expected {"enrolled": <bool>}', body),
    };

    await _biometrics.setEnrolled(enrolled);

    return {};
  }

  Future<Map<String, Object?>> _sendBiometricMatch(Object? body) async {
    final match = switch (body) {
      {'match': final bool match} => match,
      _ => throw FormatException('Expected {"match": <bool>}', body),
    };

    await _biometrics.sendMatch(match);

    return {};
  }

  Future<void> close() async {
    await _server.close(force: true);
    await _hinge.close();
    try {
      await _biometrics.restore();
    } on Exception catch (err) {
      _logger.detail('Failed to restore biometric enrollment: $err');
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/ios/ios_host_server.dart';
import 'package:patrol_cli/src/ios/simulator_biometrics.dart';
import 'package:patrol_cli/src/ios/simulator_hinge.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  group('IOSHostServer', () {
    late MockSimulatorHinge hinge;
    late MockSimulatorBiometrics biometrics;
    late IOSHostServer server;
    late HttpClient client;

    setUp(() async {
      hinge = MockSimulatorHinge();
      when(() => hinge.setAngle(any())).thenAnswer((_) async {});
      when(hinge.close).thenAnswer((_) async {});
      biometrics = MockSimulatorBiometrics();
      when(() => biometrics.setEnrolled(any())).thenAnswer((_) async {});
      when(() => biometrics.sendMatch(any())).thenAnswer((_) async {});
      server = await IOSHostServer.start(
        hinge: hinge,
        biometrics: biometrics,
        logger: MockLogger(),
      );
      client = HttpClient();
    });

    tearDown(() async {
      client.close();
      await server.close();
    });

    Future<HttpClientResponse> post(String path, Object body) async {
      final request = await client.post('127.0.0.1', server.port, path)
        ..write(jsonEncode(body));

      return request.close();
    }

    test('sets the hinge angle', () async {
      final response = await post('/setHingeAngle', {'degrees': 130});

      expect(response.statusCode, HttpStatus.ok);
      expect(jsonDecode(await utf8.decodeStream(response)), {
        'previousDegrees': null,
      });
      verify(() => hinge.setAngle(130)).called(1);
    });

    test('responds with the angle the hinge was at before', () async {
      when(() => hinge.angle).thenReturn(180);

      final response = await post('/setHingeAngle', {'degrees': 0});

      expect(jsonDecode(await utf8.decodeStream(response)), {
        'previousDegrees': 180,
      });
    });

    test('responds with the error when the hinge fails', () async {
      when(
        () => hinge.setAngle(any()),
      ).thenThrow(const SimulatorHingeException('Simulator is not booted'));

      final response = await post('/setHingeAngle', {'degrees': 0});

      expect(response.statusCode, HttpStatus.internalServerError);
      expect(
        await utf8.decodeStream(response),
        contains('Simulator is not booted'),
      );
    });

    test('rejects a body without degrees', () async {
      final response = await post('/setHingeAngle', {'angle': 90});

      expect(response.statusCode, HttpStatus.internalServerError);
      verifyNever(() => hinge.setAngle(any()));
    });

    test('sets the biometric enrollment', () async {
      final response = await post('/setBiometricEnrollment', {
        'enrolled': true,
      });

      expect(response.statusCode, HttpStatus.ok);
      verify(() => biometrics.setEnrolled(true)).called(1);
    });

    test('sends a biometric non-match', () async {
      final response = await post('/sendBiometricMatch', {'match': false});

      expect(response.statusCode, HttpStatus.ok);
      verify(() => biometrics.sendMatch(false)).called(1);
    });

    test('responds with the error when biometrics fail', () async {
      when(() => biometrics.sendMatch(any())).thenThrow(
        const SimulatorBiometricsException('Simulator is not booted'),
      );

      final response = await post('/sendBiometricMatch', {'match': true});

      expect(response.statusCode, HttpStatus.internalServerError);
      expect(
        await utf8.decodeStream(response),
        contains('Simulator is not booted'),
      );
    });

    test('rejects a biometric match body without match', () async {
      final response = await post('/sendBiometricMatch', {'matches': true});

      expect(response.statusCode, HttpStatus.internalServerError);
      verifyNever(() => biometrics.sendMatch(any()));
    });

    test('responds with 404 to an unknown path', () async {
      final response = await post('/fold', {'degrees': 0});

      expect(response.statusCode, HttpStatus.notFound);
    });
  });
}

class MockSimulatorHinge extends Mock implements SimulatorHinge {}

class MockSimulatorBiometrics extends Mock implements SimulatorBiometrics {}

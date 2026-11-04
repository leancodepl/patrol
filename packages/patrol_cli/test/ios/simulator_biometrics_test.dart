import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/ios/simulator_biometrics.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  group('SimulatorBiometrics', () {
    late MockProcessManager processManager;
    late SimulatorBiometrics biometrics;
    late List<List<String>> commands;

    setUp(() {
      processManager = MockProcessManager();
      commands = [];
      when(() => processManager.run(any())).thenAnswer((invocation) async {
        commands.add(
          (invocation.positionalArguments.first as List<Object>).cast(),
        );
        return ProcessResult(0, 0, '', '');
      });
      biometrics = SimulatorBiometrics(
        deviceId: 'SIM-ID',
        processManager: processManager,
        logger: MockLogger(),
      );
    });

    const notifyutil = ['xcrun', 'simctl', 'spawn', 'SIM-ID', 'notifyutil'];

    test('enrolls by setting and posting the enrollment state', () async {
      await biometrics.setEnrolled(true);

      expect(commands, [
        [...notifyutil, '-s', 'com.apple.BiometricKit.enrollmentChanged', '1'],
        [...notifyutil, '-p', 'com.apple.BiometricKit.enrollmentChanged'],
      ]);
    });

    test('unenrolls by clearing the enrollment state', () async {
      await biometrics.setEnrolled(false);

      expect(commands.first.last, '0');
    });

    test('sends a match to Face ID and Touch ID', () async {
      await biometrics.sendMatch(true);

      expect(commands, [
        [...notifyutil, '-p', 'com.apple.BiometricKit_Sim.pearl.match'],
        [...notifyutil, '-p', 'com.apple.BiometricKit_Sim.fingerTouch.match'],
      ]);
    });

    test('sends a non-match to Face ID and Touch ID', () async {
      await biometrics.sendMatch(false);

      expect(commands, [
        [...notifyutil, '-p', 'com.apple.BiometricKit_Sim.pearl.nomatch'],
        [...notifyutil, '-p', 'com.apple.BiometricKit_Sim.fingerTouch.nomatch'],
      ]);
    });

    test('throws when simctl fails', () {
      when(() => processManager.run(any())).thenAnswer(
        (_) async => ProcessResult(0, 1, '', 'No devices are booted.'),
      );

      return expectLater(
        biometrics.sendMatch(true),
        throwsA(isA<SimulatorBiometricsException>()),
      );
    });
  });
}

import 'dart:io' show ProcessResult;

import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/android/adb_commands.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  group('adb commands', () {
    late MockProcessManager processManager;

    setUp(() {
      processManager = MockProcessManager();
      when(
        () => processManager.run(any(), runInShell: any(named: 'runInShell')),
      ).thenAnswer((_) async => ProcessResult(0, 0, '', ''));
    });

    test('adbPull builds `adb -s <id> pull <src> <dst>`', () async {
      await adbPull(
        processManager,
        source: '/sdcard/Download/screenshots',
        destination: 'out',
        deviceId: 'emulator-5554',
      );

      verify(
        () => processManager.run([
          'adb',
          '-s',
          'emulator-5554',
          'pull',
          '/sdcard/Download/screenshots',
          'out',
        ], runInShell: true),
      ).called(1);
    });

    test(
      'adbRemove without recursive builds `rm <path>` (video case)',
      () async {
        await adbRemove(processManager, path: '/sdcard/x.mp4', deviceId: 'd1');

        verify(
          () => processManager.run([
            'adb',
            '-s',
            'd1',
            'shell',
            'rm',
            '/sdcard/x.mp4',
          ], runInShell: true),
        ).called(1);
      },
    );

    test('adbRemove with recursive builds `rm -rf <path>`', () async {
      await adbRemove(
        processManager,
        path: '/sdcard/Download/screenshots',
        deviceId: 'd1',
        recursive: true,
      );

      verify(
        () => processManager.run([
          'adb',
          '-s',
          'd1',
          'shell',
          'rm',
          '-rf',
          '/sdcard/Download/screenshots',
        ], runInShell: true),
      ).called(1);
    });

    test('omits `-s` when deviceId is empty', () async {
      await adbPull(
        processManager,
        source: 'a',
        destination: 'b',
        deviceId: '',
      );

      verify(
        () => processManager.run(['adb', 'pull', 'a', 'b'], runInShell: true),
      ).called(1);
    });
  });
}

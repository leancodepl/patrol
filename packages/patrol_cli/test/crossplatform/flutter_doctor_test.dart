import 'dart:async';
import 'dart:convert';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/crossplatform/flutter_doctor.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  group('FlutterDoctor', () {
    const command = FlutterCommand('fvm', ['flutter']);
    late MockProcessManager processManager;
    late MockProcess process;
    late DisposeScope disposeScope;
    late StreamController<List<int>> doctorStdout;
    late FlutterDoctor flutterDoctor;

    void printLine(String line) => doctorStdout.add(utf8.encode('$line\n'));

    setUp(() {
      processManager = MockProcessManager();
      doctorStdout = StreamController<List<int>>();
      process = MockProcess();
      when(() => process.stdout).thenAnswer((_) => doctorStdout.stream);
      when(() => process.kill()).thenReturn(true);
      when(() => process.stderr).thenAnswer((_) => const Stream.empty());
      when(
        () => processManager.start(
          any(),
          workingDirectory: any(named: 'workingDirectory'),
          runInShell: any(named: 'runInShell'),
        ),
      ).thenAnswer((_) async => process);
      disposeScope = DisposeScope();
      flutterDoctor = FlutterDoctor(
        processManager: processManager,
        projectRoot: MemoryFileSystem.test().directory('/project'),
        parentDisposeScope: disposeScope,
      );
    });

    tearDown(() => doctorStdout.close());

    test('finds a line before the doctor finishes', () async {
      final javaBinary = flutterDoctor.firstLineWhere(
        command,
        (line) => line.contains('Java binary at'),
      );
      printLine('[!] Android toolchain');
      printLine('    • Java binary at: /opt/jdk/bin/java');

      expect(await javaBinary, '    • Java binary at: /opt/jdk/bin/java');
    });

    test('starts flutter doctor once for several lookups', () async {
      final javaBinary = flutterDoctor.firstLineWhere(
        command,
        (line) => line.contains('Java binary at'),
      );
      printLine('    • Java binary at: /opt/jdk/bin/java');
      await javaBinary;
      final javaVersion = flutterDoctor.firstLineWhere(
        command,
        (line) => line.contains('Java version'),
      );
      printLine(
        '    • Java version OpenJDK Runtime Environment (build 21.0.8)',
      );

      expect(
        await javaVersion,
        '    • Java version OpenJDK Runtime Environment (build 21.0.8)',
      );
      verify(
        () => processManager.start(
          ['fvm', 'flutter', 'doctor', '--verbose'],
          workingDirectory: '/project',
          runInShell: true,
        ),
      ).called(1);
    });

    test('returns null when the doctor finishes without the line', () async {
      final javaBinary = flutterDoctor.firstLineWhere(
        command,
        (line) => line.contains('Java binary at'),
      );
      printLine('[✗] Android toolchain - develop for Android devices');
      await doctorStdout.close();

      expect(await javaBinary, isNull);
    });

    test('kills a running doctor when its owner is disposed', () async {
      final javaBinary = flutterDoctor.firstLineWhere(
        command,
        (line) => line.contains('Java binary at'),
      );
      printLine('[✓] Flutter (Channel stable)');
      await pumpEventQueue();

      await disposeScope.dispose();

      expect(await javaBinary, isNull);
      verify(() => process.kill()).called(1);
    });
  });
}

import 'dart:async';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/crossplatform/flutter_tool.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  const flutterCommand = FlutterCommand('flutter');

  late FlutterTool flutterTool;
  late MockProcessManager processManager;
  late Platform platform;

  setUp(() {
    final disposeScope = DisposeScope();
    final stdin = StreamController<List<int>>();
    processManager = MockProcessManager();
    platform = FakePlatform();

    flutterTool = FlutterTool(
      logger: MockLogger(),
      parentDisposeScope: disposeScope,
      processManager: processManager,
      platform: platform,
      stdin: stdin.stream,
    );
  });

  group(
    'FlutterTool',
    () {
      test(
        'attach passes deviceId correctly',
        () {
          final process = MockProcess();
          when(() => process.stdout)
              .thenAnswer((_) => Stream<List<int>>.fromIterable([]));
          when(() => process.stderr)
              .thenAnswer((_) => Stream<List<int>>.fromIterable([]));
          when(() => processManager.start(any()))
              .thenAnswer((_) async => process);

          flutterTool.attach(
            flutterCommand: flutterCommand,
            deviceId: 'testDeviceId',
            target: 'target',
            appId: 'appId',
            dartDefines: {},
            openBrowser: false,
          );

          verify(
            () => processManager.start(any(that: contains('testDeviceId'))),
          );
        },
      );
    },
  );
}

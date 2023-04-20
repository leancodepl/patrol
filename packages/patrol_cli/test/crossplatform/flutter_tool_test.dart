import 'dart:async';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/crossplatform/flutter_tool.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  late FlutterTool flutterTool;
  late MockProcessManager processManager;

  setUp(() {
    final disposeScope = DisposeScope();
    final stdin = StreamController<List<int>>();
    processManager = MockProcessManager();

    flutterTool = FlutterTool(
      logger: MockLogger(),
      parentDisposeScope: disposeScope,
      processManager: processManager,
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
            deviceId: 'testDeviceId',
            target: 'target',
            appId: 'appId',
            dartDefines: {},
          );

          verify(
            () => processManager.start(any(that: contains('testDeviceId'))),
          );
        },
      );
    },
  );
}

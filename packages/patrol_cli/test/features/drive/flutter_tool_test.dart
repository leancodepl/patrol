import 'package:dispose_scope/dispose_scope.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/features/drive/flutter_tool.dart';
import 'package:test/test.dart';

import '../../fixtures.dart';
import '../../mocks.dart';

void main() {
  late Logger logger;
  late DisposeScope disposeScope;
  late FlutterTool flutterTool;

  group('FlutterTool', () {
    setUp(() {
      logger = MockLogger();
      disposeScope = DisposeScope();

      flutterTool = FlutterTool(
        parentDisposeScope: disposeScope,
        logger: logger,
      )..init(
          driver: 'test_driver/integration_test.dart',
          host: 'localhost',
          port: '8081',
          flavor: null,
          dartDefines: const {},
        );
    });

    test('build', () async {
      when(() => logger.err(any()))
          .thenAnswer((_) => print('invo: ${_.positionalArguments}'));

      when(() => logger.detail(any()))
          .thenAnswer((_) => print('invo: ${_.positionalArguments}'));

      await flutterTool.build('integration_test/app_test.dart', androidDevice);

      verify(
        () => logger.info(
          '${green.wrap(">")} Building apk for emulator-5554...',
        ),
      ).called(1);
    });
  });
}

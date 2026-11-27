import 'package:file/memory.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/dashboard/dashboard_config.dart';
import 'package:patrol_cli/src/dashboard/dashboard_reporter.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:test/test.dart';

void main() {
  late MemoryFileSystem fileSystem;
  late Logger logger;

  setUp(() {
    fileSystem = MemoryFileSystem.test();
    fileSystem.directory('/project').createSync(recursive: true);
    logger = Logger(level: Level.quiet);
  });

  DashboardReporter reporter({String outputPath = 'reports/report.html'}) =>
      DashboardReporter.maybe(
        rootDirectory: fileSystem.directory('/project'),
        logger: logger,
        config: DashboardConfig(
          enabled: true,
          outputPath: outputPath,
          testDirectory: 'integration_test',
        ),
      )!;

  const device = Device(
    name: 'Pixel 9',
    id: 'emulator-5554',
    targetPlatform: TargetPlatform.android,
    real: false,
  );

  group('DashboardReporter', () {
    test('writes the report under the root directory, creating its parent', () {
      final sut = reporter();
      sut.wrapOnLogEntry(null)(
        TestEntry(name: 'app_test signs in', status: TestEntryStatus.skip),
      );

      sut.writeAndLog(platform: 'Android', device: device, buildMode: 'debug');

      final file = fileSystem.file('/project/reports/report.html');
      expect(file.existsSync(), isTrue);
      final html = file.readAsStringSync();
      expect(html, contains('signs in'));
      expect(html, contains('Pixel 9'));
    });

    test('builds no reporter when the report is not asked for', () {
      DashboardReporter? build(DashboardConfig? config) =>
          DashboardReporter.maybe(
            rootDirectory: fileSystem.directory('/project'),
            logger: logger,
            config: config,
          );

      expect(build(null), isNull);
      expect(
        build(const DashboardConfig(enabled: false, outputPath: 'r.html')),
        isNull,
      );
      expect(
        build(const DashboardConfig(enabled: true, outputPath: 'r.html')),
        isNotNull,
      );
    });

    test('honors an absolute output path', () {
      reporter(
        outputPath: '/somewhere/else/patrol.html',
      ).writeAndLog(platform: 'iOS', device: device, buildMode: 'release');

      expect(fileSystem.file('/somewhere/else/patrol.html').existsSync(), true);
    });

    test('forwards log entries to the wrapped callback', () {
      final seen = <Entry>[];
      final entry = TestEntry(
        name: 'app_test signs in',
        status: TestEntryStatus.skip,
      );

      reporter().wrapOnLogEntry(seen.add)(entry);

      expect(seen, [entry]);
    });

    test('reports a write failure as a warning instead of throwing', () {
      // A directory in place of the report file makes the write fail.
      fileSystem
          .directory('/project/reports/report.html')
          .createSync(recursive: true);

      expect(
        () => reporter().writeAndLog(
          platform: 'Android',
          device: device,
          buildMode: 'debug',
        ),
        returnsNormally,
      );
    });
  });
}

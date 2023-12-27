import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

void main() {
  group('BuildMode', () {
    test('infers build options in debug mode when flavor is null', () {
      const buildMode = BuildMode.debug;
      String? flavor;

      expect(buildMode.createConfiguration(flavor), 'Debug');
      expect(buildMode.createScheme(flavor), 'Runner');
    });

    test('infers build options in debug mode when flavor is not null', () {
      const buildMode = BuildMode.debug;
      const flavor = 'dev';

      expect(buildMode.createConfiguration(flavor), 'Debug-dev');
      expect(buildMode.createScheme(flavor), 'dev');
    });

    test('infers build options in release mode when flavor is null', () {
      const buildMode = BuildMode.release;
      String? flavor;

      expect(buildMode.createConfiguration(flavor), 'Release');
      expect(buildMode.createScheme(flavor), 'Runner');
    });

    test('infers build options in release mode when flavor is not null', () {
      const buildMode = BuildMode.release;
      const flavor = 'prod';

      expect(buildMode.createConfiguration(flavor), 'Release-prod');
      expect(buildMode.createScheme(flavor), 'prod');
    });
  });

  group('IOSTestBackend', () {
    late IOSTestBackend iosTestBackend;
    late FileSystem fs;

    setUp(() {
      fs = MemoryFileSystem.test();
      fs.directory('example_app').createSync();
      fs.currentDirectory = 'example_app';

      iosTestBackend = IOSTestBackend(
        processManager: FakeProcessManager(),
        platform: FakePlatform(),
        fs: fs,
        parentDisposeScope: DisposeScope(),
        logger: FakeLogger(),
      );
    });

    group('xcTestRunPath', () {
      @isTest
      void testXcTestRunPath(
        String description, {
        String scheme = 'Runner',
        bool simulator = false,
        String? arch,
        String? testPlan,
      }) {
        test(description, () async {
          final target = simulator ? 'iphonesimulator' : 'iphoneos';
          if (arch != null) {
            arch = '-$arch';
          }

          final xcTestPlan = testPlan != null ? '-$testPlan' : '';

          final name = '${scheme}_$xcTestPlan${target}16.2$arch.xctestrun';

          fs
              .file('build/ios_integ/Build/Products/$name')
              .createSync(recursive: true);

          final found = await iosTestBackend.xcTestRunPath(
            real: !simulator,
            scheme: scheme,
            sdkVersion: '16.2',
          );

          expect(
            found,
            '/example_app/build/ios_integ/Build/Products/$name',
          );
        });
      }

      testXcTestRunPath(
        'finds xctestrun with no arch on iphoneos',
      );

      testXcTestRunPath(
        'finds xctestrun with single arch on iphoneos',
        arch: 'arm64',
      );

      testXcTestRunPath(
        'finds xctestrun with single arch on iphoneos (test plan)',
        arch: 'arm64',
        testPlan: 'TestPlan',
      );

      testXcTestRunPath(
        'finds xctestrun with double arch on iphoneos',
        arch: 'arm64-x86_64',
      );

      testXcTestRunPath(
        'finds xctestrun with no arch and custom scheme on iphoneos',
        scheme: 'dev',
      );

      testXcTestRunPath(
        'finds xctestrun with single arch and custom scheme on iphoneos',
        arch: 'arm64',
        scheme: 'dev',
      );

      testXcTestRunPath(
        'finds xctestrun with double arch and custom scheme on iphoneos',
        arch: 'arm64-x86_64',
        scheme: 'dev',
      );

      testXcTestRunPath(
        'finds xctestrun with no arch on iphonesimulator',
        simulator: true,
      );

      testXcTestRunPath(
        'finds xctestrun with single arch on iphonesimulator',
        arch: 'arm64',
        simulator: true,
      );

      testXcTestRunPath(
        'finds xctestrun with double arch on iphonesimulator',
        arch: 'arm64-x86_64',
        simulator: true,
      );

      testXcTestRunPath(
        'finds xctestrun with no arch and custom scheme on iphonesimulator',
        simulator: true,
        scheme: 'dev',
      );

      testXcTestRunPath(
        'finds xctestrun with single arch and custom scheme on iphonesimulator',
        arch: 'arm64',
        simulator: true,
        scheme: 'dev',
      );

      testXcTestRunPath(
        'finds xctestrun with double arch and custom scheme on iphonesimulator',
        arch: 'arm64-x86_64',
        simulator: true,
        scheme: 'dev',
      );

      testXcTestRunPath(
        'finds xctestrun with double arch and custom scheme on iphonesimulator (test plan)',
        arch: 'arm64-x86_64',
        simulator: true,
        scheme: 'dev',
        testPlan: 'SomeTestPlan',
      );
    });

    group('stripFlavorFromAppId', () {
      test('simply returns appId when flavor is null', () {
        const appId = 'com.company.app';
        const String? flavor = null;

        expect(
          iosTestBackend.stripFlavorFromAppId(appId, flavor),
          'com.company.app',
        );
      });

      test('works when appId contains flavor', () {
        const appId = 'com.company.app.dev';
        const flavor = 'dev';

        expect(
          iosTestBackend.stripFlavorFromAppId(appId, flavor),
          'com.company.app',
        );
      });

      test('ignores when appId contains flavor not preceded by a dot', () {
        const appId = 'com.company.app_dev';
        const flavor = 'dev';

        expect(
          iosTestBackend.stripFlavorFromAppId(appId, flavor),
          'com.company.app_dev',
        );
      });
    });
  });
}

class FakeProcessManager extends Fake implements ProcessManager {}

class FakeLogger extends Fake implements Logger {
  @override
  void detail(String? message, {String? Function(String?)? style}) {}
}

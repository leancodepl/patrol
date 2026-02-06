import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
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
        rootDirectory: fs.currentDirectory,
        parentDisposeScope: DisposeScope(),
        logger: FakeLogger(),
      );
    });

    group('xcTestRunPath', () {
      test('finds xctestrun for iphoneos (real device)', () {
        fs
            .file(
              'build/ios_integ/Build/Products/Runner_TestPlan_iphoneos16.2-arm64.xctestrun',
            )
            .createSync(recursive: true);

        final path = iosTestBackend.xcTestRunPath(
          real: true,
          scheme: 'Runner',
          sdkVersion: '16.2',
        );

        expect(
          path,
          '/example_app/build/ios_integ/Build/Products/Runner_TestPlan_iphoneos16.2-arm64.xctestrun',
        );
      });

      test('finds xctestrun for iphonesimulator', () {
        fs
            .file(
              'build/ios_integ/Build/Products/Runner_CustomPlan_iphonesimulator16.2-arm64-x86_64.xctestrun',
            )
            .createSync(recursive: true);

        final path = iosTestBackend.xcTestRunPath(
          real: false,
          scheme: 'Runner',
          sdkVersion: '16.2',
        );

        expect(
          path,
          '/example_app/build/ios_integ/Build/Products/Runner_CustomPlan_iphonesimulator16.2-arm64-x86_64.xctestrun',
        );
      });

      test('finds xctestrun with custom scheme for iphoneos', () {
        fs
            .file(
              'build/ios_integ/Build/Products/dev_AnotherTestPlan_iphoneos17.0-arm64.xctestrun',
            )
            .createSync(recursive: true);

        final path = iosTestBackend.xcTestRunPath(
          real: true,
          scheme: 'dev',
          sdkVersion: '17.0',
        );

        expect(
          path,
          '/example_app/build/ios_integ/Build/Products/dev_AnotherTestPlan_iphoneos17.0-arm64.xctestrun',
        );
      });

      test('finds xctestrun with custom scheme for iphonesimulator', () {
        fs
            .file(
              'build/ios_integ/Build/Products/prod_MyTestPlan_iphonesimulator26.1-arm64-x86_64.xctestrun',
            )
            .createSync(recursive: true);

        final path = iosTestBackend.xcTestRunPath(
          real: false,
          scheme: 'prod',
          sdkVersion: '26.1',
        );

        expect(
          path,
          '/example_app/build/ios_integ/Build/Products/prod_MyTestPlan_iphonesimulator26.1-arm64-x86_64.xctestrun',
        );
      });

      test('returns relative path when absolutePath is false', () {
        fs
            .file(
              'build/ios_integ/Build/Products/Runner_TestPlan_iphoneos16.2-arm64.xctestrun',
            )
            .createSync(recursive: true);

        final path = iosTestBackend.xcTestRunPath(
          real: true,
          scheme: 'Runner',
          sdkVersion: '16.2',
          absolutePath: false,
        );

        expect(
          path,
          'build/ios_integ/Build/Products/Runner_TestPlan_iphoneos16.2-arm64.xctestrun',
        );
      });

      test('throws when xctestrun file not found', () {
        fs
            .directory('build/ios_integ/Build/Products')
            .createSync(recursive: true);

        expect(
          () => iosTestBackend.xcTestRunPath(
            real: true,
            scheme: 'Runner',
            sdkVersion: '16.2',
          ),
          throwsA(isA<FileSystemException>()),
        );
      });
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

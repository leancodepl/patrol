import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/extensions/platform.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

import '../src/common.dart';

void main() {
  _testBuildMode();

  _testIOSTestBackend(initFakePlatform(Platform.macOS));
  _testIOSTestBackend(initFakePlatform(Platform.windows));
}

void _testBuildMode() {
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
}

void _testIOSTestBackend(Platform platform) {
  group('(${platform.operatingSystem}) IOSTestBackend', () {
    late IOSTestBackend iosTestBackend;
    late FileSystem fs;

    group('xcTestRunPath', () {
      setUp(() {
        fs = MemoryFileSystem.test(style: platform.fileSystemStyle);
        final wd = fs.directory(fs.path.join('projects', 'awesome_app'))
          ..createSync(recursive: true);
        fs.currentDirectory = wd;

        iosTestBackend = IOSTestBackend(
          processManager: FakeProcessManager(),
          fs: fs,
          parentDisposeScope: DisposeScope(),
          logger: FakeLogger(),
        );
      });

      @isTest
      void testXcTestRunPath(
        String description, {
        String scheme = 'Runner',
        bool simulator = false,
        String? arch,
      }) {
        test(description, () async {
          final wd = fs.currentDirectory.absolute.path;

          final targetPlatform = simulator ? 'iphonesimulator' : 'iphoneos';
          var targetArch = arch;
          if (targetArch != null) {
            targetArch = '-$targetArch';
          }

          final name = '${scheme}_${targetPlatform}16.2$targetArch.xctestrun';

          final pth =
              fs.path.join(wd, 'build', 'ios_integ', 'Build', 'Products', name);
          fs
              .file(
                pth,
              )
              .createSync(recursive: true);
          print('created file at $pth');

          final found = await iosTestBackend.xcTestRunPath(
            real: !simulator,
            scheme: scheme,
            sdkVersion: '16.2',
          );

          expect(
            found,
            fs.path.join(wd, 'build', 'ios_integ', 'Build', 'Products', name),
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
    });
  });
}

class FakeProcessManager extends Fake implements ProcessManager {}

class FakeLogger extends Fake implements Logger {
  @override
  void detail(String? message) {
    print(message);
  }
}

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' show join;
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/ios/ios_deploy.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
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
        fs: fs,
        iosDeploy: FakeIOSDeploy(),
        parentDisposeScope: DisposeScope(),
        logger: FakeLogger(),
      );
    });

    test('finds xctestrun with no arch', () async {
      const name = 'Runner_iphoneos16.2.xctestrun';

      fs
          .file(join('build', 'ios_integ', 'Build', 'Products', name))
          .createSync(recursive: true);

      final found = await iosTestBackend.xcTestRunPath(
        real: true,
        scheme: 'Runner',
        sdkVersion: '16.2',
      );
      expect(found, '/example_app/build/ios_integ/Build/Products/$name');
    });

    test('finds xctestrun with single arch', () async {
      const name = 'Runner_iphoneos16.2-arm64.xctestrun';

      fs
          .file(join('build', 'ios_integ', 'Build', 'Products', name))
          .createSync(recursive: true);

      final found = await iosTestBackend.xcTestRunPath(
        real: true,
        scheme: 'Runner',
        sdkVersion: '16.2',
      );
      expect(found, '/example_app/build/ios_integ/Build/Products/$name');
    });
  });
}

class FakeProcessManager extends Fake implements ProcessManager {}

class FakeIOSDeploy extends Fake implements IOSDeploy {}

class FakeLogger extends Fake implements Logger {
  @override
  void detail(String? message) {}
}

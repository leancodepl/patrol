import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:path/path.dart' as path;
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

extension PlatformX on Platform {
  path.Style get pathStyle => operatingSystem == Platform.windows
      ? path.Style.windows
      : path.Style.posix;

  FileSystemStyle get fileSystemStyle {
    return isWindows ? FileSystemStyle.windows : FileSystemStyle.posix;
  }

  String get home {
    final envVars = environment;
    if (isMacOS) {
      return envVars['HOME']!;
    } else if (isLinux) {
      return envVars['HOME']!;
    } else if (isWindows) {
      return envVars['UserProfile']!;
    } else {
      throw StateError('Unsupported platform: $operatingSystem');
    }
  }
}

Platform _initFakePlatform(String platform) {
  switch (platform) {
    case 'macos':
      return FakePlatform(
        operatingSystem: Platform.macOS,
        environment: {'HOME': '/home/charlie'},
      );
    case 'linux':
      return FakePlatform(
        operatingSystem: Platform.linux,
        environment: {'HOME': '/home/charlie'},
      );
    case 'windows':
      return FakePlatform(
        operatingSystem: Platform.windows,
        environment: {'UserProfile': r'C:\Users\charlie'},
      );
    default:
      throw StateError('Unsupported platform: $platform');
  }
}

Directory _initFakeFs(FileSystem fs, Platform platform) {
  final pathContext = path.Context(style: platform.pathStyle);

  // Create home directory
  fs.directory(pathContext.join(platform.home)).createSync();
  fs.currentDirectory = platform.home;

  final projectRootDir = fs
      .directory(pathContext.join(platform.home, 'awesome_app'))
    ..createSync();
  fs.currentDirectory = projectRootDir;
  fs.directory('integration_test').createSync();
  return projectRootDir;
}

void main() {
  _test(_initFakePlatform(Platform.macOS));
  _test(_initFakePlatform(Platform.windows));
}

void _test(Platform platform) {
  final pathContext = path.Context(style: platform.pathStyle);

  group('(${platform.operatingSystem}) TestBundler', () {
    late TestBundler testBundler;

    setUp(() {
      final fs = MemoryFileSystem.test(style: platform.fileSystemStyle);
      final projectRootDir = _initFakeFs(fs, platform);
      testBundler = TestBundler(projectRoot: projectRootDir);
    });

    test('throws ArgumentError when no tests are given', () {
      expect(() => testBundler.createBundledTest([]), throwsArgumentError);
    });

    test('generates imports from relative paths', () {
      // given
      final tests = [
        pathContext.join('integration_test', 'example_test.dart'),
        pathContext.join('integration_test', 'example', 'example_test.dart'),
      ];

      // when
      final imports = testBundler.generateImports(tests);

      /// then
      expect(imports, '''
import 'example_test.dart' as example_test;
import 'example/example_test.dart' as example__example_test;
''');
    });

    test('generates imports from absolute paths', () {
      // given
      final tests = [
        pathContext.join(
          platform.home,
          'awesome_app',
          'integration_test',
          'example_test.dart',
        ),
        pathContext.join(
          platform.home,
          'awesome_app',
          'integration_test',
          'example/example_test.dart',
        ),
      ];

      // when
      final imports = testBundler.generateImports(tests);

      /// then
      expect(imports, '''
import 'example_test.dart' as example_test;
import 'example/example_test.dart' as example__example_test;
''');
    });

    test('generates groups from relative paths', () {
      // given
      final tests = [
        pathContext.join('integration_test', 'example_test.dart'),
        pathContext.join('integration_test', 'example/example_test.dart'),
      ];

      // when
      final groupsCode = testBundler.generateGroupsCode(tests);

      /// then
      expect(groupsCode, '''
group('example_test', example_test.main);
group('example.example_test', example__example_test.main);
''');
    });

    test('generates groups from absolute paths', () {
      // given
      final tests = [
        pathContext.join(
          platform.home,
          'awesome_app',
          'integration_test',
          'example_test.dart',
        ),
        pathContext.join(
          platform.home,
          'awesome_app',
          'integration_test',
          'example/example_test.dart',
        ),
      ];

      // when
      final groupsCode = testBundler.generateGroupsCode(tests);

      /// then
      expect(groupsCode, '''
group('example_test', example_test.main);
group('example.example_test', example__example_test.main);
''');
    });
  });
}

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:path/path.dart' as path;
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/constants.dart' show version;
import 'package:platform/platform.dart';
import 'package:test/test.dart';

final _macosPlatform = FakePlatform(
  pathSeparator: '/',
  operatingSystem: 'macos',
  environment: {
    'HOME': path.Context(style: path.Style.posix).join('/home', 'johndoe'),
  },
);

final _linuxPlatform = FakePlatform(
  pathSeparator: '/',
  operatingSystem: 'linux',
  environment: {
    'HOME': path.Context(style: path.Style.posix).join('/home', 'johndoe'),
  },
);

final _windowsPlatform = FakePlatform(
  pathSeparator: r'\',
  operatingSystem: 'windows',
  environment: {
    'HOME': path.Context(style: path.Style.posix).join('/home', 'johndoe'),
  },
);

const _cachePath = '/home/johndoe/.cache/patrol';

void main() {
  group('ArtifactsRepository', () {
    late FileSystem fs;
    late Platform platform;

    late ArtifactsRepository artifactsRepository;

    setUp(() {
      fs = MemoryFileSystem.test();
      final wd = fs.directory('/home/johndoe/projects/awesome_app')
        ..createSync(recursive: true);
      fs.currentDirectory = wd;

      platform = _linuxPlatform;

      artifactsRepository = ArtifactsRepository(fs: fs, platform: platform);
    });

    group('paths', () {
      test('are correct for release artifacts', () {
        expect(
          artifactsRepository.serverArtifactPath,
          equals('/home/johndoe/.cache/patrol/server-$version.apk'),
        );

        expect(
          artifactsRepository.instrumentationArtifactPath,
          equals('/home/johndoe/.cache/patrol/instrumentation-$version.apk'),
        );

        expect(
          artifactsRepository.iosArtifactDirPath,
          equals('/home/johndoe/.cache/patrol/ios-$version'),
        );
      });

      test('are correct for debug artifacts', () {
        artifactsRepository.debug = true;

        expect(
          artifactsRepository.serverArtifactPath,
          equals('/home/johndoe/.cache/patrol/server.apk'),
        );

        expect(
          artifactsRepository.instrumentationArtifactPath,
          equals('/home/johndoe/.cache/patrol/instrumentation.apk'),
        );

        expect(
          artifactsRepository.iosArtifactDirPath,
          equals('/home/johndoe/.cache/patrol/ios'),
        );
      });
    });

    group('areArtifactsPresent on Linux', () {
      test('returns false when artifacts are not present', () {
        expect(artifactsRepository.areArtifactsPresent(), equals(false));
      });

      test('returns false when only server.apk exists', () {
        fs
            .file('/home/johndoe/.cache/patrol/server-$version.apk')
            .createSync(recursive: true);

        expect(artifactsRepository.areArtifactsPresent(), equals(false));
      });

      test('returns false when only instrumentation.apk exists', () {
        fs
            .file('/home/johndoe/.cache/patrol/instrumentation-$version.apk')
            .createSync(recursive: true);

        expect(artifactsRepository.areArtifactsPresent(), equals(false));
      });

      test('returns true when server.apk and instrumentation.apk exist', () {
        fs
            .file('/home/johndoe/.cache/patrol/server-$version.apk')
            .createSync(recursive: true);
        fs
            .file('/home/johndoe/.cache/patrol/instrumentation-$version.apk')
            .createSync();

        expect(artifactsRepository.areArtifactsPresent(), equals(true));
      });
    });

    group('areArtifactsPresent on macOS', () {
      setUp(() {
        artifactsRepository = ArtifactsRepository(
          fs: fs,
          platform: _macosPlatform,
        );
      });

      test('returns false when only Android artifacts exist', () {
        fs
            .file('/home/johndoe/.cache/patrol/server-$version.apk')
            .createSync(recursive: true);
        fs
            .file('/home/johndoe/.cache/patrol/instrumentation-$version.apk')
            .createSync();

        expect(artifactsRepository.areArtifactsPresent(), equals(false));
      });

      test('returns true when Android and iOS artifacts exist', () {
        fs
            .file('/home/johndoe/.cache/patrol/server-$version.apk')
            .createSync(recursive: true);
        fs
            .file('/home/johndoe/.cache/patrol/instrumentation-$version.apk')
            .createSync();
        fs.directory('/home/johndoe/.cache/patrol/ios-$version').createSync();

        expect(artifactsRepository.areArtifactsPresent(), equals(true));
      });
    });
  
  
    });
}

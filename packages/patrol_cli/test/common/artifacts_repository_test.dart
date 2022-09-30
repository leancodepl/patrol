import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' show join;
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/constants.dart' show version;
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import '../fakes.dart';

final _macosPlatform = FakePlatform(
  pathSeparator: '/',
  operatingSystem: 'macos',
  environment: {'HOME': join('/home', 'johndoe')},
);

final _linuxPlatform = FakePlatform(
  pathSeparator: '/',
  operatingSystem: 'linux',
  environment: {'HOME': join('/home', 'johndoe')},
);

const _artifactPath = '/home/johndoe/.cache/patrol';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpFakes();

  group('ArtifactsRepository', () {
    late FileSystem fs;
    late Platform platform;
    late http.Client httpClient;

    late ArtifactsRepository artifactsRepository;

    setUp(() {
      platform = _linuxPlatform;
      httpClient = MockHttpClient();

      fs = MemoryFileSystem.test();
      final wd = fs.directory('/home/johndoe/projects/awesome_app')
        ..createSync(recursive: true);
      fs.currentDirectory = wd;

      artifactsRepository = ArtifactsRepository(
        fs: fs,
        platform: platform,
        httpClient: httpClient,
      );
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
            .file(join(_artifactPath, 'server-$version.apk'))
            .createSync(recursive: true);

        expect(artifactsRepository.areArtifactsPresent(), equals(false));
      });

      test('returns false when only instrumentation.apk exists', () {
        fs
            .file(join(_artifactPath, 'instrumentation-$version.apk'))
            .createSync(recursive: true);

        expect(artifactsRepository.areArtifactsPresent(), equals(false));
      });

      test('returns true when server.apk and instrumentation.apk exist', () {
        fs
            .file(join(_artifactPath, 'server-$version.apk'))
            .createSync(recursive: true);
        fs
            .file(join(_artifactPath, 'instrumentation-$version.apk'))
            .createSync();

        expect(artifactsRepository.areArtifactsPresent(), equals(true));
      });
    });

    group('areArtifactsPresent on macOS', () {
      setUp(() {
        artifactsRepository = ArtifactsRepository(
          fs: fs,
          platform: _macosPlatform,
          httpClient: httpClient,
        );
      });

      test('returns false when only Android artifacts exist', () {
        fs
            .file(join(_artifactPath, 'server-$version.apk'))
            .createSync(recursive: true);
        fs
            .file(join(_artifactPath, 'instrumentation-$version.apk'))
            .createSync();

        expect(artifactsRepository.areArtifactsPresent(), equals(false));
      });

      test('returns true when Android and iOS artifacts exist', () {
        fs
            .file(join(_artifactPath, 'server-$version.apk'))
            .createSync(recursive: true);
        fs
            .file(join(_artifactPath, 'instrumentation-$version.apk'))
            .createSync();
        fs.directory(join(_artifactPath, 'ios-$version')).createSync();

        expect(artifactsRepository.areArtifactsPresent(), equals(true));
      });
    });

    group('downloadArtifacts', () {
      test('throws exception when status code is not 200', () async {
        when(() => httpClient.get(any())).thenAnswer(
          (_) async => http.Response('', 404),
        );

        expect(
          artifactsRepository.downloadArtifacts,
          throwsException,
        );

        verify(() => httpClient.get(any())).called(2);
      });

      test('downloads artifacts when status code is 200', () async {
        when(() => httpClient.get(any())).thenAnswer(
          (_) async => http.Response('', 200),
        );

        await artifactsRepository.downloadArtifacts();

        expect(
          fs.file(join(_artifactPath, 'server-$version.apk')).existsSync(),
          equals(true),
        );

        expect(
          fs
              .file(join(_artifactPath, 'instrumentation-$version.apk'))
              .existsSync(),
          equals(true),
        );

        expect(
          fs.directory(join(_artifactPath, 'ios-$version')).existsSync(),
          equals(false),
        );

        verify(() => httpClient.get(any())).called(2);
      });
    });
  });
}

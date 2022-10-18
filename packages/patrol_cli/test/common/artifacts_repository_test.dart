import 'package:archive/archive.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' show join;
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/constants.dart' show globalVersion;
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import '../fakes.dart';

final _macos = FakePlatform(
  pathSeparator: '/',
  operatingSystem: 'macos',
  environment: {'HOME': join('/home', 'johndoe')},
);

final _linux = FakePlatform(
  pathSeparator: '/',
  operatingSystem: 'linux',
  environment: {'HOME': join('/home', 'johndoe')},
);

const _artifactPath = '/home/johndoe/.cache/patrol';

class MockHttpClient extends Mock implements http.Client {}

class MockZipDecoder extends Mock implements ZipDecoder {}

void main() {
  setUpFakes();

  group('ArtifactsRepository', () {
    late FileSystem fs;
    late Platform platform;
    late http.Client httpClient;
    late ZipDecoder zipDecoder;

    late ArtifactsRepository artifactsRepository;

    setUp(() {
      platform = _linux;
      httpClient = MockHttpClient();
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => http.Response('', 200),
      );

      zipDecoder = MockZipDecoder();
      when(() => zipDecoder.decodeBytes(any())).thenAnswer((invocation) {
        final archiveFile = ArchiveFile.string('ios-$globalVersion', '')
          ..isFile = false;

        return Archive()..addFile(archiveFile);
      });

      fs = MemoryFileSystem.test();
      final wd = fs.directory('/home/johndoe/projects/awesome_app')
        ..createSync(recursive: true);
      fs.currentDirectory = wd;

      artifactsRepository = ArtifactsRepository(
        fs: fs,
        platform: platform,
        httpClient: httpClient,
        zipDecoder: zipDecoder,
      );
    });

    group('paths', () {
      test('are correct for release artifacts', () {
        expect(
          artifactsRepository.serverArtifactPath,
          equals('/home/johndoe/.cache/patrol/server-$globalVersion.apk'),
        );

        expect(
          artifactsRepository.instrumentationArtifactPath,
          equals(
              '/home/johndoe/.cache/patrol/instrumentation-$globalVersion.apk'),
        );

        // expect(
        //   artifactsRepository.iosArtifactDirPath,
        //   equals('/home/johndoe/.cache/patrol/ios-$version'),
        // );
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
          artifactsRepository.iosPath,
          equals('/home/johndoe/.cache/patrol/ios'),
        );
      });
    });

    group('areArtifactsPresent', () {
      test('returns false when artifacts are not present', () {
        expect(artifactsRepository.areArtifactsPresent(), equals(false));
      });

      test('returns false when only server.apk exists', () {
        fs
            .file(join(_artifactPath, 'server-$globalVersion.apk'))
            .createSync(recursive: true);

        expect(artifactsRepository.areArtifactsPresent(), equals(false));
      });

      test('returns false when only instrumentation.apk exists', () {
        fs
            .file(join(_artifactPath, 'instrumentation-$globalVersion.apk'))
            .createSync(recursive: true);

        expect(artifactsRepository.areArtifactsPresent(), equals(false));
      });

      test('returns true when server.apk and instrumentation.apk exist', () {
        fs
            .file(join(_artifactPath, 'server-$globalVersion.apk'))
            .createSync(recursive: true);
        fs
            .file(join(_artifactPath, 'instrumentation-$globalVersion.apk'))
            .createSync();

        expect(artifactsRepository.areArtifactsPresent(), equals(true));
      });

      test('returns false when only Android artifacts exist on macOS', () {
        artifactsRepository.platform = _macos;

        fs
            .file(join(_artifactPath, 'server-$globalVersion.apk'))
            .createSync(recursive: true);
        fs
            .file(join(_artifactPath, 'instrumentation-$globalVersion.apk'))
            .createSync();

        expect(artifactsRepository.areArtifactsPresent(), equals(false));
      });

      test('returns true when Android and iOS artifacts exist on macOS', () {
        artifactsRepository.platform = _macos;
        fs
            .file(join(_artifactPath, 'server-$globalVersion.apk'))
            .createSync(recursive: true);
        fs
            .file(join(_artifactPath, 'instrumentation-$globalVersion.apk'))
            .createSync();
        fs.directory(join(_artifactPath, 'ios-$globalVersion')).createSync();

        expect(artifactsRepository.areArtifactsPresent(), equals(true));
      });
    });

    group('downloadArtifacts', () {
      test('throws exception when status code is not 200', () {
        when(() => httpClient.get(any())).thenAnswer(
          (_) async => http.Response('', 404),
        );

        expect(
          artifactsRepository.downloadArtifacts,
          throwsException,
        );

        verify(() => httpClient.get(any())).called(2);
      });

      test('does not download iOS artifacts when not on macOS', () async {
        expect(
          artifactsRepository.platform.operatingSystem,
          isNot(equals('macos')),
        );

        await artifactsRepository.downloadArtifacts();

        expect(
          fs.directory(join(_artifactPath, 'ios-$globalVersion')).existsSync(),
          isFalse,
        );
        verify(() => httpClient.get(any())).called(2);
      });

      test('downloads Android artifacts', () async {
        await artifactsRepository.downloadArtifacts();

        expect(
          fs
              .file(join(_artifactPath, 'server-$globalVersion.apk'))
              .existsSync(),
          isTrue,
        );

        expect(
          fs
              .file(join(_artifactPath, 'instrumentation-$globalVersion.apk'))
              .existsSync(),
          isTrue,
        );

        verify(() => httpClient.get(any())).called(2);
      });

      test('downloads Android and iOS artifacts when on macOS', () async {
        artifactsRepository.platform = _macos;
        await artifactsRepository.downloadArtifacts();

        expect(
          fs
              .file(join(_artifactPath, 'server-$globalVersion.apk'))
              .existsSync(),
          isTrue,
        );

        expect(
          fs
              .file(join(_artifactPath, 'instrumentation-$globalVersion.apk'))
              .existsSync(),
          isTrue,
        );

        expect(
          fs.directory(join(_artifactPath, 'ios-$globalVersion')).existsSync(),
          isTrue,
        );

        verify(() => httpClient.get(any())).called(3);
      });
    });
  });
}

import 'dart:convert';

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:test/test.dart';

import '../src/fakes.dart';
import '../src/mocks.dart';

void main() {
  group('Analytics with no env variable', () {
    late Analytics analytics;
    late FileSystem fs;

    setUp(() {
      setUpFakes();

      fs = MemoryFileSystem.test();

      final httpClient = MockHttpClient();
      when(
        () => httpClient.post(
          any(),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((_) async => http.Response('', 200));

      analytics = Analytics(
        measurementId: 'measurementId',
        apiSecret: 'apiSecret',
        fs: fs,
        platform: fakePlatform('/Users/john'),
        httpClient: httpClient,
        isCI: false,
        envAnalyticsEnabled: null,
      );
    });

    test('sends data when enabled', () async {
      // given
      _createFakeFileSystem(fs, analyticsEnabled: true);

      // when
      final sent =
          await analytics.sendCommand(FlutterVersion.test(), 'test command');

      // then
      expect(sent, true);
    });

    test('does not send data when disabled', () async {
      // given
      _createFakeFileSystem(fs, analyticsEnabled: false);

      // when
      final sent =
          await analytics.sendCommand(FlutterVersion.test(), 'test command');

      // then
      expect(sent, false);
    });
  });

  group('Analytics with env variable enabled', () {
    late Analytics analytics;
    late FileSystem fs;

    setUp(() {
      setUpFakes();

      fs = MemoryFileSystem.test();

      final httpClient = MockHttpClient();
      when(
        () => httpClient.post(
          any(),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((_) async => http.Response('', 200));

      analytics = Analytics(
        measurementId: 'measurementId',
        apiSecret: 'apiSecret',
        fs: fs,
        platform: fakePlatform('/Users/john'),
        httpClient: httpClient,
        isCI: false,
        envAnalyticsEnabled: true,
      );
    });

    test('sends data when enabled', () async {
      // given
      _createFakeFileSystem(fs, analyticsEnabled: true);

      // when
      final sent =
          await analytics.sendCommand(FlutterVersion.test(), 'test command');

      // then
      expect(sent, true);
    });

    test('does not send data when disabled', () async {
      // given
      _createFakeFileSystem(fs, analyticsEnabled: false);

      // when
      final sent =
          await analytics.sendCommand(FlutterVersion.test(), 'test command');

      // then
      expect(sent, true);
    });
  });

  group('Analytics with env variable disabled', () {
    late Analytics analytics;
    late FileSystem fs;

    setUp(() {
      setUpFakes();

      fs = MemoryFileSystem.test();

      final httpClient = MockHttpClient();
      when(
        () => httpClient.post(
          any(),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((_) async => http.Response('', 200));

      analytics = Analytics(
        measurementId: 'measurementId',
        apiSecret: 'apiSecret',
        fs: fs,
        platform: fakePlatform('/Users/john'),
        httpClient: httpClient,
        isCI: false,
        envAnalyticsEnabled: false,
      );
    });

    test('sends data when enabled', () async {
      // given
      _createFakeFileSystem(fs, analyticsEnabled: true);

      // when
      final sent =
          await analytics.sendCommand(FlutterVersion.test(), 'test command');

      // then
      expect(sent, false);
    });

    test('does not send data when disabled', () async {
      // given
      _createFakeFileSystem(fs, analyticsEnabled: false);

      // when
      final sent =
          await analytics.sendCommand(FlutterVersion.test(), 'test command');

      // then
      expect(sent, false);
    });
  });
}

void _createFakeFileSystem(FileSystem fs, {required bool analyticsEnabled}) {
  const configDirPath = '/Users/john/.config/patrol_cli';
  fs.directory(configDirPath).createSync(recursive: true);

  const configFilePath = '$configDirPath/analytics.json';
  fs.file(configFilePath).writeAsStringSync(
        jsonEncode({
          'clientId': 'd528c6d1-b621-4a2b-9fcb-b23325c34a23',
          'enabled': analyticsEnabled,
        }),
      );
}

import 'dart:convert';
import 'dart:io' as io;

import 'package:file/local.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/coverage/web_coverage_tool.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  group('resolveDartSourceUri', () {
    Uri? resolve(String sourceUrl, {String? scriptUrl}) {
      return resolveDartSourceUri(
        sourceUrl: sourceUrl,
        scriptUrl: scriptUrl,
        appPackageName: 'example_app',
      );
    }

    test('passes package: and file: URIs through', () {
      expect(
        resolve('package:foo/src/bar.dart'),
        Uri.parse('package:foo/src/bar.dart'),
      );
      expect(
        resolve('file:///home/user/app/lib/main.dart'),
        Uri.parse('file:///home/user/app/lib/main.dart'),
      );
    });

    test('maps org-dartlang-app lib/ sources to the app package', () {
      expect(
        resolve('org-dartlang-app:///lib/src/home.dart'),
        Uri.parse('package:example_app/src/home.dart'),
      );
    });

    test('maps org-dartlang-app packages/ sources to that package', () {
      expect(
        resolve('org-dartlang-app:///packages/dep/src/util.dart'),
        Uri.parse('package:dep/src/util.dart'),
      );
    });

    test('ignores org-dartlang-app sources outside lib/ and packages/', () {
      expect(resolve('org-dartlang-app:///web/main.dart'), isNull);
    });

    test('ignores unknown schemes', () {
      expect(resolve('webpack:///src/index.js'), isNull);
    });

    test('resolves relative sources against the script URL', () {
      expect(
        resolve(
          'util.dart',
          scriptUrl: 'http://localhost:8080/packages/dep/util.dart.lib.js',
        ),
        Uri.parse('package:dep/util.dart'),
      );
    });

    test(
      'attributes relative sources escaping to a top-level lib/ '
      'to the app package',
      () {
        expect(
          resolve(
            '../../lib/main.dart',
            scriptUrl: 'http://localhost:8080/main.dart.js',
          ),
          Uri.parse('package:example_app/main.dart'),
        );
      },
    );

    test('returns null for relative sources without a script URL', () {
      expect(resolve('lib/main.dart'), isNull);
    });

    test('returns null for unattributable relative sources', () {
      expect(
        resolve(
          'src/main.dart',
          scriptUrl: 'http://localhost:8080/main.dart.js',
        ),
        isNull,
      );
    });
  });

  group('WebCoverageTool', () {
    late MockLogger logger;
    late MemoryFileSystem reportFs;
    late io.Directory tempDir;
    late WebCoverageTool tool;

    setUp(() {
      logger = MockLogger();
      reportFs = MemoryFileSystem.test();
      tempDir = io.Directory.systemTemp.createTempSync(
        'web_coverage_tool_test',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      // The report goes to the memory fs; coverage data and package config
      // live in a real temp dir because package:coverage's Resolver reads
      // package_config.json with dart:io.
      const localFs = LocalFileSystem();
      tool = WebCoverageTool(
        fs: reportFs,
        rootDirectory: localFs.directory(tempDir.path),
        logger: logger,
      );
    });

    void writePackageConfig() {
      io.File('${tempDir.path}/.dart_tool/package_config.json')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          jsonEncode({
            'configVersion': 2,
            'packages': [
              {
                'name': 'example_app',
                'rootUri': '../',
                'packageUri': 'lib/',
              },
            ],
          }),
        );
    }

    test('warns and writes no report when no data was collected', () async {
      writePackageConfig();

      await tool.run(
        flutterPackageName: 'example_app',
        packagesRegExps: {RegExp('example_app')},
        ignoreGlobs: {},
      );

      verify(
        () => logger.warn(any(that: contains('No web coverage data'))),
      ).called(1);
      expect(
        reportFs.file('coverage/patrol_lcov.info').existsSync(),
        isFalse,
      );
    });

    test('converts V8 coverage into an LCOV report', () async {
      writePackageConfig();
      // The Resolver only reports files that exist on disk.
      io.File('${tempDir.path}/lib/main.dart')
        ..createSync(recursive: true)
        ..writeAsStringSync('void main() {}\n');

      // Three 4-char JS lines; the source map ("AAAA;AACA;AACA") maps JS line
      // N col 0 to line N of lib/main.dart. First range covers lines 1-2, the
      // second marks line 3 as not executed.
      final coverageData = {
        'entries': [
          {
            'url': 'http://localhost:8080/main.dart.js',
            'scriptId': '42',
            'source': 'aaaa\nbbbb\ncccc\n',
            'sourceMap': jsonEncode({
              'version': 3,
              'file': 'main.dart.js',
              'sources': ['org-dartlang-app:///lib/main.dart'],
              'names': <String>[],
              'mappings': 'AAAA;AACA;AACA',
            }),
            'functions': [
              {
                'functionName': 'main',
                'isBlockCoverage': true,
                'ranges': [
                  {'startOffset': 0, 'endOffset': 10, 'count': 1},
                  {'startOffset': 10, 'endOffset': 15, 'count': 0},
                ],
              },
            ],
          },
        ],
      };
      io.File('${tempDir.path}/.dart_tool/patrol/web_coverage/test-1.json')
        ..createSync(recursive: true)
        ..writeAsStringSync(jsonEncode(coverageData));

      await tool.run(
        flutterPackageName: 'example_app',
        packagesRegExps: {RegExp('example_app')},
        ignoreGlobs: {},
      );

      final report = reportFs
          .file('coverage/patrol_lcov.info')
          .readAsStringSync();
      expect(report, contains('lib/main.dart'));
      expect(report, contains('DA:1,1'));
      expect(report, contains('DA:2,1'));
      expect(report, contains('DA:3,0'));
    });

    test('excludes packages not selected for the report', () async {
      writePackageConfig();

      final coverageData = {
        'entries': [
          {
            'url': 'http://localhost:8080/packages/other_dep/util.dart.lib.js',
            'scriptId': '7',
            'source': 'aaaa\n',
            'sourceMap': jsonEncode({
              'version': 3,
              'file': 'util.dart.lib.js',
              'sources': ['org-dartlang-app:///packages/other_dep/util.dart'],
              'names': <String>[],
              'mappings': 'AAAA',
            }),
            'functions': [
              {
                'functionName': '',
                'isBlockCoverage': true,
                'ranges': [
                  {'startOffset': 0, 'endOffset': 5, 'count': 1},
                ],
              },
            ],
          },
        ],
      };
      io.File('${tempDir.path}/.dart_tool/patrol/web_coverage/test-2.json')
        ..createSync(recursive: true)
        ..writeAsStringSync(jsonEncode(coverageData));

      await tool.run(
        flutterPackageName: 'example_app',
        packagesRegExps: {RegExp('example_app')},
        ignoreGlobs: {},
      );

      verify(
        () => logger.warn(
          any(that: contains('did not map back to any Dart sources')),
        ),
      ).called(1);
      expect(
        reportFs.file('coverage/patrol_lcov.info').existsSync(),
        isFalse,
      );
    });

    test('prepareDataDirectory clears data from previous runs', () async {
      final stale = io.File(
        '${tempDir.path}/.dart_tool/patrol/web_coverage/stale.json',
      )..createSync(recursive: true);

      final dir = await tool.prepareDataDirectory();

      expect(io.Directory(dir.path).existsSync(), isTrue);
      expect(stale.existsSync(), isFalse);
    });
  });
}

import 'package:collection/collection.dart';
import 'package:file/file.dart';
import 'package:patrol_cli/src/base/exceptions.dart';

const _kDefaultTestFileSuffix = '_test.dart';

/// Discovers integration tests.
class TestFinder {
  TestFinder({required Directory testDir})
    : _integrationTestDirectory = testDir,
      _fs = testDir.fileSystem..currentDirectory = testDir.parent;

  final Directory _integrationTestDirectory;
  final FileSystem _fs;

  String findTest(
    String target, [
    String testFileSuffix = _kDefaultTestFileSuffix,
  ]) {
    final testFiles = findTests([target], testFileSuffix);
    if (testFiles.length > 1) {
      throwToolExit(
        'target $target is ambiguous, '
        'it matches multiple test targets: ${testFiles.join(', ')}',
      );
    }

    return testFiles.single;
  }

  /// Checks that every element of [targets] is a valid target.
  ///
  /// A target is valid if it:
  ///
  ///  * is a path to a Dart test file, or
  ///
  ///  * is a path to a directory recursively containing at least one Dart test
  ///    file
  List<String> findTests(
    List<String> targets, [
    String testFileSuffix = _kDefaultTestFileSuffix,
  ]) {
    final testFiles = <String>[];

    for (final target in targets) {
      if (target.endsWith(testFileSuffix)) {
        final isFile = _fs.isFileSync(target);
        if (!isFile) {
          throwToolExit('target file $target does not exist');
        }
        testFiles.add(_fs.file(target).absolute.path);
      } else if (_fs.isDirectorySync(target)) {
        final foundTargets = findAllTests(
          directory: _fs.directory(target),
          testFileSuffix: testFileSuffix,
        );
        if (foundTargets.isEmpty) {
          throwToolExit('target directory $target does not contain any tests');
        }

        testFiles.addAll(foundTargets);
      } else {
        throwToolExit(
          'target $target is invalid. Does your test file(s) end with "$testFileSuffix"?',
        );
      }
    }

    return testFiles;
  }

  /// Recursively searches the `integration_test` directory and returns files
  /// ending with defined [testFileSuffix]. If [testFileSuffix] is not defined,
  /// the default suffix `_test.dart` is used.
  List<String> findAllTests({
    Directory? directory,
    Set<String> excludes = const {},
    String testFileSuffix = _kDefaultTestFileSuffix,
  }) {
    directory ??= _integrationTestDirectory;

    if (!directory.existsSync()) {
      throwToolExit("Directory ${directory.path} doesn't exist");
    }

    final absoluteExcludes = excludes
        .map((e) => _fs.file(e).absolute.path)
        .toSet();

    return directory
        .listSync(recursive: true, followLinks: false)
        .sorted((a, b) => a.path.compareTo(b.path))
        // Find only test files
        .where((fileSystemEntity) {
          final hasSuffix = fileSystemEntity.path.endsWith(testFileSuffix);
          final isFile = _fs.isFileSync(fileSystemEntity.path);
          return hasSuffix && isFile;
        })
        // Filter out excluded files
        .where((fileSystemEntity) {
          // TODO: Doesn't handle excluded passes as absolute paths
          final isExcluded = absoluteExcludes.contains(fileSystemEntity.path);
          return !isExcluded;
        })
        .map((entity) => entity.absolute.path)
        .toList();
  }
}

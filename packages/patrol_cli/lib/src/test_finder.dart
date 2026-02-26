import 'package:collection/collection.dart';
import 'package:file/file.dart';
import 'package:patrol_cli/src/base/exceptions.dart';

const _kDefaultTestFileSuffix = '_test.dart';

/// Discovers integration tests.
class TestFinder {
  TestFinder({required Directory testDir, required Directory rootDir})
    : _patrolTestDirectory = testDir,
      _fs = rootDir.fileSystem;

  final Directory _patrolTestDirectory;
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

  /// Recursively searches the `patrol_test` directory (or custom directory via
  /// `test_directory` in `pubspec.yaml`) and returns files ending with defined
  /// [testFileSuffix]. If [testFileSuffix] is not defined, the default suffix
  /// `_test.dart` is used.
  List<String> findAllTests({
    Directory? directory,
    Set<String> excludes = const {},
    String testFileSuffix = _kDefaultTestFileSuffix,
  }) {
    directory ??= _patrolTestDirectory;

    if (!directory.existsSync()) {
      throwToolExit("Directory ${directory.path} doesn't exist");
    }

    final absoluteExcludes = <String>{};
    for (final exclude in excludes) {
      // Try to resolve as absolute path first, then relative to root
      final entityPath = _fs.file(exclude).absolute.path;

      // Check if it's a directory or a file
      if (_fs.isDirectorySync(entityPath)) {
        absoluteExcludes.add(_fs.directory(entityPath).absolute.path);
      } else if (_fs.isFileSync(entityPath)) {
        absoluteExcludes.add(entityPath);
      } else {
        // If it doesn't exist as absolute, it might be a relative path
        // that we still want to track for matching
        absoluteExcludes.add(entityPath);
      }
    }

    return directory
        .listSync(recursive: true, followLinks: false)
        .sorted((a, b) => a.path.compareTo(b.path))
        // Find only test files
        .where((fileSystemEntity) {
          final hasSuffix = fileSystemEntity.path.endsWith(testFileSuffix);
          final isFile = _fs.isFileSync(fileSystemEntity.path);
          return hasSuffix && isFile;
        })
        // Filter out excluded files and files in excluded directories
        .where((fileSystemEntity) {
          final filePath = fileSystemEntity.path;

          for (final exclude in absoluteExcludes) {
            // Check if the file exactly matches an excluded file
            if (filePath == exclude) {
              return false;
            }

            // Check if the file is inside an excluded directory
            // Need to add path separator to avoid matching prefixes
            // e.g., "patrol_test/permissions" shouldn't match "patrol_test/permissions_other"
            final excludeWithSeparator = exclude.endsWith(_fs.path.separator)
                ? exclude
                : exclude + _fs.path.separator;
            if (filePath.startsWith(excludeWithSeparator)) {
              return false;
            }
          }

          return true;
        })
        .map((entity) => entity.absolute.path)
        .toList();
  }
}

class TestFinderFactory {
  const TestFinderFactory({required this.rootDirectory});

  final Directory rootDirectory;

  TestFinder create(String testDirectory) => TestFinder(
    testDir: rootDirectory.childDirectory(testDirectory),
    rootDir: rootDirectory,
  );
}

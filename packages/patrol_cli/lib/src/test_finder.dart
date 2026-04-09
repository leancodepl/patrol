import 'package:collection/collection.dart';
import 'package:file/file.dart';
import 'package:patrol_cli/src/base/exceptions.dart';

const _kDefaultTestFileSuffix = '_test.dart';

/// Discovers integration tests.
class TestFinder {
  TestFinder({required Directory testDir, required Directory rootDir})
    : _patrolTestDirectory = testDir,
      _rootDir = rootDir,
      _fs = rootDir.fileSystem;

  final Directory _patrolTestDirectory;
  final Directory _rootDir;
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
    Set<String> excludes = const {},
  ]) {
    final testFiles = <String>[];
    final absoluteExcludes = _toAbsoluteExcludes(excludes);

    for (final target in targets) {
      if (target.endsWith(testFileSuffix)) {
        final isFile = _fs.isFileSync(target);
        if (!isFile) {
          throwToolExit('target file $target does not exist');
        }
        final absoluteTargetPath = _fs.file(target).absolute.path;
        if (!_isExcluded(absoluteTargetPath, absoluteExcludes)) {
          testFiles.add(absoluteTargetPath);
        }
      } else if (_fs.isDirectorySync(target)) {
        final foundTargets = findAllTests(
          directory: _fs.directory(target).absolute,
          excludes: excludes,
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

    final absoluteExcludes = _toAbsoluteExcludes(excludes);

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

          return !_isExcluded(filePath, absoluteExcludes);
        })
        .map((entity) => entity.absolute.path)
        .toList();
  }

  /// Converts `excludes` to absolute paths.
  ///
  /// Pass file paths or directory paths in `excludes`, either absolute or
  /// relative to [_rootDir]. Absolute paths are kept as-is, and relative paths
  /// are resolved against [_rootDir] (not the process working directory).
  Set<String> _toAbsoluteExcludes(Set<String> excludes) {
    return excludes.map((exclude) {
      if (_fs.path.isAbsolute(exclude)) {
        return exclude;
      }
      return _fs.path.join(_rootDir.path, exclude);
    }).toSet();
  }

  /// Returns `true` when [filePath] should be filtered out by exclusions.
  ///
  /// A file is excluded if it exactly matches an excluded path, or if it is
  /// located under an excluded directory path.
  bool _isExcluded(String filePath, Set<String> absoluteExcludes) {
    for (final exclude in absoluteExcludes) {
      // Check if the file exactly matches an excluded file.
      if (filePath == exclude) {
        return true;
      }

      final excludeWithSeparator = exclude.endsWith(_fs.path.separator)
          ? exclude
          : exclude + _fs.path.separator;
      if (filePath.startsWith(excludeWithSeparator)) {
        return true;
      }
    }

    return false;
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

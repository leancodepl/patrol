import 'package:file/file.dart';

import '../../common/tool_exit.dart';

class TestFinder {
  const TestFinder({
    required Directory integrationTestDir,
    required FileSystem fs,
  })  : _integrationTestDirectory = integrationTestDir,
        _fs = fs;

  final Directory _integrationTestDirectory;
  final FileSystem _fs;

  /// Checks that every element of [targets] is a valid target.
  ///
  /// A target is valid if it:
  /// - is a path to a Dart test file, or
  /// - is a path to a directory recursively containing at least one Dart test
  ///   file
  List<String> findTests(List<String> targets) {
    final testFiles = <String>[];

    for (final target in targets) {
      if (target.endsWith('_test.dart')) {
        final isFile = _fs.isFileSync(target);
        if (!isFile) {
          throwToolExit('target file $target does not exist');
        }
        testFiles.add(_fs.file(target).absolute.path);
      } else if (_fs.isDirectorySync(target)) {
        final foundTargets = findAllTests(directory: _fs.directory(target));
        if (foundTargets.isEmpty) {
          throwToolExit(
            'target directory $target does not contain any tests',
          );
        }

        testFiles.addAll(foundTargets);
      } else {
        throwToolExit('target $target is invalid');
      }
    }

    return testFiles;
  }

  /// Recursively searches the `integration_test` directory and returns files
  /// ending with `_test.dart` as absolute paths.
  List<String> findAllTests({Directory? directory}) {
    directory ??= _integrationTestDirectory;

    return directory
        .listSync(recursive: true, followLinks: false)
        .where(
          (fileSystemEntity) {
            final hasSuffix = fileSystemEntity.path.endsWith('_test.dart');
            final isFile = _fs.isFileSync(fileSystemEntity.path);
            return hasSuffix && isFile;
          },
        )
        .map((entity) => entity.absolute.path)
        .toList();
  }
}

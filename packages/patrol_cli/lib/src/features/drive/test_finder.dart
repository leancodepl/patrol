import 'package:file/file.dart';

import '../../common/tool_exit.dart';

class TestFinder {
  TestFinder({
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
    for (var i = 0; i < targets.length; i++) {
      final target = targets[i];
      if (target.endsWith('_test.dart')) {
        final isFile = _fs.isFileSync(target);
        if (!isFile) {
          throwToolExit('target file $target does not exist');
        }
        final absolutePath = _fs.file(target).absolute.path;
        targets[i] = absolutePath;
      } else if (_fs.isDirectorySync(target)) {
        final newTargets = findAllTests(directory: _fs.directory(target));
        if (newTargets.isEmpty) {
          throwToolExit(
            'target directory $target does not contain any tests',
          );
        }

        targets
          ..insertAll(i + 1, newTargets)
          ..removeAt(i);
      } else {
        throwToolExit('target $target is invalid');
      }
    }

    return targets;
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

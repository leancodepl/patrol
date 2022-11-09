import 'package:file/file.dart';
import 'package:path/path.dart' show join;
import 'package:patrol_cli/src/common/extensions/core.dart';

class DartDefinesReader {
  const DartDefinesReader({
    required Directory projectRoot,
    required FileSystem fs,
  })  : _projectRoot = projectRoot,
        _fs = fs;

  final Directory _projectRoot;
  final FileSystem _fs;

  Map<String, String> fromCli({required List<String> args}) {
    final map = <String, String>{};
    for (final arg in args) {
      final parts = arg.splitFirst('=');
      final key = parts.first;
      final value = parts.elementAt(1);
      map[key] = value;
    }

    return map;
  }

  Map<String, String> fromFile() {
    final filePath = join(_projectRoot.path, '.patrol.env');
    final file = _fs.file(filePath);

    if (!file.existsSync()) {
      return {};
    }

    final map = <String, String>{};
    for (final line in file.readAsLinesSync()) {
      final parts = line.splitFirst('=');
      final key = parts.first;
      final value = parts.elementAt(1);
      map[key] = value;
    }

    return map;
  }
}

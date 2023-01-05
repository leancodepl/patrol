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

  Map<String, String> fromCli({required List<String> args}) => _parse(args);

  Map<String, String> fromFile() {
    final filePath = join(_projectRoot.path, '.patrol.env');
    final file = _fs.file(filePath);

    if (!file.existsSync()) {
      return {};
    }

    final lines = file.readAsLinesSync()
      ..removeWhere((line) => line.trim().isEmpty);
    return _parse(lines);
  }

  Map<String, String> _parse(List<String> args) {
    final map = <String, String>{};
    for (final arg in args) {
      final parts = arg.splitFirst('=');
      final key = parts.first;
      if (key.contains(' ')) {
        throw FormatException('key "$key" contains whitespace');
      }

      final value = parts.elementAt(1);
      map[key] = value;
    }

    return map;
  }
}

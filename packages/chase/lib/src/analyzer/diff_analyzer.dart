import 'package:glob/glob.dart';

import 'diff_models.dart';

/// Parses unified git diff output into structured [DiffResult].
class DiffAnalyzer {
  DiffAnalyzer({this.excludePatterns = const []});

  final List<String> excludePatterns;

  late final List<Glob> _excludeGlobs =
      excludePatterns.map((p) => Glob(p)).toList();

  /// Analyzes raw git diff output.
  DiffResult analyze(String rawDiff) {
    final files = <FileDiff>[];
    final fileSections = _splitIntoFileSections(rawDiff);

    for (final section in fileSections) {
      final fileDiff = _parseFileSection(section);
      if (fileDiff != null && !_isExcluded(fileDiff.path)) {
        files.add(fileDiff);
      }
    }

    return DiffResult(files: files, rawDiff: rawDiff);
  }

  bool _isExcluded(String path) {
    return _excludeGlobs.any((glob) => glob.matches(path));
  }

  List<String> _splitIntoFileSections(String rawDiff) {
    final sections = <String>[];
    final lines = rawDiff.split('\n');
    final buffer = StringBuffer();
    var inSection = false;

    for (final line in lines) {
      if (line.startsWith('diff --git')) {
        if (inSection) {
          sections.add(buffer.toString());
          buffer.clear();
        }
        inSection = true;
      }
      if (inSection) {
        buffer.writeln(line);
      }
    }

    if (inSection && buffer.isNotEmpty) {
      sections.add(buffer.toString());
    }

    return sections;
  }

  FileDiff? _parseFileSection(String section) {
    final lines = section.split('\n');
    if (lines.isEmpty) return null;

    // Parse the diff header line: diff --git a/path b/path
    final headerLine = lines.first;
    final headerMatch =
        RegExp(r'diff --git a/(.+) b/(.+)').firstMatch(headerLine);
    if (headerMatch == null) return null;

    final oldPath = headerMatch.group(1)!;
    final newPath = headerMatch.group(2)!;

    // Determine change type
    var changeType = ChangeType.modified;
    String? renamedFrom;

    for (final line in lines) {
      if (line.startsWith('new file mode')) {
        changeType = ChangeType.added;
        break;
      } else if (line.startsWith('deleted file mode')) {
        changeType = ChangeType.deleted;
        break;
      } else if (line.startsWith('rename from')) {
        changeType = ChangeType.renamed;
        renamedFrom = oldPath;
        break;
      }
    }

    // Parse hunks
    final hunks = _parseHunks(lines);

    return FileDiff(
      path: newPath,
      changeType: changeType,
      hunks: hunks,
      oldPath: renamedFrom,
    );
  }

  List<HunkDiff> _parseHunks(List<String> lines) {
    final hunks = <HunkDiff>[];
    final hunkHeaderPattern =
        RegExp(r'^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@(.*)$');

    var i = 0;
    while (i < lines.length) {
      final match = hunkHeaderPattern.firstMatch(lines[i]);
      if (match != null) {
        final oldStart = int.parse(match.group(1)!);
        final oldCount = int.tryParse(match.group(2) ?? '1') ?? 1;
        final newStart = int.parse(match.group(3)!);
        final newCount = int.tryParse(match.group(4) ?? '1') ?? 1;
        final header = match.group(5)?.trim() ?? '';

        final hunkLines = <DiffLine>[];
        i++;

        var currentNewLine = newStart;
        while (i < lines.length && !lines[i].startsWith('diff --git') &&
            !hunkHeaderPattern.hasMatch(lines[i])) {
          final line = lines[i];
          if (line.startsWith('+')) {
            hunkLines.add(
              DiffLine(
                type: DiffLineType.addition,
                content: line.substring(1),
                lineNumber: currentNewLine,
              ),
            );
            currentNewLine++;
          } else if (line.startsWith('-')) {
            hunkLines.add(
              DiffLine(
                type: DiffLineType.deletion,
                content: line.substring(1),
              ),
            );
          } else if (line.startsWith(' ')) {
            hunkLines.add(
              DiffLine(
                type: DiffLineType.context,
                content: line.substring(1),
                lineNumber: currentNewLine,
              ),
            );
            currentNewLine++;
          }
          i++;
        }

        hunks.add(
          HunkDiff(
            oldStart: oldStart,
            oldCount: oldCount,
            newStart: newStart,
            newCount: newCount,
            header: header,
            lines: hunkLines,
          ),
        );
      } else {
        i++;
      }
    }

    return hunks;
  }
}

import 'package:meta/meta.dart';

/// Result of analyzing a git diff.
@immutable
class DiffResult {
  const DiffResult({
    required this.files,
    required this.rawDiff,
  });

  final List<FileDiff> files;
  final String rawDiff;

  /// Total number of lines added across all files.
  int get totalAdditions => files.fold(0, (sum, f) => sum + f.additions);

  /// Total number of lines removed across all files.
  int get totalDeletions => files.fold(0, (sum, f) => sum + f.deletions);
}

/// Diff for a single file.
@immutable
class FileDiff {
  const FileDiff({
    required this.path,
    required this.changeType,
    required this.hunks,
    this.oldPath,
  });

  final String path;
  final ChangeType changeType;
  final List<HunkDiff> hunks;
  final String? oldPath; // For renames

  int get additions => hunks.fold(0, (sum, h) => sum + h.additions);
  int get deletions => hunks.fold(0, (sum, h) => sum + h.deletions);

  /// Returns the file extension (e.g., 'dart').
  String get extension {
    final dot = path.lastIndexOf('.');
    return dot >= 0 ? path.substring(dot + 1) : '';
  }

  /// Whether this is a Dart source file.
  bool get isDartFile => extension == 'dart';

  /// Whether this is a test file.
  bool get isTestFile =>
      path.contains('_test.dart') || path.contains('/test/');
}

/// A single hunk within a file diff.
@immutable
class HunkDiff {
  const HunkDiff({
    required this.oldStart,
    required this.oldCount,
    required this.newStart,
    required this.newCount,
    required this.header,
    required this.lines,
  });

  final int oldStart;
  final int oldCount;
  final int newStart;
  final int newCount;
  final String header;
  final List<DiffLine> lines;

  int get additions => lines.where((l) => l.type == DiffLineType.addition).length;
  int get deletions => lines.where((l) => l.type == DiffLineType.deletion).length;
}

/// A single line in a diff hunk.
@immutable
class DiffLine {
  const DiffLine({
    required this.type,
    required this.content,
    this.lineNumber,
  });

  final DiffLineType type;
  final String content;
  final int? lineNumber;
}

enum DiffLineType { addition, deletion, context }

enum ChangeType { added, modified, deleted, renamed }

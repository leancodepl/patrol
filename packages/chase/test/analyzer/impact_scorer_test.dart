import 'package:chase/src/analyzer/change_classifier.dart';
import 'package:chase/src/analyzer/diff_models.dart';
import 'package:chase/src/analyzer/impact_scorer.dart';
import 'package:test/test.dart';

void main() {
  group('ImpactScorer', () {
    const scorer = ImpactScorer();

    FileDiff makeFile(
      String path,
      ChangeType changeType, {
      int additions = 10,
    }) {
      return FileDiff(
        path: path,
        changeType: changeType,
        hunks: [
          HunkDiff(
            oldStart: 1,
            oldCount: 0,
            newStart: 1,
            newCount: additions,
            header: '',
            lines: List.generate(
              additions,
              (i) => DiffLine(
                type: DiffLineType.addition,
                content: 'line $i',
                lineNumber: i + 1,
              ),
            ),
          ),
        ],
      );
    }

    test('ranks screens higher than widgets', () {
      final files = [
        makeFile('lib/widgets/button.dart', ChangeType.added),
        makeFile('lib/screens/home_screen.dart', ChangeType.added),
      ];

      final scored = scorer.score(files);

      expect(scored.first.category, ChangeCategory.screen);
      expect(scored.last.category, ChangeCategory.widget);
      expect(scored.first.score, greaterThan(scored.last.score));
    });

    test('gives new files a boost', () {
      final files = [
        makeFile('lib/screens/old_screen.dart', ChangeType.modified),
        makeFile(
          'lib/screens/new_screen.dart',
          ChangeType.added,
        ),
      ];

      final scored = scorer.score(files);
      final newFile =
          scored.firstWhere((s) => s.file.path.contains('new_screen'));
      final oldFile =
          scored.firstWhere((s) => s.file.path.contains('old_screen'));

      expect(newFile.score, greaterThan(oldFile.score));
    });

    test('excludes deleted files', () {
      final files = [
        makeFile('lib/screens/removed.dart', ChangeType.deleted),
        makeFile('lib/screens/kept.dart', ChangeType.modified),
      ];

      final scored = scorer.score(files);

      expect(scored, hasLength(1));
      expect(scored.first.file.path, contains('kept'));
    });

    test('excludes non-dart files', () {
      final files = [
        FileDiff(
          path: 'assets/image.png',
          changeType: ChangeType.added,
          hunks: [],
        ),
        makeFile('lib/screen.dart', ChangeType.added),
      ];

      final scored = scorer.score(files);

      expect(scored, hasLength(1));
      expect(scored.first.file.isDartFile, isTrue);
    });

    test('sorts by score descending', () {
      final files = [
        makeFile('lib/models/data.dart', ChangeType.modified),
        makeFile(
          'lib/screens/main_screen.dart',
          ChangeType.added,
          additions: 100,
        ),
        makeFile('lib/services/api.dart', ChangeType.modified),
      ];

      final scored = scorer.score(files);

      for (var i = 0; i < scored.length - 1; i++) {
        expect(scored[i].score, greaterThanOrEqualTo(scored[i + 1].score));
      }
    });
  });
}

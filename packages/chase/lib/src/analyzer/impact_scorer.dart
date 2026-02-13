import 'change_classifier.dart';
import 'diff_models.dart';

/// Scored file change for testing prioritization.
class ScoredChange {
  const ScoredChange({
    required this.file,
    required this.category,
    required this.score,
  });

  final FileDiff file;
  final ChangeCategory category;
  final double score;
}

/// Scores file changes by their testing priority.
///
/// Higher score = more important to test.
class ImpactScorer {
  const ImpactScorer();

  static const _categoryWeights = {
    ChangeCategory.screen: 1.0,
    ChangeCategory.navigation: 0.9,
    ChangeCategory.widget: 0.8,
    ChangeCategory.stateManagement: 0.7,
    ChangeCategory.dataModel: 0.5,
    ChangeCategory.service: 0.4,
    ChangeCategory.configuration: 0.2,
    ChangeCategory.test: 0.1,
    ChangeCategory.other: 0.3,
  };

  /// Scores and ranks all file diffs by testing priority.
  List<ScoredChange> score(List<FileDiff> files) {
    final classifier = const ChangeClassifier();
    final scored = <ScoredChange>[];

    for (final file in files) {
      if (!file.isDartFile) continue;
      if (file.changeType == ChangeType.deleted) continue;

      final category = classifier.classify(file);
      final categoryWeight = _categoryWeights[category] ?? 0.3;

      // Factor in the size of the change
      final changeSize = file.additions + file.deletions;
      final sizeMultiplier = _sizeMultiplier(changeSize);

      // New files get a boost — they always need tests
      final newFileBoost = file.changeType == ChangeType.added ? 0.2 : 0.0;

      final score = (categoryWeight * sizeMultiplier + newFileBoost)
          .clamp(0.0, 1.0);

      scored.add(
        ScoredChange(
          file: file,
          category: category,
          score: score,
        ),
      );
    }

    // Sort by score descending
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }

  double _sizeMultiplier(int changeSize) {
    if (changeSize > 200) return 1.0;
    if (changeSize > 100) return 0.9;
    if (changeSize > 50) return 0.8;
    if (changeSize > 20) return 0.7;
    return 0.6;
  }
}

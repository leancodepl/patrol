import 'package:chase/src/analyzer/change_classifier.dart';
import 'package:chase/src/analyzer/diff_models.dart';
import 'package:test/test.dart';

void main() {
  group('ChangeClassifier', () {
    const classifier = ChangeClassifier();

    FileDiff makeFileDiff(String path, {String content = ''}) {
      return FileDiff(
        path: path,
        changeType: ChangeType.added,
        hunks: [
          HunkDiff(
            oldStart: 0,
            oldCount: 0,
            newStart: 1,
            newCount: 1,
            header: '',
            lines: [
              DiffLine(
                type: DiffLineType.addition,
                content: content,
                lineNumber: 1,
              ),
            ],
          ),
        ],
      );
    }

    test('classifies screen files', () {
      expect(
        classifier.classify(makeFileDiff('lib/screens/home_screen.dart')),
        ChangeCategory.screen,
      );
      expect(
        classifier.classify(makeFileDiff('lib/pages/login_page.dart')),
        ChangeCategory.screen,
      );
    });

    test('classifies widget files', () {
      expect(
        classifier.classify(makeFileDiff('lib/widgets/custom_button.dart')),
        ChangeCategory.widget,
      );
      expect(
        classifier.classify(makeFileDiff('lib/components/card.dart')),
        ChangeCategory.widget,
      );
    });

    test('classifies navigation files', () {
      expect(
        classifier.classify(makeFileDiff('lib/router.dart')),
        ChangeCategory.navigation,
      );
      expect(
        classifier.classify(makeFileDiff('lib/routes.dart')),
        ChangeCategory.navigation,
      );
    });

    test('classifies state management files', () {
      expect(
        classifier.classify(makeFileDiff('lib/bloc/auth_bloc.dart')),
        ChangeCategory.stateManagement,
      );
      expect(
        classifier.classify(makeFileDiff('lib/cubit/counter_cubit.dart')),
        ChangeCategory.stateManagement,
      );
    });

    test('classifies model files', () {
      expect(
        classifier.classify(makeFileDiff('lib/models/user.dart')),
        ChangeCategory.dataModel,
      );
    });

    test('classifies service files', () {
      expect(
        classifier.classify(makeFileDiff('lib/services/auth_service.dart')),
        ChangeCategory.service,
      );
      expect(
        classifier.classify(makeFileDiff('lib/repository/user_repo.dart')),
        ChangeCategory.service,
      );
    });

    test('classifies test files', () {
      expect(
        classifier.classify(
          makeFileDiff('integration_test/home_test.dart'),
        ),
        ChangeCategory.test,
      );
    });

    test('classifies by content when path is ambiguous', () {
      expect(
        classifier.classify(
          makeFileDiff(
            'lib/src/feature.dart',
            content: 'extends StatelessWidget',
          ),
        ),
        ChangeCategory.widget,
      );
    });
  });
}

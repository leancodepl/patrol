import 'diff_models.dart';

/// Semantic classification of a file change for testing priority.
enum ChangeCategory {
  screen,
  widget,
  navigation,
  stateManagement,
  dataModel,
  service,
  configuration,
  test,
  other,
}

/// Classifies file changes by their semantic category.
class ChangeClassifier {
  const ChangeClassifier();

  /// Classifies a file diff by its path and content.
  ChangeCategory classify(FileDiff file) {
    final path = file.path.toLowerCase();
    final content = file.hunks
        .expand((h) => h.lines)
        .map((l) => l.content)
        .join('\n');

    // Test files
    if (file.isTestFile) return ChangeCategory.test;

    // Screen / Page files
    if (_isScreen(path, content)) return ChangeCategory.screen;

    // Navigation / Routing
    if (_isNavigation(path, content)) return ChangeCategory.navigation;

    // State management
    if (_isStateManagement(path, content)) return ChangeCategory.stateManagement;

    // Widget
    if (_isWidget(path, content)) return ChangeCategory.widget;

    // Data model
    if (_isDataModel(path, content)) return ChangeCategory.dataModel;

    // Service / Repository
    if (_isService(path, content)) return ChangeCategory.service;

    // Configuration
    if (_isConfiguration(path)) return ChangeCategory.configuration;

    return ChangeCategory.other;
  }

  bool _isScreen(String path, String content) {
    return path.contains('screen') ||
        path.contains('page') ||
        path.contains('view') ||
        content.contains('extends StatefulWidget') &&
            (content.contains('Scaffold') || content.contains('AppBar'));
  }

  bool _isNavigation(String path, String content) {
    return path.contains('route') ||
        path.contains('navigation') ||
        path.contains('router') ||
        content.contains('GoRouter') ||
        content.contains('Navigator') ||
        content.contains('MaterialPageRoute');
  }

  bool _isStateManagement(String path, String content) {
    return path.contains('bloc') ||
        path.contains('cubit') ||
        path.contains('provider') ||
        path.contains('notifier') ||
        path.contains('controller') ||
        path.contains('store') ||
        content.contains('extends Bloc') ||
        content.contains('extends Cubit') ||
        content.contains('ChangeNotifier') ||
        content.contains('StateNotifier') ||
        content.contains('extends Notifier');
  }

  bool _isWidget(String path, String content) {
    return path.contains('widget') ||
        path.contains('component') ||
        content.contains('extends StatelessWidget') ||
        content.contains('extends StatefulWidget');
  }

  bool _isDataModel(String path, String content) {
    return path.contains('model') ||
        path.contains('entity') ||
        path.contains('dto') ||
        content.contains('fromJson') ||
        content.contains('toJson') ||
        content.contains('@freezed');
  }

  bool _isService(String path, String content) {
    return path.contains('service') ||
        path.contains('repository') ||
        path.contains('api') ||
        path.contains('client') ||
        content.contains('http.') ||
        content.contains('Dio');
  }

  bool _isConfiguration(String path) {
    return path.endsWith('pubspec.yaml') ||
        path.endsWith('analysis_options.yaml') ||
        path.contains('.config') ||
        path.endsWith('.json') && !path.contains('test');
  }
}

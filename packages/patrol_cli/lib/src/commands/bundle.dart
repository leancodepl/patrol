import 'package:collection/collection.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_finder.dart';

class BundleCommand extends PatrolCommand {
  BundleCommand({
    required TestFinder testFinder,
    required Logger logger,
  })  : _testFinder = testFinder,
        _logger = logger {
    usesTargetOption();
  }

  final TestFinder _testFinder;
  final Logger _logger;

  @override
  bool get hidden => true;

  @override
  String get name => 'bundle';

  @override
  String get description => 'Bundle Dart tests into a single wrapper file.';

  @override
  Future<int> run() async {
    final tests = _testFinder
        .findAllTests()
        .map((filepath) => filepath.split('/integration_test/').last)
        .whereNot((filepath) => filepath == 'bundled_test.dart')
        .toList();

    _logger.detail('Will bundle ${tests.length} tests:');
    for (final test in tests) {
      _logger.detail('  - $test');
    }

    final imports = _generateImports(tests);
    _logger
      ..info(imports)
      ..info('\n\n');

    final code = _generateGroupsCode(tests);
    _logger.info(code);

    return 0;
  }

  /// Input:
  ///
  /// ```dart
  /// [
  ///   'integration_test/permissions/permissions_location_test.dart',
  ///   'integration_test/example_test.dart',
  /// ]
  /// ```
  /// Output:
  /// ```dart
  /// '''
  /// import 'permissions/permissions_location_test.dart' as permissions_location_test;
  /// import 'example_test.dart' as example_test;
  /// '''
  /// ```
  String _generateImports(List<String> testFilePaths) {
    final imports = <String>[];
    for (final testFilePath in testFilePaths) {
      final testFileName = testFilePath.split('/').last;
      final testName = testFileName.split('.').first;
      imports.add("import '$testFilePath' as $testName;");
    }
    return imports.join('\n');
  }

  /// Input:
  ///
  /// ```dart
  /// [
  ///   'integration_test/permissions/permissions_location_test.dart',
  ///   'integration_test/example_test.dart',
  /// ]
  /// ```
  ///
  /// Output:
  ///
  /// ```dart
  /// '''
  /// group('permissions.permissions_location_test', permissions_location_test.main);
  /// group('example_test', example_test.main);
  /// '''
  /// ```
  String _generateGroupsCode(List<String> testFilePaths) {
    final groups = <String>[];
    for (final testFilePath in testFilePaths) {
      final testFileName = testFilePath.split('/').last;
      final testName = testFileName.split('.').first;
      groups.add("group('$testName', $testName.main);");
    }
    return groups.join('\n');
  }
}

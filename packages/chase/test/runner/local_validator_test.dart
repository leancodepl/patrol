import 'package:chase/src/runner/local_validator.dart';
import 'package:chase/src/utils/process_runner.dart' as chase;
import 'package:test/test.dart';

// Simple mock for ProcessRunner
class _MockProcessRunner extends chase.ProcessRunner {
  _MockProcessRunner(this.mockResult);

  final chase.ProcessResult mockResult;

  @override
  Future<chase.ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Duration timeout = const Duration(minutes: 5),
    Map<String, String>? environment,
  }) async {
    return mockResult;
  }
}

void main() {
  group('LocalValidator', () {
    test('returns valid for clean analysis output', () async {
      final runner = _MockProcessRunner(
        const chase.ProcessResult(
          exitCode: 0,
          stdout: 'Analyzing integration_test...\nNo issues found!\n',
          stderr: '',
        ),
      );

      final validator = LocalValidator(
        processRunner: runner,
        testDirectory: 'integration_test',
      );

      final result = await validator.validate();

      expect(result.isValid, isTrue);
      expect(result.issues, isEmpty);
    });

    test('returns invalid with issues for analysis errors', () async {
      final runner = _MockProcessRunner(
        const chase.ProcessResult(
          exitCode: 1,
          stdout:
              'error - Undefined name \'foo\' - integration_test/test.dart:5:3 - undefined_identifier\n',
          stderr: '',
        ),
      );

      final validator = LocalValidator(
        processRunner: runner,
        testDirectory: 'integration_test',
      );

      final result = await validator.validate();

      expect(result.isValid, isFalse);
      expect(result.issues, isNotEmpty);
    });
  });
}

import 'package:equatable/equatable.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/features/devices/device.dart';

class RunResults with EquatableMixin {
  const RunResults({required this.targetRunResults});

  final List<TargetRunResult> targetRunResults;

  bool get allSuccessful => targetRunResults.every((e) => e.allRunsPassed);

  @override
  List<Object?> get props => [targetRunResults];
}

/// Represents a single run of a single target on a single device.
class TargetRunResult with EquatableMixin {
  TargetRunResult({
    required this.target,
    required this.device,
    required this.runs,
  });

  final String target;
  final Device device;

  final List<TargetRunStatus> runs;

  String get targetName => basename(target);

  bool get allRunsPassed => runs.every((run) => run == TargetRunStatus.passed);

  bool get allRunsFailed => runs.every(
        (run) =>
            run == TargetRunStatus.failedToBuild ||
            run == TargetRunStatus.failedToExecute,
      );

  /// True if at least 1 test run was canceled.
  bool get canceled => runs.any((run) => run == TargetRunStatus.canceled);

  int get passedRuns {
    return runs.where((run) => run == TargetRunStatus.passed).length;
  }

  int get runsFailedToBuild {
    return runs.where((run) => run == TargetRunStatus.failedToBuild).length;
  }

  int get runsFailedToExecute {
    return runs.where((run) => run == TargetRunStatus.failedToExecute).length;
  }

  @override
  List<Object?> get props => [target, device, runs];
}

enum TargetRunStatus { failedToBuild, failedToExecute, passed, canceled }

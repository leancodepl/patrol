import 'package:args/command_runner.dart';
import 'package:meta/meta.dart';

/// Command which runs in 2 stages.
///
/// First, it parses input (which can come from any source – e.g file or
/// command-line arguments) into a config.
///
/// Then, it executes with the config.
///
/// This allows for clear separation of setting things up from actual business
/// logic.
abstract class StagedCommand<C> extends Command<int> {
  Future<C> configure();

  Future<int> execute(C config);

  @override
  @nonVirtual
  Future<int> run() async {
    final config = await configure();
    return execute(config);
  }
}

import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/common/logger.dart';

class LoggingDisposeScope extends DisposeScope {
  LoggingDisposeScope({
    required this.name,
    required Logger logger,
  }) : _logger = logger;

  final String name;
  final Logger _logger;

  @override
  void addDispose(Dispose dispose) {
    // TODO: implement addDispose
    super.addDispose(dispose);
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
    _logger.detail('Dissposed scope $name');
  }
}

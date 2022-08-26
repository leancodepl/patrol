import 'package:dispose_scope/dispose_scope.dart';

// TODO: Remove once package:dispose_scope get this functionality.
class StatefulDisposeScope extends DisposeScope {
  StatefulDisposeScope() : super();

  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  @override
  Future<void> dispose() {
    _isDisposed = true;
    return super.dispose();
  }

  /// Calls [block] only if this dispose scope is not disposed.
  Future<void> run(Future<void> Function(DisposeScope scope) block) async {
    if (!_isDisposed) {
      await block(this);
    }
  }

  void disposed(DisposeScope disposeScope) {
    disposeScope.addDispose(dispose);
  }
}

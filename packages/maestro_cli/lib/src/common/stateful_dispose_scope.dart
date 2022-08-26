import 'package:dispose_scope/dispose_scope.dart';

// TODO: Remove once package:dispose_scope get this functionality.
class StatefulDisposeScope extends DisposeScope {
  StatefulDisposeScope() : super();

  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  @override
  void addDispose(Dispose dispose) {
    if (isDisposed) {
      throw Exception(
        '''
Cannot add new Dispose to this dispose scope. It is already disposed.
''',
      );
    }
    super.addDispose(dispose);
  }

  @override
  Future<void> dispose() {
    if (isDisposed) {
      throw Exception(
        '''
Cannot dispose this dispose scope. It is already disposed.
''',
      );
    }

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

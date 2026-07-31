import 'dart:async';

extension CompleterExt<T> on Completer<T> {
  void maybeComplete([FutureOr<T>? value]) {
    if (!isCompleted) {
      complete(value);
    }
  }
}

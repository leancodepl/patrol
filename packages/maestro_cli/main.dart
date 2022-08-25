import 'package:async/async.dart';

Future<void> longCalculation() async {
  print('begin');
  await Future<void>.delayed(const Duration(seconds: 1));
  print('middle');
  await Future<void>.delayed(const Duration(seconds: 3));
  print('end');
}

void main() async {
  final cancellableOperation = CancelableOperation<Object?>.fromFuture(
    longCalculation(),
    onCancel: () => 'HEY HO',
  );

  await Future<void>.delayed(const Duration(seconds: 3));

  final dynamic result = await cancellableOperation.cancel();
  print('result: $result');

  print('operation canceled');
}

  // expected output:
  // begin
  // middle
  // onCancel
  // result: HEY HO
  // operation canceled

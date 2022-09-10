import 'package:test/test.dart';

final isAssertionError = isA<AssertionError>();

final throwsAssertionError = throwsA(isAssertionError);

import 'common.dart';

void main() {
  patrol('z test - first test', ($) async {
    expect(1, equals(1));
  });

  patrol('a test - second test', ($) async {
    expect(1, equals(1));
  });

  patrol('c test - third test', ($) async {
    expect(1, equals(1));
  });
}

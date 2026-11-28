import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/platform/selector.dart';

void main() {
  group('Selector', () {
    test('passes instance to the Android and iOS selectors', () {
      final selector = Selector(text: 'Google', instance: 1);

      expect(selector.android.instance, 1);
      expect(selector.ios.instance, 1);
    });

    test('leaves instance unset when not given', () {
      final selector = Selector(text: 'Google');

      expect(selector.android.instance, isNull);
      expect(selector.ios.instance, isNull);
    });
  });
}

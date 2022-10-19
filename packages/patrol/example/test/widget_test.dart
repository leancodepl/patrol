import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('is displayed', (tester) async {
    await tester.pumpWidget(ExampleApp());

    expect(find.text('Add'), findsWidgets);
  });
}

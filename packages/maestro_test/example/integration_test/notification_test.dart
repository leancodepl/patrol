import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final maestro = Maestro.forTest();

  testWidgets(
    'sends a notification',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show notification'));

      await maestro.openNotifications();
      final notifications = await maestro.getNotifications();

      for (final notification in notifications) {
        print(
          '${notification.appName}: ${notification.title}, ${notification.content}',
        );
      }

      await maestro.tapOnNotification(index: 1);
    },
  );
}

import 'package:patrol_cli/src/web/chrome_pages.dart';
import 'package:test/test.dart';

void main() {
  group('pickChromePage', () {
    final targets = <Object?>[
      {'type': 'service_worker', 'id': 'SW'},
      {'type': 'page', 'id': 'NEW_TAB'},
      {'type': 'page', 'id': 'APP'},
    ];

    test('picks the app tab when another tab is listed first', () {
      expect(pickChromePage(targets, id: 'APP')?['id'], 'APP');
    });

    test('falls back to the first page when the app tab is gone', () {
      expect(pickChromePage(targets, id: 'CLOSED')?['id'], 'NEW_TAB');
      expect(pickChromePage(targets)?['id'], 'NEW_TAB');
    });

    test('finds nothing when Chrome lists no page', () {
      expect(
        pickChromePage([
          {'type': 'iframe', 'id': 'X'},
        ]),
        isNull,
      );
    });
  });
}

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

  group('pickFrontPage', () {
    final targets = <Object?>[
      {'type': 'page', 'id': 'APP'},
      {'type': 'service_worker', 'id': 'SW'},
      {'type': 'page', 'id': 'OAUTH'},
    ];

    test('picks the tab in front, not the app tab', () {
      expect(
        pickFrontPage(targets, visibleIds: {'OAUTH'}, fallbackId: 'APP')?['id'],
        'OAUTH',
      );
    });

    test('falls back to the app tab when every page is visible', () {
      expect(
        pickFrontPage(
          targets,
          visibleIds: {'APP', 'OAUTH'},
          fallbackId: 'APP',
        )?['id'],
        'APP',
      );
    });

    test('falls back to the app tab when no page answers', () {
      expect(
        pickFrontPage(targets, visibleIds: {}, fallbackId: 'APP')?['id'],
        'APP',
      );
    });
  });
}

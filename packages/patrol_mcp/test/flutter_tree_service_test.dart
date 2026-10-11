import 'package:patrol_mcp/src/flutter_tree_service.dart';
import 'package:patrol_mcp/src/patrol_session.dart';
import 'package:test/test.dart';

void main() {
  group('FlutterTreeService.wsUri', () {
    test('appends ws to the VM service path', () {
      expect(
        FlutterTreeService.wsUri('http://127.0.0.1:61070/PKRQ6tMLkV8=/'),
        'ws://127.0.0.1:61070/PKRQ6tMLkV8=/ws',
      );
    });

    test('works without a trailing slash', () {
      expect(
        FlutterTreeService.wsUri('http://127.0.0.1:61070/PKRQ6tMLkV8='),
        'ws://127.0.0.1:61070/PKRQ6tMLkV8=/ws',
      );
    });
  });

  group('FlutterTreeService.wsUri', () {
    test('keeps a ws URI', () {
      expect(
        FlutterTreeService.wsUri('ws://127.0.0.1:61070/PKRQ6tMLkV8=/ws'),
        'ws://127.0.0.1:61070/PKRQ6tMLkV8=/ws',
      );
    });
  });

  group('vmServiceUrlFromLine', () {
    test("reads the ws URI from Patrol's DevTools line", () {
      expect(
        vmServiceUrlFromLine(
          'Patrol DevTools extension is available at '
          'http://127.0.0.1:50631/Kq_uutBFU5I=/devtools/patrol_ext'
          '?uri=ws://127.0.0.1:50631/Kq_uutBFU5I=/ws',
        ),
        'ws://127.0.0.1:50631/Kq_uutBFU5I=/ws',
      );
    });

    test("reads the URL from Flutter's VM service line", () {
      expect(
        vmServiceUrlFromLine(
          '\t: A Dart VM Service on iPhone 15 Pro is available at: '
          'http://127.0.0.1:50631/Kq_uutBFU5I=/',
        ),
        'http://127.0.0.1:50631/Kq_uutBFU5I=/',
      );
    });

    test('returns null for other lines', () {
      expect(vmServiceUrlFromLine('Restarted application in 450ms.'), isNull);
    });
  });

  test('reports a missing session instead of throwing', () async {
    final result = await FlutterTreeService.handleGetFlutterTreeRequest(null);
    expect(result.isError, isTrue);
  });
}

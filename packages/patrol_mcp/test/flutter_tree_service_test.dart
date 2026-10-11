import 'package:patrol_mcp/src/flutter_tree_service.dart';
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

  test('reports a missing session instead of throwing', () async {
    final result = await FlutterTreeService.handleGetFlutterTreeRequest(null);
    expect(result.isError, isTrue);
  });
}

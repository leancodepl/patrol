import 'package:patrol_cli/src/coverage/vm_connection_details.dart';
import 'package:test/test.dart';

void main() {
  group('tryExtractFromLogs()', () {
    test('properly parses dart vm log line', () {
      const logsLine =
          'The Dart VM service is listening on http://127.0.0.1:38423/Es4SQ9VgBGw=/';
      final details = VMConnectionDetails.tryExtractFromLogs(logsLine);
      expect(details?.port, 38423);
      expect(details?.auth, 'Es4SQ9VgBGw=');
    });

    test('properly parses dart vm log line without the trailing /', () {
      const logsLine =
          'The Dart VM service is listening on http://127.0.0.1:38423/Es4SQ9VgBGw=';
      final details = VMConnectionDetails.tryExtractFromLogs(logsLine);
      expect(details?.port, 38423);
      expect(details?.auth, 'Es4SQ9VgBGw=');
    });
  });
}

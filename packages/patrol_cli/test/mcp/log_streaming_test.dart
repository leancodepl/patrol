import 'dart:io';

import 'package:patrol_cli/src/mcp/log_streaming.dart';
import 'package:test/test.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('log_streaming_test'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('overlapping stops close the log once', () async {
    final logging = LogStreaming.instance;
    await logging.startLogging(dir.path);
    logging.writeLog('line');

    await Future.wait([logging.stopLogging(), logging.stopLogging()]);

    expect(File('${dir.path}/patrol.log').readAsStringSync(), 'line\n');
  });

  test('a start during a stop gets a log of its own', () async {
    final logging = LogStreaming.instance;
    await logging.startLogging(dir.path, logFile: '${dir.path}/first.log');

    final stopping = logging.stopLogging();
    await logging.startLogging(dir.path, logFile: '${dir.path}/second.log');
    logging.writeLog('second');
    await stopping;
    await logging.stopLogging();

    expect(File('${dir.path}/second.log').readAsStringSync(), 'second\n');
  });
}

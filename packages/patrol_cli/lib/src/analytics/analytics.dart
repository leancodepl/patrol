// ignore_for_file: implementation_imports
import 'package:unified_analytics/src/ga_client.dart';
import 'package:unified_analytics/src/utils.dart';

class Analytics {
  Analytics({
    required String measurementId,
    required String apiSecret,
  }) : _client = GAClient(
          measurementId: measurementId,
          apiSecret: apiSecret,
        );

  final GAClient _client;

  Future<void> sendEvent(
    String dimension, // FIXME: currently ignored
    String name, {
    Map<String, Object?> eventData = const {},
  }) async {
    const uuid = '3c6d9ce1-38cc-4dd0-93ae-4af7ce7a5125';

    // Construct the body of the request
    final body = _generateRequestBody(
      clientId: uuid,
      eventName: name,
      eventData: eventData,
    );

    // Pass to the google analytics client to send
    final respose = await _client.sendData(body);
    print('response: ${respose.statusCode}');
  }

  // FIXME: Implement thi
  bool get firstRun => false;

  bool _enabled = false;
  set enabled(bool newValue) {
    _enabled = newValue;
  }

  bool get enabled => _enabled;
}

/// Adapted from [generateRequestBody].
Map<String, Object?> _generateRequestBody({
  required String clientId,
  required String eventName,
  required Map<String, Object?> eventData,
}) {
  return <String, Object?>{
    'client_id': clientId,
    'events': <Map<String, Object?>>[
      <String, Object?>{
        'name': eventName,
        'params': eventData,
      }
    ],
  };
}

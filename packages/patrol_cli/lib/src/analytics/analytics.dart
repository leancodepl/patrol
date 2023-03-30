// ignore: implementation_imports
import 'package:unified_analytics/src/ga_client.dart';

class Analytics {
  Analytics({
    required this.measurementId,
    required this.appName,
  }) : _client = GAClient(
          measurementId: measurementId,
          apiSecret: 'apiSecret',
        );

  // TODO

  final String measurementId;
  final String appName;
  final GAClient _client;

  Future<void> sendEvent() {
    _client.sendData(body);
  }
}

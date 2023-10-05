// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:patrol/src/native/contracts/native_automator_client.dart';
import 'package:patrol/src/native/native_automator.dart';

class DevtoolsServiceExtensions {
  DevtoolsServiceExtensions(NativeAutomatorConfig config) {
    _client = NativeAutomatorClient(
      http.Client(),
      Uri.http('${config.host}:${config.port}'),
      timeout: config.connectionTimeout,
    );
  }

  late final NativeAutomatorClient _client;

  Future<Map<String, dynamic>> getNativeUITree(Map<String, String> parameters) {
    return _wrapRequest('getNativeUITree', () async {
      final res = await _client.getNativeUITree();
      return res.toJson();
    });
  }

  Future<Map<String, dynamic>> _wrapRequest(
    String name,
    Future<Map<String, dynamic>> Function() callback,
  ) async {
    try {
      debugPrint('Start $name');

      final res = await callback();

      debugPrint('End $name');

      return <String, dynamic>{
        'result': res,
        'success': true,
      };
    } catch (e, t) {
      return <String, dynamic>{
        'result': '$e $t',
        'success': false,
      };
    }
  }
}

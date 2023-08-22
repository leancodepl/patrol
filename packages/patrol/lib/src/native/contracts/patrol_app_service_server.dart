//
//  Generated code. Do not modify.
//  source: schema.dart
//
// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'contracts.dart';

abstract class PatrolAppServiceServer {
  FutureOr<Response?> handle(Request request) async {
    if ('listDartTests' == request.url.path) {
      final result = await listDartTests();

      final body = jsonEncode(result.toJson());
      return Response.ok(body);
    } else if ('runDartTest' == request.url.path) {
      final stringContent = await request.readAsString(utf8);
      final json = jsonDecode(stringContent);
      final requestObj =
          RunDartTestRequest.fromJson(json as Map<String, dynamic>);

      final result = await runDartTest(requestObj);

      final body = jsonEncode(result.toJson());
      return Response.ok(body);
    }

    return null;
  }

  Future<ListDartTestsResponse> listDartTests();
  Future<RunDartTestResponse> runDartTest(RunDartTestRequest request);
}

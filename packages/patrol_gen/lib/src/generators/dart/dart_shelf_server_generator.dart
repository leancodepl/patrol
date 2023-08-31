import 'package:dart_style/dart_style.dart';
import 'package:patrol_gen/src/generators/dart/dart_config.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';
import 'package:path/path.dart' as path;

class DartShelfServerGenerator {
  OutputFile generate(Service service, DartConfig config) {
    final buffer = StringBuffer()..write(_contentPrefix(config));

    final handlerCalls = _generateHandlerCalls(service);
    final handlers = _generateHandlers(service);

    buffer.write(_createServerClass(service, handlerCalls, handlers));

    return OutputFile(
      filename: config.serviceFileName(service.name),
      content: DartFormatter().format(buffer.toString()),
    );
  }

  String _contentPrefix(DartConfig config) {
    return '''
//
//  Generated code. Do not modify.
//  source: schema.dart
//
// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';

import '${path.basename(config.contractsFilename)}';
''';
  }

  String _generateHandlerCalls(Service service) {
    return service.endpoints.map((e) {
      var requestDeserialization = '';
      var responseSerialization = '';

      if (e.request != null) {
        requestDeserialization = '''
final stringContent = await request.readAsString(utf8);
final json = jsonDecode(stringContent);
final requestObj = ${e.request!.name}.fromJson(json as Map<String,dynamic>);
''';
      }

      final handlerCall = e.request != null
          ? 'final result = await ${e.name}(requestObj);'
          : 'final result = await ${e.name}();';

      if (e.response != null) {
        responseSerialization = '''
final body = jsonEncode(result.toJson());
return Response.ok(body);''';
      }

      final elseKeyword = e == service.endpoints.first ? '' : 'else';

      return '''
$elseKeyword if ('${e.name}' == request.url.path){

$requestDeserialization

$handlerCall

$responseSerialization
}''';
    }).join('\n');
  }

  String _generateHandlers(Service service) {
    return service.endpoints.map((endpoint) {
      final result = endpoint.response?.name ?? 'void';
      final request =
          endpoint.request != null ? '${endpoint.request!.name} request' : '';

      return 'Future<$result> ${endpoint.name}($request);';
    }).join('\n');
  }

  String _createServerClass(
      Service service, String handlerCalls, String handlers) {
    var notFoundRespone =
        r"return Response.notFound('Request ${request.url} not found');";
    if (service.endpoints.isNotEmpty) {
      notFoundRespone = 'else { $notFoundRespone }';
    }

    return '''
abstract class ${service.name}Server {
  FutureOr<Response> handle(Request request) async {

$handlerCalls    

$notFoundRespone
  }

$handlers
}
''';
  }
}

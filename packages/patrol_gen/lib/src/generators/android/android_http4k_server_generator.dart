import 'package:patrol_gen/src/generators/android/android_config.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class AndroidHttp4kServerGenerator {
  OutputFile generate(Service service, AndroidConfig config) {
    final buffer = StringBuffer()
      ..write(_contentPrefix(config))
      ..writeln(_createServerClass(service));

    return OutputFile(
      filename: config.serverFileName(service.name),
      content: buffer.toString(),
    );
  }

  String _contentPrefix(AndroidConfig config) {
    return '''
///
//  Generated code. Do not modify.
//  source: schema.dart
//

package ${config.package};

import com.google.gson.Gson
import org.http4k.core.Response
import org.http4k.core.Method.POST
import org.http4k.routing.bind
import org.http4k.core.Status.Companion.OK
import org.http4k.routing.routes

''';
  }

  String _createServerClass(Service service) {
    final handlers = _generateHandlers(service);
    final routes = _generateRoutes(service);

    return '''
abstract class ${service.name}Server {
$handlers

    val router = routes(
$routes
    )

    private val json = Gson()
}
''';
  }

  String _generateRoutes(Service service) {
    return service.endpoints.map((e) {
      final requestDeserialization = e.request != null
          ? '''

        val body = json.fromJson(it.bodyString(), Contracts.${e.request!.name}::class.java)'''
          : '';
      final requestArg = e.request != null ? 'body' : '';

      final responseSerialization =
          e.response != null ? '.body(json.toJson(response))' : '';

      final responseVariable = e.response != null ? 'val response = ' : '';

      return '''
      "${e.name}" bind POST to {$requestDeserialization
        $responseVariable${e.name}($requestArg)
        Response(OK)$responseSerialization
      }''';
    }).join(',\n');
  }

  String _generateHandlers(Service service) {
    return service.endpoints.map((endpoint) {
      final response = endpoint.response != null
          ? ': Contracts.${endpoint.response!.name}'
          : '';
      final request = endpoint.request != null
          ? 'request: Contracts.${endpoint.request!.name}'
          : '';

      return '    abstract fun ${endpoint.name}($request)$response';
    }).join('\n');
  }
}

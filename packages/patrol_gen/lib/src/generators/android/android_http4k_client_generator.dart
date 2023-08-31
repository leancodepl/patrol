import 'package:patrol_gen/src/generators/android/android_config.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class AndroidHttp4kClientGenerator {
  OutputFile generate(Service service, AndroidConfig config) {
    final buffer = StringBuffer()..write(_contentPrefix(config));

    buffer
      ..writeln(_generateClientClass(service))
      ..writeln()
      ..writeln(_generateExceptionClass(service));

    return OutputFile(
      filename: config.clientFileName(service.name),
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

import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.apache.hc.client5.http.config.RequestConfig
import org.apache.hc.client5.http.impl.classic.HttpClients
import org.apache.hc.core5.util.Timeout
import org.http4k.client.ApacheClient
import org.http4k.core.Method
import org.http4k.core.Request
import org.http4k.core.Status

''';
  }

  String _generateClientClass(Service service) {
    final url = r'"http://$address:$port/"';
    final endpoints = service.endpoints.map(_createEndpoint).join('\n\n');
    final throwException =
        r'throw PatrolAppServiceClientException("Invalid response ${response.status}, ${response.bodyString()}")';

    final urlWithPath = r'"$serverUrl$path"';

    return '''
class ${service.name}Client(private val address: String, private val port: Int) {

$endpoints

    private fun performRequest(path: String, requestBody: String? = null): String {
        var request = Request(Method.POST, $urlWithPath)
        if (requestBody != null) {
            request = request.body(requestBody)
        }

        val client = ApacheClient(
              HttpClients.custom().setDefaultRequestConfig(
                  RequestConfig
                    .copy(RequestConfig.DEFAULT)
                    .setResponseTimeout(Timeout.ofSeconds(300))
                    .setConnectionRequestTimeout(Timeout.ofSeconds(300))
                    .build()
              ).build())
        
        val response = client(request)

        if (response.status != Status.OK) {
            $throwException
        }

        return response.bodyString()
    }

    val serverUrl = $url

    private val json = Json { ignoreUnknownKeys = true }
}''';
  }

  String _createEndpoint(Endpoint endpoint) {
    final parameterDef = endpoint.request != null
        ? 'request: Contracts.${endpoint.request!.name}'
        : '';
    final returnDef = endpoint.response != null
        ? ': Contracts.${endpoint.response!.name}'
        : '';

    final serializeParameter =
        endpoint.request != null ? ', json.encodeToString(request)' : '';

    final body = endpoint.response != null
        ? '''
        val response = performRequest("${endpoint.name}"$serializeParameter)
        return json.decodeFromString(response)'''
        : '''
        return performRequest("${endpoint.name}"$serializeParameter)''';

    return '''
    fun ${endpoint.name}($parameterDef) $returnDef {
$body
    }''';
  }

  String _generateExceptionClass(Service service) {
    return '''
class ${service.name}ClientException(message: String) : Exception(message)''';
  }
}

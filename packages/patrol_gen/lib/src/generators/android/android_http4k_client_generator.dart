import 'package:patrol_gen/src/generators/android/android_config.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class AndroidHttp4kClientGenerator {
  OutputFile generate(Service service, AndroidConfig config) {
    final buffer = StringBuffer()
      ..write(_contentPrefix(config))
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

import com.google.gson.Gson
import com.squareup.okhttp.MediaType
import com.squareup.okhttp.OkHttpClient
import com.squareup.okhttp.Request
import com.squareup.okhttp.RequestBody
import java.util.concurrent.TimeUnit

''';
  }

  String _generateClientClass(Service service) {
    const url = r'"http://$address:$port/"';
    final endpoints = service.endpoints.map(_createEndpoint).join('\n\n');
    const throwException =
        r'throw PatrolAppServiceClientException("Invalid response ${response.code()}, ${response?.body()?.string()}")';

    const urlWithPath = r'"$serverUrl$path"';

    return '''
class ${service.name}Client(address: String, port: Int, private val timeout: Long, private val timeUnit: TimeUnit) {

$endpoints

    private fun performRequest(path: String, requestBody: String? = null): String {
        val endpoint = $urlWithPath

        val client = OkHttpClient().apply {
            setConnectTimeout(timeout, timeUnit)
            setReadTimeout(timeout, timeUnit)
            setWriteTimeout(timeout, timeUnit)
        }

        val request = Request.Builder()
            .url(endpoint)
            .also {
                if (requestBody != null) {
                    it.post(RequestBody.create(jsonMediaType, requestBody))
                }
            }
            .build()

        val response = client.newCall(request).execute()
        if (response.code() != 200) {
            $throwException
        }

        return response.body().string()
    }

    val serverUrl = $url

    private val json = Gson()

    private val jsonMediaType = MediaType.parse("application/json; charset=utf-8")
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
        endpoint.request != null ? ', json.toJson(request)' : '';

    final body = endpoint.response != null
        ? '''
        val response = performRequest("${endpoint.name}"$serializeParameter)
        return json.fromJson(response, Contracts.${endpoint.response!.name}::class.java)'''
        : '''
        performRequest("${endpoint.name}"$serializeParameter)''';

    return '''
    fun ${endpoint.name}($parameterDef)$returnDef {
$body
    }''';
  }

  String _generateExceptionClass(Service service) {
    return '''
class ${service.name}ClientException(message: String) : Exception(message)''';
  }
}

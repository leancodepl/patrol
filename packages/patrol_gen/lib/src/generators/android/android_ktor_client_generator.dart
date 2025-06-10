import 'package:patrol_gen/src/generators/android/android_config.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class AndroidKtorClientGenerator {
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
import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.serialization.gson.gson
import kotlinx.coroutines.runBlocking
import java.util.concurrent.TimeUnit

''';
  }

  String _generateClientClass(Service service) {
    const url = r'"http://$address:$port/"';
    final endpoints = service.endpoints.map(_createEndpoint).join('\n\n');
    final throwException =
        'throw ${service.name}ClientException("Invalid response \${response.status.value}, \${response.bodyAsText()}")';

    const urlWithPath = r'"$serverUrl$path"';

    return '''
class ${service.name}Client(
    private val address: String,
    private val port: Int,
    private val timeout: Long,
    private val timeUnit: TimeUnit
) {
    private val client = HttpClient(CIO) {
        install(HttpTimeout) {
            connectTimeoutMillis = timeUnit.toMillis(timeout)
            requestTimeoutMillis = timeUnit.toMillis(timeout)
            socketTimeoutMillis = timeUnit.toMillis(timeout)
        }
        install(ContentNegotiation) {
            gson()
        }
    }

    private val json = Gson()
    val serverUrl = $url

$endpoints

    private fun performRequest(path: String, requestBody: String? = null): String = runBlocking {
        val endpoint = $urlWithPath

        val response = client.request(endpoint) {
            method = if (requestBody != null) HttpMethod.Post else HttpMethod.Get
            if (requestBody != null) {
                contentType(ContentType.Application.Json)
                setBody(requestBody)
            }
        }

        if (response.status.value != 200) {
            $throwException
        }

        response.bodyAsText()
    }
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

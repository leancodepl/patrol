///
//  Generated code. Do not modify.
//  source: schema.dart
//

package pl.leancode.patrol.contracts;

import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.apache.hc.client5.http.config.RequestConfig
import org.apache.hc.client5.http.impl.classic.HttpClients
import org.apache.hc.core5.util.Timeout
import org.http4k.client.ApacheClient
import org.http4k.core.Method
import org.http4k.core.Request
import org.http4k.core.Status

class PatrolAppServiceClient(private val address: String, private val port: Int) {

    fun listDartTests() : Contracts.ListDartTestsResponse {
        val response = performRequest("listDartTests")
        return json.decodeFromString(response)
    }

    fun runDartTest(request: Contracts.RunDartTestRequest) : Contracts.RunDartTestResponse {
        val response = performRequest("runDartTest", json.encodeToString(request))
        return json.decodeFromString(response)
    }

    private fun performRequest(path: String, requestBody: String? = null): String {
        var request = Request(Method.POST, "$serverUrl$path")
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
            throw PatrolAppServiceClientException("Invalid response ${response.status}, ${response.bodyString()}")
        }

        return response.bodyString()
    }

    val serverUrl = "http://$address:$port/"

    private val json = Json { ignoreUnknownKeys = true }
}

class PatrolAppServiceClientException(message: String) : Exception(message)

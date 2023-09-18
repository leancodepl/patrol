///
//  Generated code. Do not modify.
//  source: schema.dart
//

package pl.leancode.patrol.contracts;

import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import okhttp3.OkHttpClient
import okio.Timeout
import org.http4k.client.OkHttp
//import org.apache.hc.client5.http.config.RequestConfig
//import org.apache.hc.client5.http.impl.classic.HttpClients
//import org.apache.hc.core5.util.Timeout
// import org.http4k.client.ApacheClient
import org.http4k.core.Method
import org.http4k.core.Request
import org.http4k.core.Status
import org.http4k.metrics.MetricsDefaults.Companion.client
import java.time.Duration

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

        // FIXME: Figure out how to add timeouts (java.time is API 26+ only)
        val okHttpClient = OkHttp(OkHttpClient.Builder()
            .build()
        )
        
        val response = okHttpClient (request)

        if (response.status != Status.OK) {
            throw PatrolAppServiceClientException("Invalid response ${response.status}, ${response.bodyString()}")
        }

        return response.bodyString()
    }

    val serverUrl = "http://$address:$port/"

    private val json = Json { ignoreUnknownKeys = true }
}

class PatrolAppServiceClientException(message: String) : Exception(message)

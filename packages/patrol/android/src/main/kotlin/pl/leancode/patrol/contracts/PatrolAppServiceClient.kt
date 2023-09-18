///
//  Generated code. Do not modify.
//  source: schema.dart
//

package pl.leancode.patrol.contracts;

import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.http4k.client.JavaHttpClient
import org.http4k.core.HttpHandler
import org.http4k.core.Method
import org.http4k.core.Request
import org.http4k.core.Status
import org.http4k.core.then
import org.http4k.filter.DebuggingFilters.PrintResponse
//import okhttp3.OkHttpClient
//import org.http4k.client.OkHttp
//import org.http4k.core.Method
//import org.http4k.core.Request
//import org.http4k.core.Status
import java.time.Duration
import java.util.concurrent.TimeUnit

class PatrolAppServiceClient(address: String, port: Int, private val timeout: Long, private val timeUnit: TimeUnit) {

    fun listDartTests(): Contracts.ListDartTestsResponse {
        val response = performRequest("listDartTests")
        return json.decodeFromString(response)
    }

    fun runDartTest(request: Contracts.RunDartTestRequest): Contracts.RunDartTestResponse {
        val response = performRequest("runDartTest", json.encodeToString(request))
        return json.decodeFromString(response)
    }

    private fun performRequest(path: String, requestBody: String? = null): String {
        var request = Request(Method.POST, "$serverUrl$path")
        if (requestBody != null) {
            request = request.body(requestBody)
        }

        val client = JavaHttpClient()

        // val printingClient = PrintResponse().then(client)

//        val okHttpClient = OkHttp(
//            OkHttpClient.Builder()
//                .connectTimeout(timeout, timeUnit)
//                .readTimeout(timeout, timeUnit)
//                .writeTimeout(timeout, timeUnit)
//                .callTimeout(timeout, timeUnit)
//                .build()
//        )

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

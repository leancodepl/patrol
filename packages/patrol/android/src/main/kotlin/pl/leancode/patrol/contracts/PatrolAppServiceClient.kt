///
//  Generated code. Do not modify.
//  source: schema.dart
//

package pl.leancode.patrol.contracts;


import com.squareup.okhttp.MediaType
import com.squareup.okhttp.OkHttpClient
import com.squareup.okhttp.Request
import com.squareup.okhttp.RequestBody
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
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
        val endpoint = "$serverUrl$path"

        val client = OkHttpClient().apply {
            setConnectTimeout(timeout, timeUnit)
            setReadTimeout(timeout, timeUnit)
            setWriteTimeout(timeout, timeUnit)
            // setCallTimeout(timeout, timeUnit) // not available in OkHttp 2
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
            throw PatrolAppServiceClientException("Invalid response ${response.code()}, ${response?.body()?.string()}")
        }

        return response.body().string()
    }

    val serverUrl = "http://$address:$port/"

    private val json = Json { ignoreUnknownKeys = true }

    private val jsonMediaType = MediaType.parse("application/json; charset=utf-8")
}

class PatrolAppServiceClientException(message: String) : Exception(message)

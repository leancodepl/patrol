///
//  Generated code. Do not modify.
//  source: schema.dart
//

package pl.leancode.patrol.contracts;

import com.google.gson.Gson
import com.squareup.okhttp.MediaType
import com.squareup.okhttp.OkHttpClient
import com.squareup.okhttp.Request
import com.squareup.okhttp.RequestBody
import java.util.concurrent.TimeUnit

class PatrolAppServiceClient(address: String, port: Int, private val timeout: Long, private val timeUnit: TimeUnit) {

    fun listDartTests(): Contracts.ListDartTestsResponse {
        val response = performRequest("listDartTests")
        return json.fromJson(response, Contracts.ListDartTestsResponse::class.java)
    }

    fun runDartTest(request: Contracts.RunDartTestRequest): Contracts.RunDartTestResponse {
        val response = performRequest("runDartTest", json.toJson(request))
        return json.fromJson(response, Contracts.RunDartTestResponse::class.java)
    }

    private fun performRequest(path: String, requestBody: String? = null): String {
        val endpoint = "$serverUrl$path"

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
            throw PatrolAppServiceClientException("Invalid response ${response.code()}, ${response?.body()?.string()}")
        }

        return response.body().string()
    }

    val serverUrl = "http://$address:$port/"

    private val json = Gson()

    private val jsonMediaType = MediaType.parse("application/json; charset=utf-8")
}

class PatrolAppServiceClientException(message: String) : Exception(message)

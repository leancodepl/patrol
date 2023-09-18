///
//  Generated code. Do not modify.
//  source: schema.dart
//

package pl.leancode.patrol.contracts;

import com.github.kittinunf.fuel.httpPost
import com.github.kittinunf.result.Result
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

        val (_, response, result) = endpoint
            .httpPost()
            .also {
                if (requestBody != null) {
                    it.body(requestBody)
                }
            }
            .responseString()

        when (result) {
            is Result.Failure -> {
                val ex = result.getException()
                println(ex)
            }

            is Result.Success -> {
                val data = result.get()
                println(data)
            }
        }

        println("response: $response")

        val bodyString = response.body().asString(null)

        if (response.statusCode != 200) {
            throw PatrolAppServiceClientException("Invalid response ${response.statusCode}, $bodyString")
        }

        return bodyString
    }

    val serverUrl = "http://$address:$port/"

    private val json = Json { ignoreUnknownKeys = true }
}

class PatrolAppServiceClientException(message: String) : Exception(message)

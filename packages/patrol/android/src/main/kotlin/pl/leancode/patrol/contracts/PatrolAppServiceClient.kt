///
//  Generated code. Do not modify.
//  source: schema.dart
//

package pl.leancode.patrol.contracts;

import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.http4k.client.ApacheClient
import org.http4k.core.Method
import org.http4k.core.Request
import org.http4k.core.Status

class PatrolAppServiceClient(private val address: String, private val port: Int) {

    fun listDartTests() : Contracts.ListDartTestsResponse {
        val response = performRequest()
        return json.decodeFromString(response)
    }

    fun runDartTest(request: Contracts.RunDartTestRequest) : Contracts.RunDartTestResponse {
        val response = performRequest(json.encodeToString(request))
        return json.decodeFromString(response)
    }

    private fun performRequest(requestBody: String? = null): String {
        var request = Request(Method.POST, serverUrl)
        if (requestBody != null) {
            request = request.body(requestBody)
        }

        val client = ApacheClient()
        val response = client(request)

        if (response.status != Status.OK) {
            throw PatrolAppServiceClientException("Invalid response ${response.status}")
        }

        return response.bodyString()
    }

    val serverUrl = "http://$address:$port"

    private val json = Json { ignoreUnknownKeys = true }
}

class PatrolAppServiceClientException(message: String) : Exception(message)

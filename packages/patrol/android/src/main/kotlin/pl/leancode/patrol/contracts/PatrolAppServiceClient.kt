///
//  Generated code. Do not modify.
//  source: schema.dart
//

package pl.leancode.patrol.contracts;

import com.google.gson.Gson
import io.ktor.client.HttpClient
import io.ktor.client.engine.cio.CIO
import io.ktor.client.plugins.HttpTimeout
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.request
import io.ktor.client.request.setBody
import io.ktor.client.statement.bodyAsText
import io.ktor.http.ContentType
import io.ktor.http.HttpMethod
import io.ktor.http.contentType
import io.ktor.serialization.gson.gson
import kotlinx.coroutines.runBlocking
import java.util.concurrent.TimeUnit

class PatrolAppServiceClient(
    private val address: String,
    private val port: Int,
    private val timeout: Long,
    private val timeUnit: TimeUnit
) : AutoCloseable {
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
    val serverUrl = "http://$address:$port/"

    fun listDartTests(): Contracts.ListDartTestsResponse {
        val response = performRequest("listDartTests")
        return json.fromJson(response, Contracts.ListDartTestsResponse::class.java)
    }

    fun runDartTest(request: Contracts.RunDartTestRequest): Contracts.RunDartTestResponse {
        val response = performRequest("runDartTest", json.toJson(request))
        return json.fromJson(response, Contracts.RunDartTestResponse::class.java)
    }

    private fun performRequest(path: String, requestBody: String? = null): String = runBlocking {
        val endpoint = "$serverUrl$path"

        val response = client.request(endpoint) {
            method = if (requestBody != null) HttpMethod.Post else HttpMethod.Get
            if (requestBody != null) {
                contentType(ContentType.Application.Json)
                setBody(requestBody)
            }
        }

        if (response.status.value != 200) {
            throw PatrolAppServiceClientException("Invalid response ${response.status.value}, ${response.bodyAsText()}")
        }

        response.bodyAsText()
    }

    override fun close() {
        client.close()
    }
}

class PatrolAppServiceClientException(message: String) : Exception(message)

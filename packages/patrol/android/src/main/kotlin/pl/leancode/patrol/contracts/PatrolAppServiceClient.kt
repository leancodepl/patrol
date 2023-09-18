///
//  Generated code. Do not modify.
//  source: schema.dart
//

package pl.leancode.patrol.contracts;

import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.io.BufferedReader
import java.io.IOException
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.nio.charset.StandardCharsets


class PatrolAppServiceClient(private val address: String, private val port: Int) {

    fun listDartTests(): Contracts.ListDartTestsResponse {
        val response = performRequest("listDartTests")
        return json.decodeFromString(response)
    }

    fun runDartTest(request: Contracts.RunDartTestRequest): Contracts.RunDartTestResponse {
        val response = performRequest("runDartTest", json.encodeToString(request))
        return json.decodeFromString(response)
    }

    private fun performRequest(path: String, requestBody: String = ""): String {
        val endpoint = "$serverUrl$path"

        var urlConnection: HttpURLConnection? = null
        try {
            val url = URL(endpoint)
            urlConnection = url.openConnection() as HttpURLConnection

            // Set request properties
            urlConnection.setRequestMethod("POST")
            urlConnection.setRequestProperty("Content-Type", "application/json")

            // Create request body
            val postData = requestBody.toByteArray(StandardCharsets.UTF_8)
            val postDataLength = postData.size
            urlConnection.setDoOutput(true)
            urlConnection.instanceFollowRedirects = false
            urlConnection.setRequestProperty("Content-Length", postDataLength.toString())
            urlConnection.outputStream.write(postData)

            // Read the response
            val responseCode = urlConnection.getResponseCode()
            if (responseCode != 200) {
                throw PatrolAppServiceClientException("Invalid response $responseCode")
            }

            val reader = BufferedReader(InputStreamReader(urlConnection.inputStream))
            val response = StringBuilder()
            var line: String?
            while (reader.readLine().also { line = it } != null) {
                response.append(line)
            }
            reader.close()
            val responseData = response.toString()
            println("Response: $responseData")
            return responseData
        } catch (e: IOException) {
            e.printStackTrace()
        } finally {
            urlConnection?.disconnect()
        }


        throw PatrolAppServiceClientException("something bad hapened!")
    }

    val serverUrl = "http://$address:$port/"

    private val json = Json { ignoreUnknownKeys = true }
}

class PatrolAppServiceClientException(message: String) : Exception(message)

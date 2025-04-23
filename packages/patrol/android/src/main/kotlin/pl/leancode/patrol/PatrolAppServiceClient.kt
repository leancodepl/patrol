package pl.leancode.patrol

import pl.leancode.patrol.contracts.Contracts
import pl.leancode.patrol.contracts.PatrolAppServiceClientException
import java.util.concurrent.TimeUnit
import pl.leancode.patrol.contracts.PatrolAppServiceClient as Client

/**
 * Enables querying Dart tests, running them, waiting for them to finish, and getting their results
 */
class PatrolAppServiceClient {

    private var client: Client

    // https://github.com/leancodepl/patrol/issues/1683
    private val timeout = 2L
    private val timeUnit = TimeUnit.HOURS

    constructor(port: Int) {
        client = Client(address = "localhost", port = port, timeout = timeout, timeUnit = timeUnit)
        Logger.i("Created PatrolAppServiceClient: ${client.serverUrl}")
    }

    constructor(address: String, port: Int) {
        client = Client(address = address, port = port, timeout = timeout, timeUnit = timeUnit)
        Logger.i("Created PatrolAppServiceClient: ${client.serverUrl}")
    }

    @Throws(PatrolAppServiceClientException::class)
    fun listDartTests(): Contracts.DartGroupEntry {
        Logger.i("PatrolAppServiceClient.listDartTests()")
        val result = client.listDartTests()
        return result.group
    }

    @Throws(PatrolAppServiceClientException::class)
    fun runDartTest(name: String): Contracts.RunDartTestResponse {
        Logger.i("PatrolAppServiceClient.runDartTest($name)")
        return client.runDartTest(Contracts.RunDartTestRequest(name))
    }
}

package pl.leancode.patrol;

import pl.leancode.patrol.contracts.Contracts
import pl.leancode.patrol.contracts.PatrolAppServiceClientException
import pl.leancode.patrol.contracts.PatrolAppServiceClient as Client

/**
 * Enables querying Dart tests, running them, waiting for them to finish, and getting their results
 */
class PatrolAppServiceClient {

    private var client: Client

    constructor() {
        client = Client(address = "localhost", port = 8082)
        Logger.i("Created PatrolAppServiceClient: ${client.serverUrl}")
    }

    constructor(address: String) {
        client = Client(address = address, port = 8082)
        Logger.i("Created PatrolAppServiceClient: ${client.serverUrl}")
    }

    @Throws(PatrolAppServiceClientException::class)
    fun listDartTests(): Contracts.DartTestGroup {
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
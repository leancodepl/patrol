package pl.leancode.patrol

import pl.leancode.patrol.contracts.Contracts
import pl.leancode.patrol.contracts.PatrolAppServiceClientException
import java.util.concurrent.TimeUnit
import pl.leancode.patrol.contracts.PatrolAppServiceClient as Client

/**
 * Enables querying Dart tests, running them, waiting for them to finish, and getting their results
 */
class PatrolAppServiceClient(private val address: String) {

    // https://github.com/leancodepl/patrol/issues/1683
    private val timeout = 2L
    private val timeUnit = TimeUnit.HOURS

    // The connection is created on first use. By then the app has reported its readiness,
    // and with it the port its PatrolAppService listens on.
    private val lazyClient = lazy {
        Client(address = address, port = port, timeout = timeout, timeUnit = timeUnit).also {
            Logger.i("Created PatrolAppServiceClient: ${it.serverUrl}")
        }
    }
    private val client: Client
        get() = lazyClient.value

    private val defaultPort = 8082

    /**
     * The port reported by the app's Flutter engine. Falls back to the build-time port
     * for an engine that did not report one.
     */
    val port: Int
        get() {
            PatrolEngines.appServicePort?.let { return it }

            val portStr = patrolBuildConfigString("PATROL_APP_PORT")
            if (portStr == null) {
                Logger.i("PATROL_APP_PORT is null, falling back to default ($defaultPort)")
                return defaultPort
            }
            return portStr.toIntOrNull() ?: run {
                Logger.i("PATROL_APP_PORT is not a valid integer, falling back to default ($defaultPort)")
                defaultPort
            }
        }

    constructor() : this("localhost")

    @Throws(PatrolAppServiceClientException::class)
    fun listDartTests(): Contracts.DartGroupEntry {
        Logger.i("PatrolAppServiceClient.listDartTests()")
        val result = client.listDartTests()
        return result.group
    }

    @Throws(PatrolAppServiceClientException::class)
    fun runDartTest(name: String): Contracts.RunDartTestResponse {
        return runDartTest(name, null, false)
    }

    /**
     * Runs [phaseIndex] of the Dart test [name], or the test from its start if it is null.
     * [engineRestarted] tells the app that the runner attached to a new Flutter engine.
     */
    @Throws(PatrolAppServiceClientException::class)
    fun runDartTest(
        name: String,
        phaseIndex: Long?,
        engineRestarted: Boolean
    ): Contracts.RunDartTestResponse {
        Logger.i(
            "PatrolAppServiceClient.runDartTest($name, phaseIndex=$phaseIndex, " +
                "engineRestarted=$engineRestarted)"
        )
        return client.runDartTest(
            Contracts.RunDartTestRequest(
                name,
                phaseIndex,
                if (engineRestarted) true else null
            )
        )
    }

    fun close() {
        if (lazyClient.isInitialized()) {
            client.close()
        }
    }
}

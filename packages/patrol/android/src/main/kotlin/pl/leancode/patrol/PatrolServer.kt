package pl.leancode.patrol

import android.os.ConditionVariable
import org.http4k.core.ContentType
import org.http4k.filter.ServerFilters
import org.http4k.server.Http4kServer
import org.http4k.server.KtorCIO
import org.http4k.server.asServer

class PatrolServer {
    private val defaultPort = 8081

    private var server: Http4kServer? = null
    private var automatorServer: AutomatorServer? = null

    val port: Int
        get() {
            val portStr = BuildConfig.PATROL_TEST_PORT
            if (portStr == null) {
                Logger.i("PATROL_TEST_PORT is null, falling back to default ($defaultPort)")
                return defaultPort
            }
            return portStr.toIntOrNull() ?: run {
                Logger.i("PATROL_TEST_PORT is not a valid integer, falling back to default ($defaultPort)")
                defaultPort
            }
        }

    fun start() {
        Logger.i("Starting server...")

        automatorServer = AutomatorServer(Automator.instance)
        server = automatorServer!!.router
            .withFilter(catcher)
            .withFilter(printer)
            .withFilter(ServerFilters.SetContentType(ContentType.TEXT_PLAIN))
            .asServer(KtorCIO(port))
            .start()

        Logger.i("Created and started PatrolServer, port: $port")

        Runtime.getRuntime().addShutdownHook(
            Thread {
                Logger.i("Stopping server...")
                server?.close()
                Logger.i("Server stopped")
            }
        )
    }

    companion object {
        val appReady: ConditionVariable = ConditionVariable()
    }
}

typealias DartTestResults = Map<String, String>

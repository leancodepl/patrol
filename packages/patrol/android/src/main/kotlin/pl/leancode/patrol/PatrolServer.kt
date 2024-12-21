package pl.leancode.patrol

import android.os.ConditionVariable
import io.ktor.server.engine.ApplicationEngineEnvironment
import org.http4k.core.ContentType
import org.http4k.filter.ServerFilters
import org.http4k.server.Http4kServer
import org.http4k.server.KtorCIO
import org.http4k.server.asServer
import java.net.ServerSocket

class PatrolServer {
    private var server: Http4kServer? = null
    private var automatorServer: AutomatorServer? = null
    var port: Int? = null

    fun start() {
        Logger.i("Starting server...")

        port = BuildConfig.PATROL_TEST_PORT.toIntOrNull() ?: getFreePort()

        automatorServer = AutomatorServer(Automator.instance)

        server = automatorServer!!.router
            .withFilter(catcher)
            .withFilter(printer)
            .withFilter(ServerFilters.SetContentType(ContentType.TEXT_PLAIN))
            .asServer(KtorCIO(port!!))
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
        var appServerPort: Int? = null
    }

    private fun getFreePort() = ServerSocket(0).use { it.localPort }

}

typealias DartTestResults = Map<String, String>

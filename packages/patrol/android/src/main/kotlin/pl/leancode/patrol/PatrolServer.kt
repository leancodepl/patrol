package pl.leancode.patrol

import android.os.ConditionVariable
import kotlinx.coroutines.runBlocking
import org.http4k.core.ContentType
import org.http4k.filter.ServerFilters
import org.http4k.server.Http4kServer
import org.http4k.server.KtorCIO
import org.http4k.server.asServer

class PatrolServer {
    private var server: Http4kServer? = null
    private var automatorServer: AutomatorServer? = null
    var port: Int? = null

    fun start() {
        Logger.i("Starting server...")

        automatorServer = AutomatorServer(Automator.instance)
        server = automatorServer!!.router
            .withFilter(catcher)
            .withFilter(printer)
            .withFilter(ServerFilters.SetContentType(ContentType.TEXT_PLAIN))
            .asServer(KtorCIO(8081))
            .start()


        port = server!!.port()

        Logger.i("Created and started PatrolServer, port: ${server!!.port()}")

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

}

typealias DartTestResults = Map<String, String>

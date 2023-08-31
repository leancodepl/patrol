package pl.leancode.patrol

import androidx.test.platform.app.InstrumentationRegistry
import org.http4k.core.ContentType
import org.http4k.filter.ServerFilters
import org.http4k.server.Http4kServer
import org.http4k.server.Netty
import org.http4k.server.asServer
import java.util.concurrent.Future
import com.google.common.util.concurrent.SettableFuture;

class PatrolServer {
    private val envPortKey = "PATROL_PORT"
    private val port: Int
    private var server: Http4kServer? = null
    private var automatorServer: AutomatorServer? = null

    init {
        port = arguments.getString(envPortKey)?.toInt() ?: 8081
    }

    private val arguments get() = InstrumentationRegistry.getArguments()

    fun start() {
        Logger.i("Starting server...")

        automatorServer = AutomatorServer(Automator.instance)
        server = automatorServer!!.router
            .withFilter(catcher)
            .withFilter(printer)
            .withFilter(ServerFilters.SetContentType(ContentType.TEXT_PLAIN))
            .asServer(Netty(port))

        server?.start()
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
        val appReady: SettableFuture<Boolean> = SettableFuture.create()
        val appReadyFuture: Future<Boolean>
            get() = appReady
    }
}

typealias DartTestResults = Map<String, String>

package pl.leancode.patrol

import android.os.ConditionVariable
import org.http4k.core.ContentType
import org.http4k.filter.ServerFilters
import org.http4k.routing.RoutingHttpHandler
import org.http4k.routing.routes
import org.http4k.server.Http4kServer
import org.http4k.server.KtorCIO
import org.http4k.server.asServer
import java.util.concurrent.atomic.AtomicInteger

class PatrolServer {
    private val defaultPort = 8081

    private var server: Http4kServer? = null
    private var automatorServer: AutomatorServer? = null

    val port: Int
        get() {
            val portStr = patrolBuildConfigString("PATROL_TEST_PORT")
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

        val automator = AutomatorServer(Automator.instance)
        automatorServer = automator

        // Discover optional extension packages and mount their routes on the same server.
        val extensions = PatrolServerExtensions.discover()
        extensions.forEach { Logger.i("Loaded Patrol server extension: ${it.name}") }

        val extensionRoutes = extensions.map { it.routes() }
        val allRoutes = ArrayList<RoutingHttpHandler>(1 + extensionRoutes.size)
        allRoutes.add(automator.router)
        allRoutes.addAll(extensionRoutes)

        server = routes(*(allRoutes.toTypedArray()))
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

        /**
         * How many times PatrolAppService reported its readiness. Every Flutter engine
         * reports once, so a change during a test means the app restarted its engine.
         */
        val engineGeneration: AtomicInteger = AtomicInteger()

        /**
         * The port PatrolAppService listens on in the Flutter engine that reported its
         * readiness last, or null if the engine did not report one.
         */
        @Volatile
        var appServicePort: Int? = null
    }
}

typealias DartTestResults = Map<String, String>

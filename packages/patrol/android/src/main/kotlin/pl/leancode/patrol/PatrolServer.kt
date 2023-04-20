package pl.leancode.patrol

import androidx.test.platform.app.InstrumentationRegistry
import com.google.common.util.concurrent.SettableFuture
import io.grpc.InsecureServerCredentials
import io.grpc.Server
import io.grpc.okhttp.OkHttpServerBuilder
import java.util.concurrent.Future

class PatrolServer {
    private val envPortKey = "PATROL_PORT"
    private val port: Int
    private var server: Server? = null

    init {
        port = arguments.getString(envPortKey)?.toInt() ?: 8081
        server = OkHttpServerBuilder
            .forPort(port, InsecureServerCredentials.create())
            .intercept(LoggerInterceptor())
            .addService(AutomatorServer(automation = Automator.instance))
            .build()
    }

    private val arguments get() = InstrumentationRegistry.getArguments()

    fun start() {
        server?.start()
        Logger.i("Created and started PatrolServer, port: $port")

        Runtime.getRuntime().addShutdownHook(
            Thread {
                Logger.i("Stopping server...")
                server?.shutdown()
                Logger.i("Server stopped")
            }
        )
    }

    fun blockUntilShutdown() {
        server?.awaitTermination()
    }

    companion object {
        val appReady: SettableFuture<Boolean> = SettableFuture.create()
        val appReadyFuture: Future<Boolean>
            get() = appReady
    }
}

typealias DartTestResults = Map<String, String>

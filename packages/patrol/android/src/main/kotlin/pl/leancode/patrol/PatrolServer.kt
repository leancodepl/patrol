package pl.leancode.patrol

import androidx.test.platform.app.InstrumentationRegistry
import com.google.common.util.concurrent.SettableFuture
import io.grpc.InsecureServerCredentials
import io.grpc.Server
import io.grpc.okhttp.OkHttpServerBuilder

class PatrolServer {
    private val envPortKey = "PATROL_PORT"
    private val port: Int
    private var server: Server? = null

    init {
        port = arguments.getString(envPortKey)?.toInt() ?: 8081
        server = OkHttpServerBuilder
            .forPort(port, InsecureServerCredentials.create())
            .intercept(LoggerInterceptor())
            .addService(
                AutomatorServer(
                    automation = Automator.instance,
                    onTestResultsSubmitted = { testResulsSettable.set(it) }
                )
            )
            .build()
    }

    private val arguments get() = InstrumentationRegistry.getArguments()

    fun start() {
        Logger.i("Starting server...")
        server?.start()
        Logger.i("Server started on http://localhost:$port")

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
        private val testResulsSettable: SettableFuture<DartTestResults> = SettableFuture.create()
        val testResults
            get() = testResulsSettable
    }
}

typealias DartTestResults = Map<String, String>

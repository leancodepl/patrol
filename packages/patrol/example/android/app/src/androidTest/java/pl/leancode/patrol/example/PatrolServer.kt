package pl.leancode.patrol.example

import androidx.test.platform.app.InstrumentationRegistry
import io.grpc.Server
import io.grpc.netty.NettyServerBuilder

class PatrolServer {
    private val envPortKey = "PATROL_PORT"
    private val port: Int
    private val server: Server

    init {
        port = arguments.getString(envPortKey)?.toInt() ?: 8081
        server = NettyServerBuilder
            .forPort(port)
            .intercept(LoggerInterceptor())
            .addService(NativeAutomatorServer())
            .build()
    }

    private val arguments get() = InstrumentationRegistry.getArguments()

    fun start() {
        Logger.i("Starting server...")
        server.start()
        Logger.i("Server started on http://localhost:$port")

        Runtime.getRuntime().addShutdownHook(
            Thread {
                Logger.i("Stopping server...")
                server.shutdown()
                Logger.i("Server stopped")
            }
        )
    }

    fun blockUntilShutdown() {
        server.awaitTermination()
    }
}

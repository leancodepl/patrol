package pl.leancode.automatorserver

import com.orhanobut.logger.Logger
import org.http4k.core.Method
import org.http4k.core.Response
import org.http4k.core.Status.Companion.OK
import org.http4k.routing.bind
import org.http4k.routing.routes
import org.http4k.server.Http4kServer
import org.http4k.server.Netty
import org.http4k.server.asServer
import java.util.*
import kotlin.concurrent.schedule

class ServerInstrumentation {
    var isStopped = false
    var server: Http4kServer? = null

    fun startServer() {
        val app = routes(
            "healthCheck" bind Method.GET to {
                Logger.i("Health check")
                Response(OK)
            },
            "stop" bind Method.POST to {
                Logger.i("Stopping server")
                stopServer()
                Response(OK)
            },
            "pressHome" bind Method.POST to {
                UIAutomatorInstrumentation.instance.pressHome()
                Response(OK)
            },
            "pressRecentApps" bind Method.POST to {
                UIAutomatorInstrumentation.instance.pressRecentApps()
                Response(OK)
            },
            "pressDoubleRecentApps" bind Method.POST to {
                UIAutomatorInstrumentation.instance.pressDoubleRecentApps()
                Response(OK)
            },
        )
        server = app.asServer(Netty(8081)).start()
    }

    private fun stopServer() {
        Timer("SettingUp", false).schedule(1000) {
            server?.stop()
            isStopped = true
        }
    }

    companion object {
        val instance = ServerInstrumentation()
    }
}

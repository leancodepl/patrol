package pl.leancode.automatorserver

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
    var running = false
    var server: Http4kServer? = null

    fun start() {
        running = true

        val app = routes(
            "healthCheck" bind Method.GET to {
                Logger.i("Health check")
                Response(OK).body("All is good.")
            },
            "stop" bind Method.POST to {
                Logger.i("Stopping server")
                stop()
                Response(OK).body("Server stopped")
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
            "openNotifications" bind Method.POST to {
                UIAutomatorInstrumentation.instance.openNotifications()
                Response(OK)
            },
            "nativeTextField" bind Method.GET to {
                UIAutomatorInstrumentation.instance.getNativeTextField()
                Response(OK)
            },
            "nativeTextField" bind Method.POST to {
                val text = it.bodyString()
                UIAutomatorInstrumentation.instance.setNativeTextField(text)
                Response(OK)
            }
        )
        server = app.asServer(Netty(8081)).start()
    }

    private fun stop() {
        Timer("SettingUp", false).schedule(1000) {
            server?.stop()
            running = false
        }
    }

    companion object {
        val instance = ServerInstrumentation()
    }
}

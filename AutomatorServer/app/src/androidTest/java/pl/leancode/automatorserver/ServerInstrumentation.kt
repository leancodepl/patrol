package pl.leancode.automatorserver

import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
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
import kotlinx.serialization.json.*
import org.http4k.core.Body

@Serializable
data class GetNativeTextField(val index: Int? = null)

@Serializable
data class SetNativeTextField(val index: Int, val text: String)

@Serializable
data class SetNativeButton(val index: Int)


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
                val reqBody = Json.decodeFromString<GetNativeTextField>(it.bodyString())

                if (reqBody.index == null) {
                    val textFields = UIAutomatorInstrumentation.instance.getNativeTextFields()
                    Response(OK).body(Json.encodeToString(textFields))
                } else {
                    val textField =
                        UIAutomatorInstrumentation.instance.getNativeTextField(reqBody.index)
                    Response(OK).body(Json.encodeToString(textField))
                }
            },
            "nativeTextField" bind Method.POST to {
                val data = Json.decodeFromString<SetNativeTextField>(it.bodyString())

                UIAutomatorInstrumentation.instance.setNativeTextField(data.index, data.text)
                Response(OK)
            },
            "nativeButton" bind Method.POST to {
                val data = Json.decodeFromString<SetNativeButton>(it.bodyString())

                UIAutomatorInstrumentation.instance.setNativeButton(data.index)
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

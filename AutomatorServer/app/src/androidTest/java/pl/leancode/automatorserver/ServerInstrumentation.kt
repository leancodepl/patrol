package pl.leancode.automatorserver

import androidx.test.uiautomator.UiObjectNotFoundException
import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString

import org.http4k.core.Response
import org.http4k.core.Status.Companion.OK
import org.http4k.routing.bind
import org.http4k.routing.routes
import org.http4k.server.Http4kServer
import org.http4k.server.Netty
import org.http4k.server.asServer


import kotlin.concurrent.schedule
import kotlinx.serialization.json.*
import org.http4k.core.Method.*
import org.http4k.core.Status.Companion.BAD_REQUEST
import org.http4k.core.Status.Companion.INTERNAL_SERVER_ERROR
import org.http4k.core.Status.Companion.NOT_FOUND
import java.util.*
import kotlin.Exception

@Serializable
data class GetNativeTextField(val index: Int? = null)

@Serializable
data class SetNativeTextField(val index: Int, val text: String)

@Serializable
data class GetNativeButton(val index: Int? = null)

@Serializable
data class SetNativeButton(val index: Int)


class ServerInstrumentation {
    var running = false
    var server: Http4kServer? = null

    fun start() {
        running = true

        val app = routes(
            "healthCheck" bind GET to {
                Logger.i("Health check")
                Response(OK).body("All is good.")
            },
            "stop" bind POST to {
                Logger.i("Stopping server")
                stop()
                Response(OK).body("Server stopped")
            },
            "pressBack" bind POST to {
                UIAutomatorInstrumentation.instance.pressBack()
                Response(OK)
            },
            "pressHome" bind POST to {
                UIAutomatorInstrumentation.instance.pressHome()
                Response(OK)
            },
            "pressRecentApps" bind POST to {
                UIAutomatorInstrumentation.instance.pressRecentApps()
                Response(OK)
            },
            "pressDoubleRecentApps" bind POST to {
                UIAutomatorInstrumentation.instance.pressDoubleRecentApps()
                Response(OK)
            },
            "openNotifications" bind POST to {
                UIAutomatorInstrumentation.instance.openNotifications()
                Response(OK)
            },

            // TextFields
            "nativeTextField" bind GET to {
                val reqBody = try {
                    Json.decodeFromString<GetNativeTextField>(it.bodyString())
                } catch (err: Exception) {
                    return@to Response(BAD_REQUEST)
                }

                if (reqBody.index == null) {
                    val textFields = UIAutomatorInstrumentation.instance.getNativeTextFields()
                    Response(OK).body(Json.encodeToString(textFields))
                } else {
                    val textField =
                        UIAutomatorInstrumentation.instance.getNativeTextField(reqBody.index)
                    Response(OK).body(Json.encodeToString(textField))
                }
            },
            "nativeTextField" bind POST to {
                val data = Json.decodeFromString<SetNativeTextField>(it.bodyString())

                UIAutomatorInstrumentation.instance.setNativeTextField(data.index, data.text)
                Response(OK)
            },

            // Buttons
            "nativeButton" bind GET to {
                val reqBody = Json.decodeFromString<GetNativeButton>(it.bodyString())

                if (reqBody.index == null) {
                    val textFields = UIAutomatorInstrumentation.instance.getNativeButtons()
                    Response(OK).body(Json.encodeToString(textFields))
                } else {
                    val textField =
                        UIAutomatorInstrumentation.instance.getNativeButton(reqBody.index)
                    Response(OK).body(Json.encodeToString(textField))
                }
            },
            "nativeButton" bind POST to {
                val data = try {
                    Json.decodeFromString<SetNativeButton>(it.bodyString())
                } catch (err: Exception) {
                    return@to Response(BAD_REQUEST).body(err.stackTraceToString())
                }

                try {
                    UIAutomatorInstrumentation.instance.setNativeButton(data.index)
                    Response(OK)
                } catch (err: UiObjectNotFoundException) {
                    return@to Response(NOT_FOUND)
                } catch (err: Exception) {
                    return@to Response(INTERNAL_SERVER_ERROR).body(err.stackTraceToString())
                }
            }
        )
        server = app.asServer(Netty(8081)).start()
    }

    private fun stop() {
        Logger.i("Stopping...")
        Timer("SettingUp", false).schedule(1000) {
            server?.stop()
            running = false
            Logger.i("Stopped")
        }
    }

    companion object {
        val instance = ServerInstrumentation()
    }
}

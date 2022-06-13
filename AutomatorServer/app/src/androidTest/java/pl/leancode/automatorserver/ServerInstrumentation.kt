package pl.leancode.automatorserver

import androidx.test.uiautomator.UiObjectNotFoundException
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationException
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.http4k.core.Method.GET
import org.http4k.core.Method.POST
import org.http4k.core.Response
import org.http4k.core.Status.Companion.BAD_REQUEST
import org.http4k.core.Status.Companion.INTERNAL_SERVER_ERROR
import org.http4k.core.Status.Companion.NOT_FOUND
import org.http4k.core.Status.Companion.OK
import org.http4k.routing.bind
import org.http4k.routing.routes
import org.http4k.server.Http4kServer
import org.http4k.server.Netty
import org.http4k.server.asServer
import java.util.Timer
import kotlin.concurrent.schedule

@Serializable
data class TapCommand(val index: Int)

@Serializable
data class EnterTextCommand(val index: Int, val text: String)

const val TextClass = "com.android.widget.Text"
const val TextFieldClass = "com.android.widget.EditText"
const val ButtonClass = "com.android.widget.Button"

@Serializable
data class WidgetsQuery(
    val className: String? = null,
    val enabled: Boolean? = null,
    val focused: Boolean? = null,
    val text: String? = null,
    val textContains: String? = null,
    val contentDescription: String? = null,
) {
    fun isEmpty(): Boolean {
        return (
            className == null &&
                clazz() == null &&
                enabled == null &&
                focused == null &&
                text == null &&
                textContains == null &&
                contentDescription == null
            )
    }

    fun clazz(): String? {
        return when (className) {
            "Text" -> TextClass
            "TextField" -> TextFieldClass
            "Button" -> ButtonClass
            else -> null
        }
    }
}

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
            "tap" bind POST to {
                try {
                    val body = Json.decodeFromString<TapCommand>(it.bodyString())
                    UIAutomatorInstrumentation.instance.tap(body.index)
                    Response(OK)
                } catch (err: SerializationException) {
                    return@to Response(BAD_REQUEST).body(err.stackTraceToString())
                } catch (err: UiObjectNotFoundException) {
                    return@to Response(NOT_FOUND)
                } catch (err: Exception) {
                    return@to Response(INTERNAL_SERVER_ERROR).body(err.stackTraceToString())
                }
            },
            "enterText" bind POST to {
                try {
                    val body = Json.decodeFromString<EnterTextCommand>(it.bodyString())
                    UIAutomatorInstrumentation.instance.setNativeTextField(body.index, body.text)
                    Response(OK)
                } catch (err: SerializationException) {
                    return@to Response(BAD_REQUEST).body(err.stackTraceToString())
                } catch (err: UiObjectNotFoundException) {
                    return@to Response(NOT_FOUND)
                } catch (err: Exception) {
                    return@to Response(INTERNAL_SERVER_ERROR).body(err.stackTraceToString())
                }
            },
            "getNativeWidgets" bind POST to {
                try {
                    val body = Json.decodeFromString<WidgetsQuery>(it.bodyString())
                    val textFields = UIAutomatorInstrumentation.instance.getNativeWidgets(body)
                    Response(OK).body(Json.encodeToString(textFields))
                } catch (err: SerializationException) {
                    return@to Response(BAD_REQUEST).body(err.stackTraceToString())
                } catch (err: UiObjectNotFoundException) {
                    return@to Response(NOT_FOUND)
                } catch (err: Exception) {
                    return@to Response(INTERNAL_SERVER_ERROR).body(err.stackTraceToString())
                }
            },
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

package pl.leancode.automatorserver

import androidx.test.uiautomator.UiObjectNotFoundException
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationException
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.http4k.core.Filter
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

const val TextClass = "android.widget.TextView"
const val TextFieldClass = "android.widget.EditText"
const val ButtonClass = "android.widget.Button"

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
        server?.stop()
        running = true

        val router = routes(
            "healthCheck" bind GET to {
                Logger.i("Health check")
                Response(OK).body("All is good.")
            },
            "stop" bind POST to {
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
                val body = Json.decodeFromString<TapCommand>(it.bodyString())
                UIAutomatorInstrumentation.instance.tap(body.index)
                Response(OK)
            },
            "enterText" bind POST to {
                val body = Json.decodeFromString<EnterTextCommand>(it.bodyString())
                UIAutomatorInstrumentation.instance.enterText(body.index, body.text)
                Response(OK)
            },
            "getNativeWidgets" bind POST to {
                val body = Json.decodeFromString<WidgetsQuery>(it.bodyString())
                val textFields = UIAutomatorInstrumentation.instance.getNativeWidgets(body)
                Response(OK).body(Json.encodeToString(textFields))
            },
            "enableDarkMode" bind POST to {
                UIAutomatorInstrumentation.instance.enableDarkMode()
                Response(OK)
            },
            "disableDarkMode" bind POST to {
                UIAutomatorInstrumentation.instance.disableDarkMode()
                Response(OK)
            },
            "enableWifi" bind POST to {
                UIAutomatorInstrumentation.instance.enableWifi()
                Response(OK)
            },
            "disableWifi" bind POST to {
                UIAutomatorInstrumentation.instance.disableWifi()
                Response(OK)
            },
            "enableCelluar" bind POST to {
                UIAutomatorInstrumentation.instance.enableCelluar()
                Response(OK)
            },
            "disableCelluar" bind POST to {
                UIAutomatorInstrumentation.instance.disableCelluar()
                Response(OK)
            },
        )

        server = router.withFilter(catcher)
            .withFilter(printer)
            .asServer(Netty(8081))
            .start()
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

val printer = Filter { next ->
    { request ->
        val requestName = "${request.method} ${request.uri}"
        Logger.i("$requestName started")
        val startTime = System.currentTimeMillis()
        val response = next(request)
        val latency = System.currentTimeMillis() - startTime
        Logger.i("$requestName took $latency ms")
        response
    }
}

val catcher = Filter { next ->
    { request ->
        try {
            next(request)
        } catch (err: SerializationException) {
            Logger.e("caught SerializationException", err)
            Response(BAD_REQUEST).body(err.stackTraceToString())
        } catch (err: UiObjectNotFoundException) {
            Logger.e("caught UiObjectNotFoundException", err)
            Response(NOT_FOUND).body(err.stackTraceToString())
        } catch (err: Exception) {
            Logger.e("caught Exception", err)
            Response(INTERNAL_SERVER_ERROR).body(err.stackTraceToString())
        }
    }
}

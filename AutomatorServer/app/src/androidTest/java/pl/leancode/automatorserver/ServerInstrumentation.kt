package pl.leancode.automatorserver

import androidx.test.uiautomator.UiObjectNotFoundException
import androidx.test.uiautomator.UiSelector
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
data class TapOnNotificationCommand(val index: Int)

@Serializable
data class EnterTextCommand(val index: Int, val text: String)

@Serializable
data class WidgetsQuery(
    val text: String? = null,
    val textStartsWith: String? = null,
    val textContains: String? = null,
    val className: String? = null,
    val contentDescription: String? = null,
    val contentDescriptionStartsWith: String? = null,
    val contentDescriptionContains: String? = null,
    val resourceId: String? = null,
    val instance: Int? = null,
    val enabled: Boolean? = null,
    val focused: Boolean? = null,
    val pkg: String? = null,
) {
    fun isEmpty(): Boolean {
        return (
            text == null &&
                textStartsWith == null &&
                textContains == null &&
                className == null &&
                contentDescription == null &&
                contentDescriptionStartsWith == null &&
                contentDescriptionContains == null &&
                resourceId == null &&
                instance == null &&
                enabled == null &&
                focused == null &&
                pkg == null
            )
    }

    fun toUiSelector(): UiSelector {
        val selector = UiSelector()

        if (text != null) {
            selector.text(text)
        }

        if (textStartsWith != null) {
            selector.textStartsWith(textStartsWith)
        }

        if (textContains != null) {
            selector.textContains(textContains)
        }

        if (className != null) {
            selector.className(className)
        }

        if (contentDescription != null) {
            selector.description(contentDescription)
        }

        if (contentDescriptionStartsWith != null) {
            selector.descriptionStartsWith(contentDescriptionStartsWith)
        }

        if (contentDescriptionContains != null) {
            selector.descriptionContains(contentDescriptionContains)
        }

        if (resourceId != null) {
            selector.resourceId(resourceId)
        }

        if (instance != null) {
            selector.instance(instance)
        }

        if (enabled != null) {
            selector.enabled(enabled)
        }

        if (focused != null) {
            selector.focused(focused)
        }

        if (pkg != null) {
            selector.packageName(pkg)
        }

        return selector
    }
}

class ServerInstrumentation {
    var running = false
    var server: Http4kServer? = null

    fun start() {
        server?.stop()
        UIAutomatorInstrumentation.instance.configure()
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
            "tapOnNotification" bind POST to {
                val body = Json.decodeFromString<TapOnNotificationCommand>(it.bodyString())
                UIAutomatorInstrumentation.instance.tapOnNotification(body.index)
                Response(OK)
            },
            "tap" bind POST to {
                val body = Json.decodeFromString<TapCommand>(it.bodyString())
                UIAutomatorInstrumentation.instance.tap(body.index)
                Response(OK)
            },
            "tap2" bind POST to {
                val body = Json.decodeFromString<WidgetsQuery>(it.bodyString())
                UIAutomatorInstrumentation.instance.tap(body)
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
            "enableBluetooth" bind POST to {
                UIAutomatorInstrumentation.instance.enableBluetooth()
                Response(OK)
            },
            "disableBluetooth" bind POST to {
                UIAutomatorInstrumentation.instance.disableBluetooth()
                Response(OK)
            }
        )

        val port = UIAutomatorInstrumentation.instance.port
            ?: throw Exception("Could not start server: port is null")

        Logger.i("Starting server on port $port")

        server = router.withFilter(catcher)
            .withFilter(printer)
            .asServer(Netty(port))
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

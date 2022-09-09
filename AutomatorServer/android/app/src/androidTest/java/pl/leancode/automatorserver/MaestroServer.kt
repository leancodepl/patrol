package pl.leancode.automatorserver

import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.By
import androidx.test.uiautomator.BySelector
import androidx.test.uiautomator.UiObjectNotFoundException
import androidx.test.uiautomator.UiSelector
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationException
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.http4k.core.ContentType
import org.http4k.core.Filter
import org.http4k.core.Method.GET
import org.http4k.core.Method.POST
import org.http4k.core.Response
import org.http4k.core.Status.Companion.BAD_REQUEST
import org.http4k.core.Status.Companion.INTERNAL_SERVER_ERROR
import org.http4k.core.Status.Companion.NOT_FOUND
import org.http4k.core.Status.Companion.OK
import org.http4k.filter.ServerFilters
import org.http4k.routing.bind
import org.http4k.routing.routes
import org.http4k.server.Http4kServer
import org.http4k.server.Netty
import org.http4k.server.asServer
import java.util.Timer
import kotlin.concurrent.schedule

@Serializable
data class OpenAppCommand(var appId: String)

@Serializable
data class SwipeCommand(
    var startX: Float,
    var startY: Float,
    var endX: Float,
    var endY: Float,
    var steps: Int
)

@Serializable
data class PermissionCommand(var code: String)

@Serializable
data class TapOnNotificationByIndexCommand(val index: Int)

@Serializable
data class EnterTextByIndexCommand(val data: String, val index: Int)

@Serializable
data class EnterTextBySelectorCommand(val data: String, val selector: SelectorQuery)

@Serializable
data class SelectorQuery(
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
    val pkg: String? = null
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
        var selector = UiSelector()

        if (text != null) {
            selector = selector.text(text)
        }

        if (textStartsWith != null) {
            selector = selector.textStartsWith(textStartsWith)
        }

        if (textContains != null) {
            selector = selector.textContains(textContains)
        }

        if (className != null) {
            selector = selector.className(className)
        }

        if (contentDescription != null) {
            selector = selector.description(contentDescription)
        }

        if (contentDescriptionStartsWith != null) {
            selector = selector.descriptionStartsWith(contentDescriptionStartsWith)
        }

        if (contentDescriptionContains != null) {
            selector = selector.descriptionContains(contentDescriptionContains)
        }

        if (resourceId != null) {
            selector = selector.resourceId(resourceId)
        }

        if (instance != null) {
            selector = selector.instance(instance)
        }

        if (enabled != null) {
            selector = selector.enabled(enabled)
        }

        if (focused != null) {
            selector = selector.focused(focused)
        }

        if (pkg != null) {
            selector = selector.packageName(pkg)
        }

        return selector
    }

    fun toBySelector(): BySelector {
        if (isEmpty()) {
            throw MaestroException("SelectorQuery is empty")
        }

        var matchedText = false
        var matchedTextStartsWith = false
        var matchedTextContains = false
        var matchedClassName = false
        var matchedContentDescription = false
        var matchedContentDescriptionStartsWith = false
        var matchedContentDescriptionContains = false
        var matchedResourceId = false
        var matchedEnabled = false
        var matchedFocused = false
        var matchedPkg = false

        var bySelector = if (text != null) {
            matchedText = true
            By.text(text)
        } else if (textStartsWith != null) {
            matchedTextStartsWith = true
            By.textStartsWith(textStartsWith)
        } else if (textContains != null) {
            matchedTextContains = true
            By.textContains(textContains)
        } else if (className != null) {
            matchedClassName = true
            By.clazz(className)
        } else if (contentDescription != null) {
            matchedContentDescription = true
            By.desc(contentDescription)
        } else if (contentDescriptionStartsWith != null) {
            matchedContentDescriptionStartsWith = true
            By.descStartsWith(contentDescriptionStartsWith)
        } else if (contentDescriptionContains != null) {
            matchedContentDescriptionContains = true
            By.descContains(contentDescriptionContains)
        } else if (resourceId != null) {
            matchedResourceId = true
            By.res(resourceId)
        } else if (instance != null) {
            throw IllegalArgumentException("instance() argument is not supported for BySelector")
        } else if (enabled != null) {
            matchedEnabled = true
            By.enabled(enabled)
        } else if (focused != null) {
            matchedFocused = true
            By.focused(focused)
        } else if (pkg != null) {
            matchedPkg = true
            By.pkg(pkg)
        } else {
            throw IllegalArgumentException("SelectorQuery is empty")
        }

        if (!matchedText && text != null) {
            bySelector = By.copy(bySelector).text(text)
        }

        if (!matchedTextStartsWith && textStartsWith != null) {
            bySelector = By.copy(bySelector).textStartsWith(textStartsWith)
        }

        if (!matchedTextContains && textContains != null) {
            bySelector = By.copy(bySelector).textContains(textContains)
        }

        if (!matchedClassName && className != null) {
            bySelector = By.copy(bySelector).clazz(className)
        }

        if (!matchedContentDescription && contentDescription != null) {
            bySelector = By.copy(bySelector).desc(contentDescription)
        }

        if (!matchedContentDescriptionStartsWith && contentDescriptionStartsWith != null) {
            bySelector = By.copy(bySelector).descStartsWith(contentDescriptionStartsWith)
        }

        if (!matchedContentDescriptionContains && contentDescriptionContains != null) {
            bySelector = By.copy(bySelector).descContains(contentDescriptionContains)
        }

        if (!matchedResourceId && resourceId != null) {
            bySelector = By.copy(bySelector).res(resourceId)
        }

        if (instance != null) {
            throw IllegalArgumentException("instance() argument is not supported for BySelector")
        }

        if (!matchedEnabled && enabled != null) {
            bySelector = bySelector.enabled(enabled)
        }

        if (!matchedFocused && focused != null) {
            bySelector = bySelector.focused(focused)
        }

        if (!matchedPkg && pkg != null) {
            bySelector = bySelector.pkg(pkg)
        }

        return bySelector
    }
}

class MaestroServer {
    private val envPortKey = "MAESTRO_PORT"

    var running = false
    private var server: Http4kServer? = null
    private val port: Int

    init {
        port = arguments.getString(envPortKey)?.toInt()
            ?: throw MaestroException("$envPortKey is null")
    }

    private val arguments get() = InstrumentationRegistry.getArguments()

    private val json = Json { ignoreUnknownKeys = true }

    private val router = routes(
        "" bind GET to {
            Response(OK).body("Hello from AutomatorServer on Android!")
        },
        "isRunning" bind GET to {
            Response(OK).body("All is good.")
        },
        "stop" bind POST to {
            stop()
            Response(OK).body("Server stopped.")
        },
        "pressHome" bind POST to {
            MaestroAutomator.instance.pressHome()
            Response(OK)
        },
        "openApp" bind POST to {
            val body = json.decodeFromString<OpenAppCommand>(it.bodyString())
            MaestroAutomator.instance.openApp(body.appId)
            Response(OK)
        },
        "pressBack" bind POST to {
            MaestroAutomator.instance.pressBack()
            Response(OK)
        },
        "pressRecentApps" bind POST to {
            MaestroAutomator.instance.pressRecentApps()
            Response(OK)
        },
        "pressDoubleRecentApps" bind POST to {
            MaestroAutomator.instance.pressDoubleRecentApps()
            Response(OK)
        },
        "openNotifications" bind POST to {
            MaestroAutomator.instance.openNotifications()
            Response(OK)
        },
        "openQuickSettings" bind POST to {
            MaestroAutomator.instance.openQuickSettings()
            Response(OK)
        },
        "getNotifications" bind GET to {
            val notifications = MaestroAutomator.instance.getNotifications()
            Response(OK).body(json.encodeToString(notifications))
        },
        "tapOnNotificationByIndex" bind POST to {
            val body = json.decodeFromString<TapOnNotificationByIndexCommand>(it.bodyString())
            MaestroAutomator.instance.tapOnNotification(body.index)
            Response(OK)
        },
        "tapOnNotificationBySelector" bind POST to {
            val body = json.decodeFromString<SelectorQuery>(it.bodyString())
            MaestroAutomator.instance.tapOnNotification(body)
            Response(OK)
        },
        "tap" bind POST to {
            val body = json.decodeFromString<SelectorQuery>(it.bodyString())
            MaestroAutomator.instance.tap(body)
            Response(OK)
        },
        "doubleTap" bind POST to {
            val body = json.decodeFromString<SelectorQuery>(it.bodyString())
            MaestroAutomator.instance.doubleTap(body)
            Response(OK)
        },
        "enterTextByIndex" bind POST to {
            val body = json.decodeFromString<EnterTextByIndexCommand>(it.bodyString())
            MaestroAutomator.instance.enterText(body.data, body.index)
            Response(OK)
        },
        "enterTextBySelector" bind POST to {
            val body = json.decodeFromString<EnterTextBySelectorCommand>(it.bodyString())
            MaestroAutomator.instance.enterText(body.data, body.selector)
            Response(OK)
        },
        "swipe" bind POST to {
            val body = json.decodeFromString<SwipeCommand>(it.bodyString())
            MaestroAutomator.instance.swipe(body)
            Response(OK)
        },
        "getNativeWidgets" bind POST to {
            val body = json.decodeFromString<SelectorQuery>(it.bodyString())
            val textFields = MaestroAutomator.instance.getNativeWidgets(body)
            Response(OK).body(json.encodeToString(textFields))
        },
        "enableDarkMode" bind POST to {
            MaestroAutomator.instance.enableDarkMode()
            Response(OK)
        },
        "disableDarkMode" bind POST to {
            MaestroAutomator.instance.disableDarkMode()
            Response(OK)
        },
        "enableWifi" bind POST to {
            MaestroAutomator.instance.enableWifi()
            Response(OK)
        },
        "disableWifi" bind POST to {
            MaestroAutomator.instance.disableWifi()
            Response(OK)
        },
        "enableCelluar" bind POST to {
            MaestroAutomator.instance.enableCelluar()
            Response(OK)
        },
        "disableCelluar" bind POST to {
            MaestroAutomator.instance.disableCelluar()
            Response(OK)
        },
        "enableBluetooth" bind POST to {
            MaestroAutomator.instance.enableBluetooth()
            Response(OK)
        },
        "disableBluetooth" bind POST to {
            MaestroAutomator.instance.disableBluetooth()
            Response(OK)
        },
        "handlePermission" bind POST to {
            val body = json.decodeFromString<PermissionCommand>(it.bodyString())
            MaestroAutomator.instance.handlePermission(body.code)
            Response(OK)
        },
        "selectFineLocation" bind POST to {
            MaestroAutomator.instance.selectFineLocation()
            Response(OK)
        },
        "selectCoarseLocation" bind POST to {
            MaestroAutomator.instance.selectCoarseLocation()
            Response(OK)
        }
    )

    fun start() {
        Logger.i("Starting server...")
        server?.stop()
        MaestroAutomator.instance.configure()
        running = true

        server = router
            .withFilter(catcher)
            .withFilter(printer)
            .withFilter(ServerFilters.SetContentType(ContentType.TEXT_PLAIN))
            .asServer(Netty(port))
            .start()

        Logger.i("Server started on http://localhost:$port")
        server?.block()
    }

    private fun stop() {
        Logger.i("Stopping server...")
        Timer("StopServer", false).schedule(1000) {
            server?.stop()
            running = false
            Logger.i("Server stopped")
        }
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

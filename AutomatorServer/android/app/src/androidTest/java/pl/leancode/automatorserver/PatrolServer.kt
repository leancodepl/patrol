package pl.leancode.automatorserver

import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.By
import androidx.test.uiautomator.BySelector
import androidx.test.uiautomator.UiObjectNotFoundException
import androidx.test.uiautomator.UiSelector
import com.google.protobuf.Message
import com.google.protobuf.util.JsonFormat
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationException
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.http4k.core.ContentType
import org.http4k.core.Filter
import org.http4k.core.MemoryBody
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


private fun Contracts.Selector.isEmpty(): Boolean {
    return (
            !hasText() &&
                    !hasTextStartsWith() &&
                    !hasTextContains() &&
                    !hasClassName() &&
                    !hasContentDescription() &&
                    !hasContentDescriptionStartsWith() &&
                    !hasContentDescriptionContains() &&
                    !hasResourceId() &&
                    !hasInstance() &&
                    !hasEnabled() &&
                    !hasFocused() &&
                    !hasPkg()
            )
}

fun Contracts.Selector.toUiSelector(): UiSelector {
    var selector = UiSelector()

    if (hasText()) {
        selector = selector.text(text)
    }

    if (hasTextStartsWith()) {
        selector = selector.textStartsWith(textStartsWith)
    }

    if (hasTextContains()) {
        selector = selector.textContains(textContains)
    }

    if (hasClassName()) {
        selector = selector.className(className)
    }

    if (hasContentDescription()) {
        selector = selector.description(contentDescription)
    }

    if (hasContentDescriptionStartsWith()) {
        selector = selector.descriptionStartsWith(contentDescriptionStartsWith)
    }

    if (hasContentDescriptionContains()) {
        selector = selector.descriptionContains(contentDescriptionContains)
    }

    if (hasResourceId()) {
        selector = selector.resourceId(resourceId)
    }

    if (hasInstance()) {
        selector = selector.instance(instance)
    }

    if (hasEnabled()) {
        selector = selector.enabled(enabled)
    }

    if (hasFocused()) {
        selector = selector.focused(focused)
    }

    if (hasPkg()) {
        selector = selector.packageName(pkg)
    }

    return selector
}

fun Contracts.Selector.toBySelector(): BySelector {
    if (isEmpty()) {
        throw PatrolException("Selector is empty")
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

    var bySelector = if (hasText()) {
        matchedText = true
        By.text(text)
    } else if (hasTextStartsWith()) {
        matchedTextStartsWith = true
        By.textStartsWith(textStartsWith)
    } else if (hasTextContains()) {
        matchedTextContains = true
        By.textContains(textContains)
    } else if (hasClassName()) {
        matchedClassName = true
        By.clazz(className)
    } else if (hasContentDescription()) {
        matchedContentDescription = true
        By.desc(contentDescription)
    } else if (hasContentDescriptionStartsWith()) {
        matchedContentDescriptionStartsWith = true
        By.descStartsWith(contentDescriptionStartsWith)
    } else if (hasContentDescriptionContains()) {
        matchedContentDescriptionContains = true
        By.descContains(contentDescriptionContains)
    } else if (hasResourceId()) {
        matchedResourceId = true
        By.res(resourceId)
    } else if (hasInstance()) {
        throw IllegalArgumentException("instance() argument is not supported for BySelector")
    } else if (hasEnabled()) {
        matchedEnabled = true
        By.enabled(enabled)
    } else if (hasFocused()) {
        matchedFocused = true
        By.focused(focused)
    } else if (hasPkg()) {
        matchedPkg = true
        By.pkg(pkg)
    } else {
        throw IllegalArgumentException("SelectorQuery is empty")
    }

    if (!matchedText && hasText()) {
        bySelector = By.copy(bySelector).text(text)
    }

    if (!matchedTextStartsWith && hasTextStartsWith()) {
        bySelector = By.copy(bySelector).textStartsWith(textStartsWith)
    }

    if (!matchedTextContains && hasTextContains()) {
        bySelector = By.copy(bySelector).textContains(textContains)
    }

    if (!matchedClassName && hasClassName()) {
        bySelector = By.copy(bySelector).clazz(className)
    }

    if (!matchedContentDescription && hasContentDescription()) {
        bySelector = By.copy(bySelector).desc(contentDescription)
    }

    if (!matchedContentDescriptionStartsWith && hasContentDescriptionStartsWith()) {
        bySelector = By.copy(bySelector).descStartsWith(contentDescriptionStartsWith)
    }

    if (!matchedContentDescriptionContains && hasContentDescriptionContains()) {
        bySelector = By.copy(bySelector).descContains(contentDescriptionContains)
    }

    if (!matchedResourceId && hasResourceId()) {
        bySelector = By.copy(bySelector).res(resourceId)
    }

    if (hasInstance()) {
        throw IllegalArgumentException("instance() argument is not supported for BySelector")
    }

    if (!matchedEnabled && hasEnabled()) {
        bySelector = bySelector.enabled(enabled)
    }

    if (!matchedFocused && hasFocused()) {
        bySelector = bySelector.focused(focused)
    }

    if (!matchedPkg && hasPkg()) {
        bySelector = bySelector.pkg(pkg)
    }

    return bySelector
}


val json = Json { ignoreUnknownKeys = true }

class PatrolServer {
    private val envPortKey = "PATROL_PORT"

    private var server: Http4kServer? = null
    private val port: Int

    init {
        port = arguments.getString(envPortKey)?.toInt() ?: 8081
    }

    private val arguments get() = InstrumentationRegistry.getArguments()

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
            PatrolAutomator.instance.pressHome()
            Response(OK)
        },
        "openApp" bind POST to {
            val builder = Contracts.OpenAppCommand.newBuilder()
            JsonFormat.parser().merge(it.bodyString(), builder)
            val command = builder.build()

            PatrolAutomator.instance.openApp(command.appId)
            Response(OK)
        },
        "pressBack" bind POST to {
            PatrolAutomator.instance.pressBack()
            Response(OK)
        },
        "pressRecentApps" bind POST to {
            PatrolAutomator.instance.pressRecentApps()
            Response(OK)
        },
        "pressDoubleRecentApps" bind POST to {
            PatrolAutomator.instance.pressDoubleRecentApps()
            Response(OK)
        },
        "openNotifications" bind POST to {
            PatrolAutomator.instance.openNotifications()
            Response(OK)
        },
        "openQuickSettings" bind POST to {
            PatrolAutomator.instance.openQuickSettings()
            Response(OK)
        },
        "getNotifications" bind GET to {
            val notifications = PatrolAutomator.instance.getNotifications()
            val query = Contracts.NotificationsQueryResponse.newBuilder().addAllNotifications(notifications).build()
            val body = JsonFormat.printer().print(query)
            Response(OK).body(body)
        },
        "tapOnNotificationByIndex" bind POST to {
            val builder = Contracts.TapOnNotificationByIndexCommand.newBuilder()
            JsonFormat.parser().merge(it.bodyString(), builder)
            val command = builder.build()

            PatrolAutomator.instance.tapOnNotification(command.index)
            Response(OK)
        },
        "tapOnNotificationBySelector" bind POST to {
            val builder = Contracts.TapOnNotificationBySelectorCommand.newBuilder()
            JsonFormat.parser().merge(it.bodyString(), builder)
            val command = builder.build()

            PatrolAutomator.instance.tapOnNotification(command.selector)
            Response(OK)
        },
        "tap" bind POST to {
            val builder = Contracts.TapCommand.newBuilder()
            JsonFormat.parser().merge(it.bodyString(), builder)
            val command = builder.build()

            PatrolAutomator.instance.tap(command.selector.toUiSelector())
            Response(OK)
        },
        "doubleTap" bind POST to {
            val builder = Contracts.DoubleTapCommand.newBuilder()
            JsonFormat.parser().merge(it.bodyString(), builder)
            val command = builder.build()

            PatrolAutomator.instance.doubleTap(command.selector.toUiSelector())
            Response(OK)
        },
        "enterTextByIndex" bind POST to {
            val builder = Contracts.EnterTextByIndexCommand.newBuilder()
            JsonFormat.parser().merge(it.bodyString(), builder)
            val command = builder.build()

            PatrolAutomator.instance.enterText(command.data, command.index)
            Response(OK)
        },
        "enterTextBySelector" bind POST to {
            val builder = Contracts.EnterTextBySelectorCommand.newBuilder()
            JsonFormat.parser().merge(it.bodyString(), builder)
            val command = builder.build()

            PatrolAutomator.instance.enterText(command.data, command.selector)
            Response(OK)
        },
        "swipe" bind POST to {
            val builder = Contracts.SwipeCommand.newBuilder()
            JsonFormat.parser().merge(it.bodyString(), builder)
            val command = builder.build()

            PatrolAutomator.instance.swipe(command)
            Response(OK)
        },
        "getNativeWidgets" bind POST to {
            val builder = Contracts.NativeWidgetsQuery.newBuilder()
            JsonFormat.parser().merge(it.bodyString(), builder)
            val command = builder.build()

            val textFields = PatrolAutomator.instance.getNativeWidgets(command.selector.toBySelector())
            Response(OK).body(json.encodeToString(textFields))
        },
        "enableDarkMode" bind POST to {
            PatrolAutomator.instance.enableDarkMode()
            Response(OK)
        },
        "disableDarkMode" bind POST to {
            PatrolAutomator.instance.disableDarkMode()
            Response(OK)
        },
        "enableWifi" bind POST to {
            PatrolAutomator.instance.enableWifi()
            Response(OK)
        },
        "disableWifi" bind POST to {
            PatrolAutomator.instance.disableWifi()
            Response(OK)
        },
        "enableCelluar" bind POST to {
            PatrolAutomator.instance.enableCelluar()
            Response(OK)
        },
        "disableCelluar" bind POST to {
            PatrolAutomator.instance.disableCelluar()
            Response(OK)
        },
        "enableBluetooth" bind POST to {
            PatrolAutomator.instance.enableBluetooth()
            Response(OK)
        },
        "disableBluetooth" bind POST to {
            PatrolAutomator.instance.disableBluetooth()
            Response(OK)
        },
        "handlePermission" bind POST to {
            val builder = Contracts.HandlePermissionCommand.newBuilder()
            JsonFormat.parser().merge(it.bodyString(), builder)
            val command = builder.build()

            PatrolAutomator.instance.handlePermission(command.code)
            Response(OK)
        },
        "selectFineLocation" bind POST to {
            PatrolAutomator.instance.selectFineLocation()
            Response(OK)
        },
        "selectCoarseLocation" bind POST to {
            PatrolAutomator.instance.selectCoarseLocation()
            Response(OK)
        }
    )

    fun start() {
        Logger.i("Starting server...")
        server?.stop()
        PatrolAutomator.instance.configure()

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
        server?.stop()
        Logger.i("Server stopped")
    }
}

val printer = Filter { next ->
    { request ->
        val requestName = "${request.method} ${request.uri}"
        Logger.i("$requestName started")
        val startTime = System.currentTimeMillis()
        val response = next(request)
        val latency = System.currentTimeMillis() - startTime
        if (response.bodyString().isNotEmpty()) {
            Logger.i("body of ${request.uri}: \n- - -\n\t${response.bodyString()}\n- - -")
        }
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
            val msg = "selector ${err.message} found nothing"
            Response(NOT_FOUND).body(
                MemoryBody(
                    json.encodeToString(
                        UiObjectNotFoundResponse(
                            message = msg,
                            stackTrace = err.stackTraceToString()
                        )
                    )
                )
            )
        } catch (err: Exception) {
            Logger.e("caught Exception", err)
            Response(INTERNAL_SERVER_ERROR).body(err.stackTraceToString())
        }
    }
}

@Serializable
data class UiObjectNotFoundResponse(
    val message: String?,
    val stackTrace: String,
)

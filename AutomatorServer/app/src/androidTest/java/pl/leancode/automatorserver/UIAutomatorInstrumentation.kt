package pl.leancode.automatorserver

import android.os.Bundle
import android.os.SystemClock
import android.widget.EditText
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.Configurator
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.UiObject2
import androidx.test.uiautomator.UiSelector
import kotlinx.serialization.Serializable
import kotlin.math.roundToInt

@Serializable
data class Notification(
    val appName: String,
    val title: String,
    val content: String
)

@Serializable
data class NativeWidget(
    val className: String?,
    val text: String?,
    val contentDescription: String?,
    val focused: Boolean?,
    val enabled: Boolean?,
    val childCount: Int?,
    val resourceName: String?,
    val applicationPackage: String?,
    val children: List<NativeWidget>?
) {
    companion object {
        fun fromUiObject2(obj: UiObject2): NativeWidget {
            return NativeWidget(
                className = obj.className,
                text = obj.text,
                contentDescription = obj.contentDescription,
                focused = obj.isFocused,
                enabled = obj.isEnabled,
                childCount = obj.childCount,
                resourceName = obj.resourceName,
                applicationPackage = obj.applicationPackage,
                children = obj.children?.map { fromUiObject2(it) }
            )
        }
    }
}

class UIAutomatorInstrumentation {
    fun configure() {
        val configurator = Configurator.getInstance()
        configurator.waitForSelectorTimeout = 5000
        configurator.waitForIdleTimeout = 5000
        configurator.keyInjectionDelay = 50

        Logger.i("Android UiAutomator configuration:")
        Logger.i("\twaitForSelectorTimeout: ${configurator.waitForSelectorTimeout} ms")
        Logger.i("\twaitForIdleTimeout: ${configurator.waitForIdleTimeout} ms")
        Logger.i("\tkeyInjectionDelay: ${configurator.keyInjectionDelay} ms")
        Logger.i("\tactionAcknowledgmentTimeout: ${configurator.actionAcknowledgmentTimeout} ms")
        Logger.i("\tscrollAcknowledgmentTimeout: ${configurator.scrollAcknowledgmentTimeout} ms")
        Logger.i("\ttoolType: ${configurator.toolType}")
        Logger.i("\tuiAutomationFlags: ${configurator.uiAutomationFlags}")
    }

    private fun getUiDevice(): UiDevice =
        UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())

    private fun getArguments(): Bundle = InstrumentationRegistry.getArguments()

    val port: Int?
        get() = getArguments().getString("MAESTRO_PORT")?.toInt()

    private fun executeShellCommand(cmd: String) {
        val device = getUiDevice()
        device.executeShellCommand(cmd)
        delay()
    }

    private fun delay(ms: Long = 1000) = SystemClock.sleep(ms)

    fun pressBack() {
        Logger.d("pressBack()")

        val device = getUiDevice()
        device.pressBack()
        delay()
    }

    fun pressHome() {
        Logger.d("pressHome()")

        val device = getUiDevice()
        device.pressHome()
        delay()
    }

    fun pressRecentApps() {
        Logger.d("pressRecentApps()")

        val device = getUiDevice()
        device.pressRecentApps()
        delay()
    }

    fun pressDoubleRecentApps() {
        Logger.d("pressDoubleRecentApps()")

        val device = getUiDevice()
        device.pressRecentApps()
        delay()
        device.pressRecentApps()
        delay()
    }

    fun enableDarkMode() = executeShellCommand("cmd uimode night yes")

    fun disableDarkMode() = executeShellCommand("cmd uimode night no")

    fun disableWifi() = executeShellCommand("svc wifi disable")

    fun enableWifi() = executeShellCommand("svc wifi enable")

    fun disableCelluar() = executeShellCommand("svc data disable")

    fun enableCelluar() = executeShellCommand("svc data enable")

    fun enableBluetooth() = executeShellCommand("svc bluetooth enable")

    fun disableBluetooth() = executeShellCommand("svc bluetooth disable")

    fun getNativeWidgets(query: SelectorQuery): List<NativeWidget> {
        Logger.d("getNativeWidgets()")

        val device = getUiDevice()
        val selector = query.toBySelector()
        val uiObjects2 = device.findObjects(selector)
        return uiObjects2.map { NativeWidget.fromUiObject2(it) }
    }

    fun tap(query: SelectorQuery) {
        Logger.d("tap()")

        val device = getUiDevice()

        val selector = query.toUiSelector()
        Logger.d("Selector: $selector")

        val uiObject = device.findObject(selector)

        Logger.d("Clicking on UIObject with text: ${uiObject.text}")
        uiObject.click()
        delay()
    }

    fun doubleTap(query: SelectorQuery) {
        Logger.d("doubleTap()")

        val device = getUiDevice()
        val selector = query.toUiSelector()
        Logger.d("Selector: $selector")

        val uiObject = device.findObject(selector)

        Logger.d("Double clicking on UIObject with text: ${uiObject.text}")
        uiObject.click()
        Logger.d("After first click")
        delay(ms = 300)
        uiObject.click()
        Logger.d("After second click")
        delay()
    }

    fun enterText(text: String, index: Int) {
        Logger.d("enterText(text: $text, index: $index)")

        val device = getUiDevice()
        val selector = UiSelector().className(EditText::class.java).instance(index)
        Logger.d("Selector: $selector")

        Logger.d("entering text \"$text\" to $selector")

        val uiObject = device.findObject(selector)
        uiObject.click()
        uiObject.text = text

        pressBack() // Hide keyboard.
    }

    fun enterText(text: String, query: SelectorQuery) {
        Logger.d("enterText(text: $text, query: $query")

        val device = getUiDevice()
        val selector = query.toUiSelector()
        Logger.d("entering text \"$text\" to $selector")

        val uiObject = device.findObject(selector).getFromParent(UiSelector().className(EditText::class.java))
        uiObject.click()
        uiObject.text = text

        pressBack() // Hide keyboard.
    }

    fun swipe(swipe: SwipeCommand) {
        Logger.d("swipe()")

        if (swipe.startX !in 0f..1f) {
            throw IllegalArgumentException("startX represents a percentage and must be between 0 and 1")
        }

        if (swipe.startY !in 0f..1f) {
            throw IllegalArgumentException("startY represents a percentage and must be between 0 and 1")
        }

        val device = getUiDevice()
        val startX = (device.displayWidth * swipe.startX).roundToInt()
        val startY = (device.displayHeight * swipe.startY).roundToInt()
        val endX = (device.displayWidth * swipe.endX).roundToInt()
        val endY = (device.displayHeight * swipe.endY).roundToInt()

        val successful = device.swipe(startX, startY, endX, endY, swipe.steps)
        if (!successful) {
            throw IllegalArgumentException("Swipe failed")
        }

        delay()
    }

    fun openHalfNotificationShade() {
        Logger.d("openHalfNotificationShade()")

        val device = getUiDevice()

        device.openNotification()
        delay()
    }

    fun openFullNotificationShade() {
        Logger.d("openFullNotificationShade()")

        val device = getUiDevice()

        openHalfNotificationShade()

        val startX = (device.displayWidth * 0.5).roundToInt()
        val startY = (device.displayHeight * 0.1).roundToInt()
        val endX = (device.displayWidth * 0.5).roundToInt()
        val endY = (device.displayHeight * 0.9).roundToInt()

        val successful = device.swipe(startX, startY, endX, endY, 3)
        if (!successful) {
            throw IllegalArgumentException("Swipe failed")
        }

        delay()
    }

    fun getNotifications(): List<Notification> {
        Logger.d("getNotifications()")

        openHalfNotificationShade()

        val widgets = getNativeWidgets(
            query = SelectorQuery(resourceId = "android:id/status_bar_latest_event_content")
        )

        val notifications = mutableListOf<Notification>()
        for (widget in widgets) {
            try {
                // Tested and working on API 30. May require changes for other OS versions.
                val appName = widget.children?.get(0)?.children?.get(1)?.text
                val title = widget.children?.get(1)?.children?.get(0)?.children?.get(0)?.text
                val content = widget.children?.get(1)?.children?.get(1)?.text
                notifications.add(Notification(appName = appName!!, title = title!!, content = content!!))
            } catch (err: IndexOutOfBoundsException) {
                Logger.e("Failed to get notification UI component", err)
            } catch (err: NullPointerException) {
                Logger.e("Null Pointer", err)
            }
        }

        return notifications
    }

    fun tapOnNotification(index: Int) {
        Logger.d("tapOnNotification($index)")

        openHalfNotificationShade()

        val device = getUiDevice()

        val query = SelectorQuery(resourceId = "android:id/status_bar_latest_event_content", instance = index)
        val obj = device.findObject(query.toUiSelector())
        obj.click()

        delay()
    }

    fun tapOnNotification(selector: SelectorQuery) {
        Logger.d("tapOnNotification()")

        openHalfNotificationShade()

        val device = getUiDevice()

        val obj = device.findObject(selector.toUiSelector())
        obj.click()

        delay()
    }

    companion object {
        val instance = UIAutomatorInstrumentation()
    }
}

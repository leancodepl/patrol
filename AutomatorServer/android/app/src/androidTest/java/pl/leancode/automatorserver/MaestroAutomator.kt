package pl.leancode.automatorserver

import android.os.SystemClock
import android.widget.EditText
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.By
import androidx.test.uiautomator.Configurator
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.UiObject2
import androidx.test.uiautomator.UiSelector
import kotlinx.serialization.Serializable
import kotlin.math.roundToInt

enum class PermissionLevel {
    WHILE_USING, ONLY_THIS_TIME, DENIED
}

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

class MaestroAutomator {
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

    private val instrumentation get() = InstrumentationRegistry.getInstrumentation()

    private val uiDevice get() = UiDevice.getInstance(instrumentation)

    private val targetContext get() = instrumentation.targetContext

    private fun executeShellCommand(cmd: String) {
        uiDevice.executeShellCommand(cmd)
        delay()
    }

    private fun delay(ms: Long = 1000) = SystemClock.sleep(ms)

    fun openApp(packageName: String) {
        val intent = targetContext.packageManager!!.getLaunchIntentForPackage(packageName)
            ?: throw Exception("intent for launching $packageName is null")
        // intent?.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK) // clear out any previous task, i.e., make sure it starts on the initial screen
        targetContext.startActivity(intent) // starts the app
        delay()
    }

    fun pressBack() {
        Logger.d("pressBack()")
        uiDevice.pressBack()
        delay()
    }

    fun pressHome() {
        Logger.d("pressHome()")
        uiDevice.pressHome()
        delay()
    }

    fun pressRecentApps() {
        Logger.d("pressRecentApps()")
        uiDevice.pressRecentApps()
        delay()
    }

    fun pressDoubleRecentApps() {
        Logger.d("pressDoubleRecentApps()")

        uiDevice.pressRecentApps()
        delay()
        uiDevice.pressRecentApps()
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

        val selector = query.toBySelector()
        val uiObjects2 = uiDevice.findObjects(selector)
        return uiObjects2.map { NativeWidget.fromUiObject2(it) }
    }

    fun tap(query: SelectorQuery) {
        Logger.d("tap()")

        val selector = query.toUiSelector()
        Logger.d("Selector: $selector")

        val uiObject = uiDevice.findObject(selector)

        Logger.d("Clicking on UIObject with text: ${uiObject.text}")
        uiObject.click()
        delay()
    }

    fun doubleTap(query: SelectorQuery) {
        Logger.d("doubleTap()")

        val selector = query.toUiSelector()
        Logger.d("Selector: $selector")

        val uiObject = uiDevice.findObject(selector)

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

        val selector = UiSelector().className(EditText::class.java).instance(index)
        Logger.d("Selector: $selector")

        Logger.d("entering text \"$text\" to $selector")

        val uiObject = uiDevice.findObject(selector)
        uiObject.click()
        uiObject.text = text

        pressBack() // Hide keyboard.
    }

    fun enterText(text: String, query: SelectorQuery) {
        Logger.d("enterText(text: $text, query: $query")

        val selector = query.toUiSelector()
        Logger.d("entering text \"$text\" to $selector")

        val uiObject = uiDevice.findObject(selector).getFromParent(UiSelector().className(EditText::class.java))
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

        val startX = (uiDevice.displayWidth * swipe.startX).roundToInt()
        val startY = (uiDevice.displayHeight * swipe.startY).roundToInt()
        val endX = (uiDevice.displayWidth * swipe.endX).roundToInt()
        val endY = (uiDevice.displayHeight * swipe.endY).roundToInt()

        val successful = uiDevice.swipe(startX, startY, endX, endY, swipe.steps)
        if (!successful) {
            throw IllegalArgumentException("Swipe failed")
        }

        delay()
    }

    fun openNotifications() {
        Logger.d("openNotifications()")
        val success = uiDevice.openNotification()
        if (!success) {
            throw MaestroException("Could not open notifications")
        }
        delay()
    }

    fun openQuickSettings() {
        Logger.d("openNotifications()")
        val success = uiDevice.openQuickSettings()
        if (!success) {
            throw MaestroException("Could not open quick settings")
        }
        delay()
    }

    fun getNotifications(): List<Notification> {
        Logger.d("getNotifications()")

        openNotifications()

        val notificationContainers = uiDevice.findObjects(By.res("android:id/status_bar_latest_event_content"))

        val notifications = mutableListOf<Notification>()
        Logger.d("Found ${notificationContainers.size} notifications")
        for (notificationContainer in notificationContainers) {
            try {
                val appName = notificationContainer.findObject(By.res("android:id/app_name_text"))?.text
                    ?: throw NullPointerException("Could not find app name text")
                val title = notificationContainer.findObject(By.res("android:id/title"))?.text
                    ?: throw NullPointerException("Could not find title text")
                val content = notificationContainer.findObject(By.res("android:id/text"))?.text
                    ?: notificationContainer.findObject(By.res("android:id/big_text"))?.text
                    ?: throw NullPointerException("Could not find content text")

                notifications.add(Notification(appName = appName, title = title, content = content))
            } catch (e: NullPointerException) {
                Logger.e("Failed to find UI component of a notification", e)
            }
        }

        return notifications
    }

    fun tapOnNotification(index: Int) {
        Logger.d("tapOnNotification($index)")

        openNotifications()

        val query = SelectorQuery(resourceId = "android:id/status_bar_latest_event_content", instance = index)
        val obj = uiDevice.findObject(query.toUiSelector())
        obj.click()

        delay()
    }

    fun tapOnNotification(selector: SelectorQuery) {
        Logger.d("tapOnNotification()")

        openNotifications()

        val obj = uiDevice.findObject(selector.toUiSelector())
        obj.click()

        delay()
    }

    fun handlePermission(code: String) {
        when (code) {
            "WHILE_USING" -> {
                tap(SelectorQuery(resourceId = "com.android.permissioncontroller:id/permission_allow_foreground_only_button"))
            }

            "ONLY_THIS_TIME" -> {
                tap(SelectorQuery(resourceId = "com.android.permissioncontroller:id/permission_allow_one_time_button"))
            }

            "DENIED" -> {
                tap(SelectorQuery(resourceId = "com.android.permissioncontroller:id/permission_deny_button"))
            }
        }
    }

    companion object {
        val instance = MaestroAutomator()
    }
}

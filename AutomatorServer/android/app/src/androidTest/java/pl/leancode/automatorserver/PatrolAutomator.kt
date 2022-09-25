package pl.leancode.automatorserver

import android.app.UiAutomation
import android.os.Build
import android.os.SystemClock
import android.widget.EditText
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.By
import androidx.test.uiautomator.BySelector
import androidx.test.uiautomator.Configurator
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.UiObject2
import androidx.test.uiautomator.UiSelector
import pl.leancode.automatorserver.contracts.Contracts
import pl.leancode.automatorserver.contracts.nativeWidget
import pl.leancode.automatorserver.contracts.notification
import kotlin.math.roundToInt

private fun fromUiObject2(obj: UiObject2): Contracts.NativeWidget {
    return nativeWidget {
        className = obj.className
        text = obj.text
        contentDescription = obj.contentDescription
        focused = obj.isFocused
        enabled = obj.isEnabled
        childCount = obj.childCount
        resourceName = obj.resourceName
        applicationPackage = obj.applicationPackage
        children.addAll(obj.children?.map { fromUiObject2(it) } ?: listOf())
    }
}

class PatrolAutomator private constructor() {

    fun configure() {
        val configurator = Configurator.getInstance()
        configurator.waitForSelectorTimeout = 5000
        configurator.waitForIdleTimeout = 5000
        configurator.keyInjectionDelay = 50

        Configurator.getInstance().uiAutomationFlags = UiAutomation.FLAG_DONT_SUPPRESS_ACCESSIBILITY_SERVICES

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

    fun disableCellular() = executeShellCommand("svc data disable")

    fun enableCellular() = executeShellCommand("svc data enable")

    fun enableBluetooth() = executeShellCommand("svc bluetooth enable")

    fun disableBluetooth() = executeShellCommand("svc bluetooth disable")

    fun getNativeWidgets(selector: BySelector): List<Contracts.NativeWidget> {
        Logger.d("getNativeWidgets()")

        val uiObjects2 = uiDevice.findObjects(selector)
        return uiObjects2.map { fromUiObject2(it) }
    }

    fun tap(selector: UiSelector) {
        Logger.d("tap() with selector $selector")

        val uiObject = uiDevice.findObject(selector)

        Logger.d("Clicking on UIObject with text: ${uiObject.text}")
        uiObject.click()
        delay()
    }

    fun doubleTap(selector: UiSelector) {
        Logger.d("doubleTap() with selector $selector")

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

    fun enterText(text: String, selector: UiSelector) {
        Logger.d("enterText(text: $text, selector: $selector)")

        val uiObject = uiDevice.findObject(selector).getFromParent(UiSelector().className(EditText::class.java))
        uiObject.click()
        uiObject.text = text

        pressBack() // Hide keyboard.
    }

    fun swipe(startX: Float, startY: Float, endX: Float, endY: Float, steps: Int) {
        Logger.d("swipe()")

        if (startX !in 0f..1f) {
            throw IllegalArgumentException("startX represents a percentage and must be between 0 and 1")
        }

        if (startY !in 0f..1f) {
            throw IllegalArgumentException("startY represents a percentage and must be between 0 and 1")
        }

        if (endX !in 0f..1f) {
            throw IllegalArgumentException("endX represents a percentage and must be between 0 and 1")
        }

        if (endY !in 0f..1f) {
            throw IllegalArgumentException("endY represents a percentage and must be between 0 and 1")
        }

        val sX = (uiDevice.displayWidth * startX).roundToInt()
        val sY = (uiDevice.displayHeight * startY).roundToInt()
        val eX = (uiDevice.displayWidth * endX).roundToInt()
        val eY = (uiDevice.displayHeight * endY).roundToInt()

        val successful = uiDevice.swipe(sX, sY, eX, eY, steps)
        if (!successful) {
            throw IllegalArgumentException("Swipe failed")
        }

        delay()
    }

    fun openNotifications() {
        Logger.d("openNotifications()")
        val success = uiDevice.openNotification()
        if (!success) {
            throw PatrolException("Could not open notifications")
        }
        delay()
    }

    fun openQuickSettings() {
        Logger.d("openNotifications()")
        val success = uiDevice.openQuickSettings()
        if (!success) {
            throw PatrolException("Could not open quick settings")
        }
        delay()
    }

    fun getNotifications(): List<Contracts.Notification> {
        Logger.d("getNotifications()")

        openNotifications()

        val notificationContainers = uiDevice.findObjects(By.res("android:id/status_bar_latest_event_content"))
        Logger.d("Found ${notificationContainers.size} notifications")

        val notifications = mutableListOf<Contracts.Notification>()
        for (notificationContainer in notificationContainers) {
            try {
                val notification = notification {
                    val appName = notificationContainer.findObject(By.res("android:id/app_name_text"))?.text
                    if (appName != null) {
                        this.appName = appName
                    }

                    val title = notificationContainer.findObject(By.res("android:id/title"))?.text
                        ?: throw PatrolException("Could not find title text")
                    this.title = title

                    val content = notificationContainer.findObject(By.res("android:id/text"))?.text
                        ?: notificationContainer.findObject(By.res("android:id/big_text"))?.text
                        ?: throw PatrolException("Could not find content text")
                    this.content = content
                }
                notifications.add(notification)
            } catch (e: PatrolException) {
                Logger.e("Failed to find UI component of a notification:", e)
            }
        }

        return notifications
    }

    fun tapOnNotification(index: Int) {
        Logger.d("tapOnNotification($index)")

        openNotifications()

        val query = Contracts.Selector.newBuilder().setResourceId("android:id/status_bar_latest_event_content")
            .setInstance(index).build()
        val obj = uiDevice.findObject(query.toUiSelector())
        obj.click()

        delay()
    }

    fun tapOnNotification(selector: UiSelector) {
        Logger.d("tapOnNotification()")

        openNotifications()

        val obj = uiDevice.findObject(selector)
        obj.click()

        delay()
    }

    fun allowPermissionWhileUsingApp() {
        val sdk = Build.VERSION.SDK_INT
        val resourceId = when {
            sdk <= Build.VERSION_CODES.P -> {
                "com.android.packageinstaller:id/permission_allow_button"
            }

            sdk == Build.VERSION_CODES.Q -> {
                "com.android.permissioncontroller:id/permission_allow_button"
            }

            else -> "com.android.permissioncontroller:id/permission_allow_foreground_only_button"
        }

        tap(UiSelector().resourceId(resourceId))
    }

    fun allowPermissionOnce() {
        val sdk = Build.VERSION.SDK_INT
        val resourceId = when {
            sdk <= Build.VERSION_CODES.P -> {
                "com.android.packageinstaller:id/permission_allow_button"
            }

            sdk == Build.VERSION_CODES.Q -> {
                "com.android.permissioncontroller:id/permission_allow_button"
            }

            else -> "com.android.permissioncontroller:id/permission_allow_foreground_only_button"
        }
        tap(UiSelector().resourceId(resourceId))
    }

    fun denyPermission() {
        val sdk = Build.VERSION.SDK_INT
        val resourceId = when {
            sdk <= Build.VERSION_CODES.P -> {
                "com.android.packageinstaller:id/permission_deny_button"
            }

            sdk == Build.VERSION_CODES.Q -> {
                "com.android.permissioncontroller:id/permission_deny_button"
            }

            else -> "com.android.permissioncontroller:id/permission_deny_button"
        }
        tap(UiSelector().resourceId(resourceId))
    }

    fun selectFineLocation() {
        tap(UiSelector().resourceId("com.android.permissioncontroller:id/permission_location_accuracy_radio_fine"))
    }

    fun selectCoarseLocation() {
        tap(UiSelector().resourceId("com.android.permissioncontroller:id/permission_location_accuracy_radio_coarse"))
    }

    companion object {
        val instance = PatrolAutomator()
    }
}

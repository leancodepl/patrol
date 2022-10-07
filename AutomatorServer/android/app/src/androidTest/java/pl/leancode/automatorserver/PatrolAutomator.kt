package pl.leancode.automatorserver

import android.app.UiAutomation
import android.os.SystemClock
import android.widget.EditText
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.By
import androidx.test.uiautomator.BySelector
import androidx.test.uiautomator.Configurator
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.UiObject2
import androidx.test.uiautomator.UiObjectNotFoundException
import androidx.test.uiautomator.UiSelector
import pl.leancode.automatorserver.contracts.Contracts
import pl.leancode.automatorserver.contracts.nativeView
import pl.leancode.automatorserver.contracts.notification
import kotlin.math.roundToInt

private fun fromUiObject2(obj: UiObject2): Contracts.NativeView {
    return nativeView {
        if (obj.className != null) {
            className = obj.className
        }

        if (obj.text != null) {
            text = obj.text
        }

        if (obj.contentDescription != null) {
            contentDescription = obj.contentDescription
        }

        focused = obj.isFocused
        enabled = obj.isEnabled
        childCount = obj.childCount

        if (obj.resourceName != null) {
            resourceName = obj.resourceName
        }

        if (obj.applicationPackage != null) {
            applicationPackage = obj.applicationPackage
        }

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

    private fun exists(byResourceId: String): Boolean {
        Logger.i("Checking if view with resourceId \"$byResourceId\" exists")
        return if (uiDevice.findObjects(By.res(byResourceId)).isNotEmpty()) {
            Logger.i("View with resourceId \"$byResourceId\" exists")
            true
        } else {
            Logger.i("View with resourceId \"$byResourceId\" doesn't exist")
            false
        }
    }

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

    fun enableAirplaneMode(): Unit = TODO()

    fun disableAirplaneMode(): Unit = TODO()

    fun disableCellular() = executeShellCommand("svc data disable")

    fun enableCellular() = executeShellCommand("svc data enable")

    fun disableWifi() = executeShellCommand("svc wifi disable")

    fun enableWifi() = executeShellCommand("svc wifi enable")

    fun enableBluetooth(): Unit = TODO()

    fun disableBluetooth(): Unit = TODO()

    fun getNativeViews(selector: BySelector): List<Contracts.NativeView> {
        Logger.d("getNativeViews()")

        val uiObjects2 = uiDevice.findObjects(selector)
        return uiObjects2.map { fromUiObject2(it) }
    }

    fun tap(selector: UiSelector) {
        Logger.d("tap() selector $selector")

        val uiObject = uiDevice.findObject(selector)

        Logger.d("Clicking on UIObject with text: ${uiObject.text}")
        uiObject.click()
        delay()
    }

    fun doubleTap(selector: UiSelector) {
        Logger.d("doubleTap() selector $selector")

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

        val notificationContainers = mutableListOf<UiObject2>()
        val identifiers = listOf(
            "android:id/status_bar_latest_event_content", // notification not bundled
            "com.android.systemui:id/expandableNotificationRow", // notifications bundled
        )

        for (identifier in identifiers) {
            val objects = uiDevice.findObjects(By.res(identifier))
            if (identifier == "com.android.systemui:id/expandableNotificationRow") {
                // the first element is invalid
                objects.removeFirstOrNull()
            }

            Logger.i("Found ${objects.size} notification containers with resourceId \"$identifier\"")
            notificationContainers.addAll(objects)
        }

        Logger.d("Found ${notificationContainers.size} notifications")

        val notifications = mutableListOf<Contracts.Notification>()
        for (notificationContainer in notificationContainers) {

            val notification = notification {
                val appName = notificationContainer.findObject(By.res("android:id/app_name_text"))?.text
                if (appName != null) {
                    this.appName = appName
                }

                val title = notificationContainer.findObject(By.res("android:id/title"))?.text
                    ?: notificationContainer.findObject(By.res("com.android.systemui:id/notification_title"))?.text
                if (title != null) {
                    this.title = title
                } else {
                    Logger.e("Could not find title text")
                }

                val content = notificationContainer.findObject(By.res("android:id/text"))?.text
                    ?: notificationContainer.findObject(By.res("android:id/big_text"))?.text
                    ?: notificationContainer.findObject(By.res("com.android.systemui:id/notification_text"))?.text
                if (content != null) {
                    this.content = content
                } else {
                    Logger.e("Could not find content text")
                }
            }
            notifications.add(notification)
        }

        return notifications
    }

    fun tapOnNotification(index: Int) {
        Logger.d("tapOnNotification($index)")

        openNotifications()

        try {
            val query = Contracts.Selector.newBuilder().setResourceId("android:id/status_bar_latest_event_content")
                .setInstance(index).build()
            val obj = uiDevice.findObject(query.toUiSelector())
            obj.click()
        } catch (err: UiObjectNotFoundException) {
            throw UiObjectNotFoundException("notification at index $index")
        }

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
        val identifiers = listOf(
            "com.android.packageinstaller:id/permission_allow_button",
            "com.android.permissioncontroller:id/permission_allow_button",
            "com.android.permissioncontroller:id/permission_allow_foreground_only_button",
        )

        for (identifier in identifiers) {
            if (exists(identifier)) {
                uiDevice.findObject(UiSelector().resourceId(identifier)).click()
                return
            }
        }

        throw UiObjectNotFoundException("button to allow permission while using")
    }

    fun allowPermissionOnce() {
        val identifiers = listOf(
            "com.android.packageinstaller:id/permission_allow_button",
            "com.android.permissioncontroller:id/permission_allow_button",
            "com.android.permissioncontroller:id/permission_allow_one_time_button",
        )

        for (identifier in identifiers) {
            if (exists(identifier)) {
                uiDevice.findObject(UiSelector().resourceId(identifier)).click()
                return
            }
        }

        throw UiObjectNotFoundException("button to allow permission once")
    }

    fun denyPermission() {
        val identifiers = listOf(
            "com.android.packageinstaller:id/permission_deny_button",
            "com.android.permissioncontroller:id/permission_deny_button",
        )

        for (identifier in identifiers) {
            if (exists(identifier)) {
                uiDevice.findObject(UiSelector().resourceId(identifier)).click()
                return
            }
        }

        throw UiObjectNotFoundException("button to deny permission")
    }

    fun selectFineLocation() {
        val resourceId = "com.android.permissioncontroller:id/permission_location_accuracy_radio_fine"
        if (uiDevice.findObjects(By.res(resourceId)).isNotEmpty()) {
            uiDevice.findObject(UiSelector().resourceId(resourceId)).click()
        } else {
            throw UiObjectNotFoundException("button to select fine location")
        }
    }

    fun selectCoarseLocation() {
        val resourceId = "com.android.permissioncontroller:id/permission_location_accuracy_radio_coarse"
        if (uiDevice.findObjects(By.res(resourceId)).isNotEmpty()) {
            uiDevice.findObject(UiSelector().resourceId(resourceId)).click()
        } else {
            throw UiObjectNotFoundException("button to select coarse location")
        }
    }

    companion object {
        val instance = PatrolAutomator()
    }
}

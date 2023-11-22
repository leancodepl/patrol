package pl.leancode.patrol

import android.app.Instrumentation
import android.app.UiAutomation
import android.content.Context
import android.os.Build
import android.os.SystemClock
import android.widget.EditText
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.By
import androidx.test.uiautomator.BySelector
import androidx.test.uiautomator.Configurator
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.UiObject
import androidx.test.uiautomator.UiObject2
import androidx.test.uiautomator.UiObjectNotFoundException
import androidx.test.uiautomator.UiSelector
import pl.leancode.patrol.contracts.Contracts.KeyboardBehavior
import pl.leancode.patrol.contracts.Contracts.NativeView
import pl.leancode.patrol.contracts.Contracts.Notification
import pl.leancode.patrol.contracts.Contracts.Selector
import kotlin.math.roundToInt

private fun fromUiObject2(obj: UiObject2): NativeView {
    return NativeView(
        className = obj.className,
        text = obj.text,
        contentDescription = obj.contentDescription,
        focused = obj.isFocused,
        enabled = obj.isEnabled,
        childCount = obj.childCount.toLong(),
        resourceName = obj.resourceName,
        applicationPackage = obj.applicationPackage,
        children = obj.children?.map { fromUiObject2(it) } ?: listOf()
    )
}

class Automator private constructor() {
    private var timeoutMillis: Long = 10_000

    private lateinit var instrumentation: Instrumentation
    private lateinit var configurator: Configurator
    private lateinit var uiDevice: UiDevice
    private lateinit var targetContext: Context
    private lateinit var uiAutomation: UiAutomation

    fun initialize() {
        if (!this::instrumentation.isInitialized) {
            instrumentation = InstrumentationRegistry.getInstrumentation()
        }
        if (!this::targetContext.isInitialized) {
            targetContext = instrumentation.targetContext
        }
        if (!this::configurator.isInitialized) {
            configurator = Configurator.getInstance()
        }
        if (!this::uiDevice.isInitialized) {
            uiDevice = UiDevice.getInstance(instrumentation)
        }
        if (!this::uiAutomation.isInitialized) {
            uiAutomation = instrumentation.uiAutomation
        }
    }

    fun configure(waitForSelectorTimeout: Long) {
        timeoutMillis = waitForSelectorTimeout
        configurator.waitForSelectorTimeout = waitForSelectorTimeout
        configurator.waitForIdleTimeout = 5000
        configurator.keyInjectionDelay = 50

        configurator.uiAutomationFlags = UiAutomation.FLAG_DONT_SUPPRESS_ACCESSIBILITY_SERVICES

        Logger.i("Timeout: $timeoutMillis ms")
        Logger.i("Android UiAutomator configuration:")
        Logger.i("\twaitForSelectorTimeout: ${configurator.waitForSelectorTimeout} ms")
        Logger.i("\twaitForIdleTimeout: ${configurator.waitForIdleTimeout} ms")
        Logger.i("\tkeyInjectionDelay: ${configurator.keyInjectionDelay} ms")
        Logger.i("\tactionAcknowledgmentTimeout: ${configurator.actionAcknowledgmentTimeout} ms")
        Logger.i("\tscrollAcknowledgmentTimeout: ${configurator.scrollAcknowledgmentTimeout} ms")
        Logger.i("\ttoolType: ${configurator.toolType}")
        Logger.i("\tuiAutomationFlags: ${configurator.uiAutomationFlags}")
    }

    private fun executeShellCommand(cmd: String) {
        uiDevice.executeShellCommand(cmd)
        delay()
    }

    private fun delay(ms: Long = 1000) = SystemClock.sleep(ms)

    fun openApp(packageName: String) {
        val intent = targetContext.packageManager!!.getLaunchIntentForPackage(packageName)
            ?: throw Exception("intent for launching package \"$packageName\" is null. Make sure you have android.permission.QUERY_ALL_PACKAGES in AndroidManifest.xml")
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

    fun enableAirplaneMode(): Unit = throw NotImplementedError("enableAirplaneMode")

    fun disableAirplaneMode(): Unit = throw NotImplementedError("disableAirplaneMode")

    fun disableCellular() = executeShellCommand("svc data disable")

    fun enableCellular() = executeShellCommand("svc data enable")

    fun disableWifi() = executeShellCommand("svc wifi disable")

    fun enableWifi() = executeShellCommand("svc wifi enable")

    fun enableBluetooth(): Unit = throw NotImplementedError("enableBluetooth")

    fun disableBluetooth(): Unit = throw NotImplementedError("disableBluetooth")

    fun getNativeViews(selector: BySelector): List<NativeView> {
        Logger.d("getNativeViews()")

        val uiObjects2 = uiDevice.findObjects(selector)
        return uiObjects2.map { fromUiObject2(it) }
    }

    fun getNativeUITrees(): List<NativeView> {
        Logger.d("getNativeUITrees()")

        return getWindowTrees(uiDevice, uiAutomation)
    }

    fun tap(uiSelector: UiSelector, bySelector: BySelector, index: Int) {
        Logger.d("tap(): $uiSelector, $bySelector")

        if (waitForView(bySelector, index) == null) {
            throw UiObjectNotFoundException("$uiSelector")
        }

        val uiObject = uiDevice.findObject(uiSelector)
        Logger.d("Clicking on UIObject with text: ${uiObject.text}")
        uiObject.click()
        delay()
    }

    fun doubleTap(uiSelector: UiSelector, bySelector: BySelector, index: Int) {
        Logger.d("doubleTap(): $uiSelector, $bySelector")

        val uiObject = uiDevice.findObject(uiSelector)

        if (waitForView(bySelector, index) == null) {
            throw UiObjectNotFoundException("$uiSelector")
        }

        Logger.d("Double clicking on UIObject with text: ${uiObject.text}")
        uiObject.click()
        Logger.d("After first click")
        delay(ms = 300)
        uiObject.click()
        Logger.d("After second click")
        delay()
    }

    fun enterText(text: String, index: Int, keyboardBehavior: KeyboardBehavior) {
        Logger.d("enterText(text: $text, index: $index)")

        val selector = By.clazz(EditText::class.java)
        if (waitForView(selector, index) == null) {
            throw UiObjectNotFoundException("$selector")
        }

        Logger.d("entering text \"$text\" to EditText at index $index")

        val uiSelector = UiSelector().className(EditText::class.java).instance(index)
        val uiObject = uiDevice.findObject(uiSelector)

        if (keyboardBehavior == KeyboardBehavior.showAndDismiss) {
            uiObject.click()
        }

        uiObject.text = text

        if (keyboardBehavior == KeyboardBehavior.showAndDismiss) {
            pressBack() // Hide keyboard.
        }
    }

    fun enterText(
        text: String,
        uiSelector: UiSelector,
        bySelector: BySelector,
        index: Int,
        keyboardBehavior: KeyboardBehavior
    ) {
        Logger.d("enterText($text): $uiSelector, $bySelector")

        if (waitForView(bySelector, index) == null) {
            throw UiObjectNotFoundException("$uiSelector")
        }

        val uiObject = uiDevice.findObject(uiSelector).getFromParent(UiSelector().className(EditText::class.java))

        if (keyboardBehavior == KeyboardBehavior.showAndDismiss) {
            uiObject.click()
        }

        uiObject.text = text

        if (keyboardBehavior == KeyboardBehavior.showAndDismiss) {
            pressBack() // Hide keyboard.
        }
    }

    fun swipe(startX: Float, startY: Float, endX: Float, endY: Float, steps: Int) {
        Logger.d("swipe(startX: $startX, startY: $startY, endX: $endX, endY: $endY, steps: $steps)")

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

    fun waitUntilVisible(uiSelector: UiSelector, bySelector: BySelector, index: Int) {
        Logger.d("waitUntilVisible(): $uiSelector, $bySelector")

        if (waitForView(bySelector, index) == null) {
            throw UiObjectNotFoundException("$uiSelector")
        }
    }

    fun openNotifications() {
        Logger.d("openNotifications()")
        val success = uiDevice.openNotification()
        if (!success) {
            throw PatrolException("Could not open notifications")
        }
        delay()
    }

    fun closeNotifications() {
        Logger.d("closeNotifications()")
        val success = uiDevice.pressBack()
        if (!success) {
            throw PatrolException("Could not close notifications")
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

    fun getNotifications(): List<Notification> {
        Logger.d("getNotifications()")

        val notificationContainers = mutableListOf<UiObject2>()
        val identifiers = listOf(
            "android:id/status_bar_latest_event_content", // notification not bundled
            "com.android.systemui:id/expandableNotificationRow" // notifications bundled
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

        val notifications = mutableListOf<Notification>()
        for (notificationContainer in notificationContainers) {
            val appName = notificationContainer.findObject(By.res("android:id/app_name_text"))?.text

            val content = notificationContainer.findObject(By.res("android:id/text"))?.text
                ?: notificationContainer.findObject(By.res("android:id/big_text"))?.text
                ?: notificationContainer.findObject(By.res("com.android.systemui:id/notification_text"))?.text
            if (content == null) {
                Logger.e("Could not find content text")
            }

            val title = notificationContainer.findObject(By.res("android:id/title"))?.text
                ?: notificationContainer.findObject(By.res("com.android.systemui:id/notification_title"))?.text
            if (title == null) {
                Logger.e("Could not find title text")
            }

            val notification = Notification(
                appName = appName,
                content = content ?: "",
                title = title ?: ""
            )

            notifications.add(notification)
        }

        return notifications
    }

    fun tapOnNotification(index: Int) {
        Logger.d("tapOnNotification($index)")

        try {
            val query = Selector(
                resourceId = "android:id/status_bar_latest_event_content",
                instance = index.toLong()
            )
            val obj = uiDevice.findObject(query.toUiSelector())
            obj.click()
        } catch (err: UiObjectNotFoundException) {
            throw UiObjectNotFoundException("notification at index $index")
        }

        delay()
    }

    fun tapOnNotification(selector: UiSelector) {
        Logger.d("tapOnNotification()")

        val obj = uiDevice.findObject(selector)
        obj.click()

        delay()
    }

    fun isPermissionDialogVisible(timeout: Long): Boolean {
        val identifiers = arrayOf(
            // while using
            "com.android.packageinstaller:id/permission_allow_button",
            "com.android.permissioncontroller:id/permission_allow_button",
            "com.android.permissioncontroller:id/permission_allow_foreground_only_button",
            // once
            "com.android.packageinstaller:id/permission_allow_button",
            "com.android.permissioncontroller:id/permission_allow_button",
            "com.android.permissioncontroller:id/permission_allow_one_time_button",
            // deny
            "com.android.packageinstaller:id/permission_deny_button",
            "com.android.permissioncontroller:id/permission_deny_button"
        )

        val uiObject = waitForUiObjectByResourceId(*identifiers, timeout = timeout)
        return uiObject != null
    }

    fun allowPermissionWhileUsingApp() {
        val identifiers = arrayOf(
            "com.android.packageinstaller:id/permission_allow_button", // API <= 28
            "com.android.permissioncontroller:id/permission_allow_button", // API 29
            "com.android.permissioncontroller:id/permission_allow_foreground_only_button" // API >= 30 + API 29 (only for location permission)
        )

        val uiObject = waitForUiObjectByResourceId(*identifiers, timeout = timeoutMillis)
            ?: throw UiObjectNotFoundException("button to allow permission while using")

        uiObject.click()
    }

    fun allowPermissionOnce() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            // One-time permissions are available only on API 30 (R) and above.
            // See: https://developer.android.com/training/permissions/requesting#one-time
            allowPermissionWhileUsingApp()
            return
        }

        val identifiers = arrayOf(
            "com.android.permissioncontroller:id/permission_allow_one_time_button" // API >= 30
        )

        val uiObject = waitForUiObjectByResourceId(*identifiers, timeout = timeoutMillis)
            ?: throw UiObjectNotFoundException("button to allow permission once")

        uiObject.click()
    }

    fun denyPermission() {
        val identifiers = arrayOf(
            "com.android.packageinstaller:id/permission_deny_button", // API <= 28
            "com.android.permissioncontroller:id/permission_deny_button" // API >= 29
        )

        val uiObject = waitForUiObjectByResourceId(*identifiers, timeout = timeoutMillis)
            ?: throw UiObjectNotFoundException("button to deny permission")

        uiObject.click()
    }

    fun selectFineLocation() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            Logger.i("Ignoring selectFineLocation() since it's not available on ${Build.VERSION.SDK_INT}")
            return
        }

        val resourceId = "com.android.permissioncontroller:id/permission_location_accuracy_radio_fine"

        val uiObject = waitForUiObjectByResourceId(resourceId, timeout = timeoutMillis)
            ?: throw UiObjectNotFoundException("button to select fine location")

        uiObject.click()
    }

    fun selectCoarseLocation() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            Logger.i("Ignoring selectFineLocation() since it's not available on ${Build.VERSION.SDK_INT}")
            return
        }

        val resourceId = "com.android.permissioncontroller:id/permission_location_accuracy_radio_coarse"

        val uiObject = waitForUiObjectByResourceId(resourceId, timeout = timeoutMillis)
            ?: throw UiObjectNotFoundException("button to select coarse location")

        uiObject.click()
    }

    /**
     * Returns true if [bySelector] found a view at [index] within [timeoutMillis], false otherwise.
     */
    private fun waitForView(bySelector: BySelector, index: Int): UiObject2? {
        val startTime = System.currentTimeMillis()
        while (System.currentTimeMillis() - startTime < timeoutMillis) {
            val objects = uiDevice.findObjects(bySelector)
            if (objects.size > index && objects[index] != null) {
                return objects[index]
            }

            delay(ms = 500)
        }

        return null
    }

    private fun waitForUiObjectByResourceId(vararg identifiers: String, timeout: Long): UiObject? {
        val startTime = System.currentTimeMillis()
        while (System.currentTimeMillis() - startTime < timeout) {
            for (ident in identifiers) {
                val bySelector = By.res(ident)
                if (uiDevice.findObjects(bySelector).isNotEmpty()) {
                    return uiDevice.findObject(UiSelector().resourceId(ident))
                }
            }

            delay(ms = 500)
        }

        return null
    }

    companion object {
        val instance = Automator()
    }
}

package pl.leancode.automatorserver

import android.os.SystemClock
import android.widget.EditText
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.*


class UIAutomatorInstrumentation {
    private fun getDevice(): UiDevice {
        return UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
    }

    fun pressHome() {
        val device = getDevice();
        Logger.i("Before press home")
        device.pressHome()
        SystemClock.sleep(1000);
        Logger.i("After press home")
    }

    fun pressRecentApps() {
        val device = getDevice()
        Logger.i("Before press recent apps")
        device.pressRecentApps()
        SystemClock.sleep(1000);
        Logger.i("Before press recent apps")
    }

    fun pressDoubleRecentApps() {
        val device = getDevice()
        Logger.i("Before press double recent apps")
        device.pressRecentApps()
        SystemClock.sleep(1000);
        device.pressRecentApps()
        SystemClock.sleep(1000);
        Logger.i("After press double recent apps")
    }

    fun getNativeTextField() {
        val device = getDevice()

        val selector = UiSelector().className(EditText::class.java).instance(0)
        val emailInput = device.findObject(selector)

        Logger.i("text: ${emailInput.text}")
        Logger.i("content description: ${emailInput.contentDescription}")
    }

    fun setNativeTextField(text: String) {
        val device = getDevice()

        val selector = UiSelector().className(EditText::class.java).instance(0)
        val emailInput = device.findObject(selector)

        emailInput.click()
        emailInput.text = text
        Logger.i("setting native text field to $text")
    }

    fun openNotifications() {
        val device = getDevice()
        device.openNotification()
    }

    companion object {
        val instance = UIAutomatorInstrumentation()
    }
}

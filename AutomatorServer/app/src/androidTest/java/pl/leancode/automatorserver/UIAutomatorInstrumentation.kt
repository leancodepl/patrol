package pl.leancode.automatorserver

import android.os.SystemClock
import android.widget.Button
import android.widget.EditText
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.*
import kotlinx.serialization.Serializable

@Serializable
data class NativeTextField(
    val text: String?,
    val contentDescription: String?,
    val focused: Boolean?,
    val enabled: Boolean?,
) {
    companion object {
        fun fromUiObject(obj: UiObject2): NativeTextField {
            return NativeTextField(
                text = obj.text,
                contentDescription = obj.contentDescription,
                focused = obj.isFocused,
                enabled = obj.isEnabled,
            )
        }
    }
}

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

    fun getNativeTextField(index: Int): NativeTextField {
        return getNativeTextFields()[index]
    }

    fun getNativeTextFields(): List<NativeTextField> {
        val device = getDevice()

        val selector = By.clazz(EditText::class.java)

        return device.findObjects(selector).map { NativeTextField.fromUiObject(it) }
    }

    fun setNativeTextField(index: Int, text: String) {
        val device = getDevice()

        val selector = UiSelector().className(EditText::class.java).instance(index)
        val uiObject = device.findObject(selector)

        uiObject.click()
        uiObject.text = text
        Logger.i("setting native text field to $text")
    }

    fun setNativeButton(index: Int) {
        val device = getDevice()

        val selector = UiSelector().className(Button::class.java).instance(index)
        val uiObject = device.findObject(selector)

        uiObject.click()
        Logger.i("Tapped button at index $index")
    }

    fun openNotifications() {
        val device = getDevice()
        device.openNotification()
    }

    companion object {
        val instance = UIAutomatorInstrumentation()
    }
}

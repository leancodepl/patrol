package pl.leancode.automatorserver

import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.UiDevice
import com.orhanobut.logger.Logger

class UIAutomatorInstrumentation {
    private fun getDevice(): UiDevice {
        return UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
    }

    fun pressHome() {
        val device = getDevice();
        Logger.i("Before press home")
        device.pressHome()
        Logger.i("After press home")
    }

    fun pressRecentApps() {
        val device = getDevice()
        Logger.i("Before press recent apps")
        device.pressRecentApps()
        Logger.i("Before press recent apps")
    }

    fun pressDoubleRecentApps() {
        val device = getDevice()
        Logger.i("Before press double recent apps")
        device.pressRecentApps()
        device.pressRecentApps()
        Logger.i("After press double recent apps")
    }

    fun openNotifications() {
        val device = getDevice()
        device.openNotification()
    }

    companion object {
        val instance = UIAutomatorInstrumentation()
    }
}

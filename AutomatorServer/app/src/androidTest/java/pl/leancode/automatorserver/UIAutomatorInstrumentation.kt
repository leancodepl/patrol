package pl.leancode.automatorserver

import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.UiDevice
import com.orhanobut.logger.Logger

class UIAutomatorInstrumentation {
    fun pressHome() {
        val device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
        Logger.i("Before press home")
        device.pressHome()
        Logger.i("After press home")
    }

    fun pressRecentApps() {
        val device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
        Logger.i("Before press recent apps")
        device.pressRecentApps()
        Logger.i("Before press recent apps")
    }

    fun pressDoubleRecentApps() {
        val device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
        Logger.i("Before press double recent apps")
        device.pressRecentApps()
        device.pressRecentApps()
        Logger.i("After press double recent apps")
    }

    companion object {
        val instance = UIAutomatorInstrumentation()
    }
}

package pl.leancode.automatorserver

import androidx.test.ext.junit.runners.AndroidJUnit4
import com.orhanobut.logger.AndroidLogAdapter
import com.orhanobut.logger.Logger
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class AutomatorServer {
    @Test
    fun startServer() {
        Logger.addLogAdapter(AndroidLogAdapter())

        if (serverInstrumentation == null) {
            serverInstrumentation = ServerInstrumentation.instance
            Logger.i("Starting server")
            try {
                serverInstrumentation!!.startServer()
                while (!serverInstrumentation!!.isStopped) {
                }
            } catch (e: Exception) {
                e.printStackTrace()
                Logger.w("Exception thrown: ", e)
            }
        }
    }

    companion object {
        private var serverInstrumentation: ServerInstrumentation? = null
    }
}

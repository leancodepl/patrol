package pl.leancode.automatorserver

import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class AutomatorServer {
    @Test
    fun startServer() {
        if (serverInstrumentation == null) {
            serverInstrumentation = ServerInstrumentation.instance
            Logger.i("Starting server")
            try {
                serverInstrumentation!!.startServer()
                Logger.i("Server started")
                while (!serverInstrumentation!!.isStopped) {
                }
            } catch (e: Exception) {
                e.printStackTrace()
                Logger.e("Exception thrown: ", e)
            }
        }
    }

    companion object {
        private var serverInstrumentation: ServerInstrumentation? = null
    }
}

package pl.leancode.automatorserver

import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class AutomatorServer {
    @Test
    fun startServer() {
        Logger.i("Starting server")

        val serverInstrumentation = ServerInstrumentation.instance
        try {
            serverInstrumentation.start()
            Logger.i("Server started")
            while (serverInstrumentation.running) {
            }
        } catch (e: Exception) {
            e.printStackTrace()
            Logger.e("Exception thrown: ", e)
        }
    }
}


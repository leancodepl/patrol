package pl.leancode.automatorserver

import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class AutomatorServer {
    @Test
    fun startServer() {
        Logger.i("Starting server...")

        val maestroServer = MaestroServer.instance
        try {
            maestroServer.start()
            Logger.i("Server started")
            while (maestroServer.running) {
            }
        } catch (e: Exception) {
            e.printStackTrace()
            Logger.e("Exception thrown: ", e)
        }

        Logger.i("Server stopped")
    }
}

package pl.leancode.automatorserver

import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class ServerLoop {
    @Test
    fun startServer() {
        Logger.i("Starting server loop...")

        val patrolServer = PatrolServer()
        try {
            patrolServer.start()
        } catch (e: Exception) {
            Logger.e("Failure while running the server: ", e)
        }
        patrolServer.blockUntilShutdown()
    }
}

package pl.leancode.patrol.example

import android.content.Intent
import androidx.test.rule.ActivityTestRule
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch


open class PatrolTestRule : ActivityTestRule<MainActivity>(MainActivity::class.java, true, false) {
    override fun launchActivity(startIntent: Intent?): MainActivity {
        Logger.i("Starting server loop...")

        val patrolServer = PatrolServer()
        try {
            patrolServer.start()
        } catch (e: Exception) {
            Logger.e("Failure while running the server: ", e)
        }

        GlobalScope.launch {
            patrolServer.blockUntilShutdown()
        }

        return super.launchActivity(startIntent)
    }
}

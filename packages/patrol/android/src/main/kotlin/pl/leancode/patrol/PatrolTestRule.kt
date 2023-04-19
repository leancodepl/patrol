package pl.leancode.patrol

import android.app.Activity
import android.content.Intent
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.rule.ActivityTestRule
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class PatrolTestRule<T : Activity>(activityClass: Class<T>) :
    ActivityTestRule<T>(activityClass, true, false) {

    lateinit var patrolServer: PatrolServer

    @OptIn(DelicateCoroutinesApi::class)
    override fun launchActivity(startIntent: Intent?): T {
        Logger.i("Starting server loop...")

        patrolServer = PatrolServer()
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

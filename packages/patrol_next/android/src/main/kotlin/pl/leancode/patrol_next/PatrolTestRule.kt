package pl.leancode.patrol_next

import android.app.Activity
import android.content.Intent
import androidx.test.rule.ActivityTestRule
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch


class PatrolTestRule<T : Activity> : ActivityTestRule<T> {

    private val activityClass: Class<T>

    constructor(activityClass: Class<T>) : super(activityClass, true, false) {
        this.activityClass = activityClass
    }

    override fun launchActivity(startIntent: Intent?): T {
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

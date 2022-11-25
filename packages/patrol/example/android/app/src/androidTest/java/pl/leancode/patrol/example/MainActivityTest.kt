package pl.leancode.patrol.example

import android.content.Intent
import androidx.test.rule.ActivityTestRule
import dev.flutter.plugins.integration_test.FlutterTestRunner
import org.junit.Rule
import org.junit.runner.RunWith


class PatrolTestRule : ActivityTestRule<MainActivity>(MainActivity::class.java, true, false) {
    override fun launchActivity(startIntent: Intent?): MainActivity {
//        Logger.i("Starting server loop...")
//
//        val patrolServer = PatrolServer()
//        try {
//            patrolServer.start()
//        } catch (e: Exception) {
//            Logger.e("Failure while running the server: ", e)
//        }
//        // patrolServer.blockUntilShutdown()

        return super.launchActivity(startIntent)
    }
}

@RunWith(FlutterTestRunner::class)
class MainActivityTest {

    @Rule
    var rule = PatrolTestRule()
}

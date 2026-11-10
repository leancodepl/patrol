package pl.leancode.patrol.e2e_app

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper

/**
 * Handles `patrol-recreate://` links the way many apps handle a link that arrives while they
 * run: it starts [MainActivity] in a cleared task. That destroys the running activity and
 * its Flutter engine, but not the process.
 *
 * `patrol-recreate://slow` does it 3 seconds later, like an app that does some work first.
 */
class RecreateActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val context = applicationContext
        val intent = Intent(context, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
        val delayMillis = if (getIntent().data?.host == "slow") 3000L else 0L
        Handler(Looper.getMainLooper()).postDelayed({ context.startActivity(intent) }, delayMillis)
        finish()
    }
}

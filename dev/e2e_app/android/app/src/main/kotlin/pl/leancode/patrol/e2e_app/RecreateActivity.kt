package pl.leancode.patrol.e2e_app

import android.app.Activity
import android.content.Intent
import android.os.Bundle

/**
 * Handles `patrol-recreate://` links the way many apps handle a link that arrives while they
 * run: it starts [MainActivity] in a cleared task. That destroys the running activity and
 * its Flutter engine, but not the process.
 */
class RecreateActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val intent = Intent(this, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
        startActivity(intent)
        finish()
    }
}

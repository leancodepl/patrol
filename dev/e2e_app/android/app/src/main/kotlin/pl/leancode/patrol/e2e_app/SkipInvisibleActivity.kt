package pl.leancode.patrol.e2e_app

import android.app.Activity
import android.os.Bundle
import pl.leancode.patrol.skipNodesNotVisibleToUser

/** Sets patrol's tree-walk flag, so one build can run both variants. */
class SkipInvisibleActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        skipNodesNotVisibleToUser =
            intent?.data?.getQueryParameter("value")?.toBoolean() ?: true
        finish()
    }
}

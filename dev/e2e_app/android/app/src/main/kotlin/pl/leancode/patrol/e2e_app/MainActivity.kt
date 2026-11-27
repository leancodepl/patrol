package pl.leancode.patrol.e2e_app

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    // Read by patrol_test/entrypoint_args_test.dart.
    override fun getDartEntrypointArgs(): List<String> = listOf("--patrol-e2e")
}

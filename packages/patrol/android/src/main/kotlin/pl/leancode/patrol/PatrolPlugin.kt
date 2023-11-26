package pl.leancode.patrol

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class PatrolPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel

    private var isInitialRun: Boolean? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "pl.leancode.patrol/main")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "isInitialRun" -> result.success(isInitialRun)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        val intent = binding.activity.intent
        if (!intent.hasExtra("isInitialRun")) {
            throw IllegalStateException("PatrolPlugin must be initialized with intent having isInitialRun boolean")
        }

        isInitialRun = intent.getBooleanExtra("isInitialRun", false)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // Do nothing
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        // Do nothing
    }

    override fun onDetachedFromActivity() {
        // Do nothing
    }
}

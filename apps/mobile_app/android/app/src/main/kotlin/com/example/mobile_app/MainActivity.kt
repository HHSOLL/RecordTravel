package com.example.mobile_app

import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "travel_atlas/runtime_capabilities",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasGoogleMapsKey" -> result.success(hasGoogleMapsKey())
                else -> result.notImplemented()
            }
        }
    }

    private fun hasGoogleMapsKey(): Boolean {
        val appInfo = packageManager.getApplicationInfo(
            packageName,
            PackageManager.GET_META_DATA,
        )
        val apiKey = appInfo.metaData?.getString("com.google.android.geo.API_KEY")
        return !apiKey.isNullOrBlank()
    }
}

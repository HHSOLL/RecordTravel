package com.example.mobile_app

import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private fun bundleString(metaKey: String): String? {
        val appInfo = packageManager.getApplicationInfo(
            packageName,
            PackageManager.GET_META_DATA,
        )
        val rawValue = appInfo.metaData?.getString(metaKey)?.trim()
        return if (rawValue.isNullOrBlank() || rawValue.startsWith("$")) null else rawValue
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "travel_atlas/runtime_capabilities",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasGoogleMapsKey" -> result.success(hasGoogleMapsKey())
                "getMapConfig" -> result.success(
                    mapOf(
                        "hasGoogleMapsKey" to hasGoogleMapsKey(),
                        "hasNaverMapClientId" to hasNaverMapClientId(),
                        "naverMapClientId" to naverMapClientId(),
                    ),
                )
                else -> result.notImplemented()
            }
        }
    }

    private fun hasGoogleMapsKey(): Boolean {
        return bundleString("com.google.android.geo.API_KEY") != null
    }

    private fun naverMapClientId(): String? {
        return bundleString("com.hhsoll.recordtravel.NAVER_MAP_CLIENT_ID")
    }

    private fun hasNaverMapClientId(): Boolean {
        return naverMapClientId() != null
    }
}

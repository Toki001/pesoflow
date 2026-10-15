package com.pesoflow.pesoflow

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.pesoflow/app_info")
            .setMethodCallHandler { call, result ->
                if (call.method != "version") {
                    result.notImplemented()
                } else {
                    @Suppress("DEPRECATION")
                    val info = packageManager.getPackageInfo(packageName, 0)
                    @Suppress("DEPRECATION")
                    val build = if (Build.VERSION.SDK_INT >= 28) info.longVersionCode else info.versionCode.toLong()
                    result.success(mapOf("version" to info.versionName, "build" to build.toString()))
                }
            }
    }
}

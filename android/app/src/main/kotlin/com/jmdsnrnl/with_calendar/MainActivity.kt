package com.jmdsnrnl.with_calendar

import android.content.ActivityNotFoundException
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app.share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "shareToKakao" -> {
                        val text = (call.argument<String>("text") ?: "")
                        val kakaoPkg = "com.kakao.talk"

                        // 카카오에 바로 보내기 (텍스트 공유)
                        val intent = Intent(Intent.ACTION_SEND).apply {
                            type = "text/plain"
                            putExtra(Intent.EXTRA_TEXT, text)
                            setPackage(kakaoPkg)
                        }

                        try {
                            startActivity(intent)
                            result.success(null)
                        } catch (e: ActivityNotFoundException) {
                            // 미설치거나 실패 시: 일반 공유 시트로 폴백
                            val chooser = Intent(Intent.ACTION_SEND).apply {
                                type = "text/plain"
                                putExtra(Intent.EXTRA_TEXT, text)
                            }
                            startActivity(Intent.createChooser(chooser, "공유하기"))
                            result.success(null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}

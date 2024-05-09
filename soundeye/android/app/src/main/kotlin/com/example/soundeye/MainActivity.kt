package com.example.soundeye

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.math.absoluteValue

class MainActivity: FlutterActivity() {
  private val CHANNEL = "samples.flutter.dev/audioprocessing"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      call, result ->
      if (call.method == "square") {
        result.success(square(call.argument<Int>("number")))
      } else {
        result.notImplemented()
      }
    }
  }

  private fun square(input: Int?): Int {
    val input_sure: Int = input?.absoluteValue ?: 0
    return input_sure * input_sure
  }
}
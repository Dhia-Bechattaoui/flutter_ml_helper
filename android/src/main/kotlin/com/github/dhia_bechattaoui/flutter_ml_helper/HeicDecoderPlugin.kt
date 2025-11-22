package com.github.dhia_bechattaoui.flutter_ml_helper

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

/** HeicDecoderPlugin */
class HeicDecoderPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "flutter_ml_helper/heic_decoder")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "decodeHeic" -> {
                val bytes = call.argument<ByteArray>("bytes")
                if (bytes == null) {
                    result.error("INVALID_ARGUMENT", "Bytes cannot be null", null)
                    return
                }
                decodeHeic(bytes, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun decodeHeic(bytes: ByteArray, result: MethodChannel.Result) {
        try {
            // Android 9+ (API 28+) has native HEIC support via BitmapFactory
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
                
                if (bitmap == null) {
                    result.error("DECODE_ERROR", "Failed to decode HEIC image", null)
                    return
                }

                // Convert bitmap to PNG bytes (for compatibility with image package)
                val outputStream = ByteArrayOutputStream()
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
                val pngBytes = outputStream.toByteArray()
                
                result.success(pngBytes)
            } else {
                result.error(
                    "UNSUPPORTED_VERSION",
                    "HEIC decoding requires Android 9 (API 28) or higher. Current: ${Build.VERSION.SDK_INT}",
                    null
                )
            }
        } catch (e: Exception) {
            result.error("DECODE_ERROR", "Failed to decode HEIC: ${e.message}", null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}





package com.github.dhia_bechattaoui.flutter_ml_helper

import io.flutter.embedding.engine.plugins.FlutterPlugin

/** FlutterMlHelperPlugin - Main plugin class that registers all sub-plugins */
class FlutterMlHelperPlugin : FlutterPlugin {
    private val heicDecoderPlugin = HeicDecoderPlugin()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Register HEIC decoder plugin
        heicDecoderPlugin.onAttachedToEngine(binding)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Clean up
        heicDecoderPlugin.onDetachedFromEngine(binding)
    }
}







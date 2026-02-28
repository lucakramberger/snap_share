package com.snap_share.plugin

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import java.io.File

/**
 * Flutter plugin for sharing content to Snapchat.
 *
 * Uses Snapchat's Creative Kit Lite intent-based sharing on Android.
 */
class SnapSharePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.snap_share.package/channel")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "isInstalled" -> {
                result.success(isSnapchatInstalled())
            }
            "sharePhoto" -> {
                handleSharePhoto(call, result)
            }
            "shareVideo" -> {
                result.error(
                    "UNSUPPORTED",
                    "Video sharing is not supported on Android",
                    null
                )
            }
            "openCamera" -> {
                result.error(
                    "UNSUPPORTED",
                    "Camera sticker is not supported on Android",
                    null
                )
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * Checks if Snapchat is installed on the device.
     */
    private fun isSnapchatInstalled(): Boolean {
        return try {
            context.packageManager.getPackageInfo("com.snapchat.android", 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    /**
     * Handles the sharePhoto method call.
     */
    private fun handleSharePhoto(call: MethodCall, result: Result) {
        val imagePath = call.argument<String>("imagePath")
        val caption = call.argument<String>("caption")
        val stickerPath = call.argument<String>("stickerPath")

        if (imagePath.isNullOrEmpty()) {
            result.error("INVALID_ARGUMENTS", "imagePath is required", null)
            return
        }

        val currentActivity = activity
        if (currentActivity == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        try {
            shareToSnapchat(currentActivity, imagePath, caption, stickerPath, result)
        } catch (e: Exception) {
            result.error("SHARE_ERROR", e.message, null)
        }
    }

    /**
     * Shares content to Snapchat using Creative Kit Lite intents.
     */
    private fun shareToSnapchat(
        activity: Activity,
        imagePath: String,
        caption: String?,
        stickerPath: String?,
        result: Result
    ) {
        val intent = Intent(Intent.ACTION_SEND).apply {
            setPackage("com.snapchat.android")
            setDataAndType(Uri.parse("snapchat://creativekit/preview"), "image/*")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        // Add background image
        val imageFile = File(imagePath)
        if (!imageFile.exists()) {
            result.error("FILE_NOT_FOUND", "Image file not found: $imagePath", null)
            return
        }

        val authority = "${context.packageName}.fileprovider"
        val imageUri = FileProvider.getUriForFile(context, authority, imageFile)
        intent.putExtra(Intent.EXTRA_STREAM, imageUri)
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

        // Add sticker if provided
        if (!stickerPath.isNullOrEmpty()) {
            val stickerFile = File(stickerPath)
            if (stickerFile.exists()) {
                val stickerUri = FileProvider.getUriForFile(context, authority, stickerFile)

                // Create sticker JSON configuration
                val stickerJson = JSONObject().apply {
                    put("uri", stickerUri.toString())
                    put("posX", 0.5)  // Center horizontally
                    put("posY", 0.5)  // Center vertically
                    put("rotation", 0)
                    put("widthDp", 300)
                    put("heightDp", 400)
                }

                intent.putExtra("sticker", stickerJson.toString())
                activity.grantUriPermission(
                    "com.snapchat.android",
                    stickerUri,
                    Intent.FLAG_GRANT_READ_URI_PERMISSION
                )
            }
        }

        // Add caption if provided
        if (!caption.isNullOrEmpty()) {
            intent.putExtra("captionText", caption)
        }

        // Check if Snapchat can handle the intent
        if (context.packageManager.resolveActivity(intent, 0) != null) {
            activity.startActivity(intent)
            result.success(null)
        } else {
            result.error(
                "SNAPCHAT_NOT_INSTALLED",
                "Snapchat is not installed or cannot handle this intent",
                null
            )
        }
    }
}

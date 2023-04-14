package com.themonstersapp.share_me

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import android.content.Intent
import android.content.Intent.ACTION_SEND
import android.content.Intent.EXTRA_SUBJECT
import android.content.Intent.EXTRA_TEXT
import android.content.Intent.EXTRA_TITLE
import android.content.Intent.EXTRA_STREAM
import android.net.Uri
import android.webkit.MimeTypeMap
import androidx.core.content.FileProvider
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import java.io.OutputStream
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

class ShareMePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var context: android.content.Context

    companion object {
        private const val CHANNEL_NAME = "share_me"

        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            ShareMePlugin().apply {
                channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
                channel.setMethodCallHandler(this)
                context = registrar.context()
            }
        }
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "share_me_system" -> {
                val title = call.argument<String>("title")
                val url = call.argument<String>("url")
                val description = call.argument<String>("description")
                val subject = call.argument<String>("subject")
                val files = call.argument<List<String>>("files")
                share(title, url, description, subject, files)
                result.success(null)
            }
            "share_me_file" -> {
                val title = call.argument<String>("title")
                val byteArray = call.argument<ByteArray>("file")
                shareFile(title, byteArray)
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun share(title: String?, url: String?, description: String?, subject: String?, files: List<String>?) {
        val intent = Intent(ACTION_SEND)
        intent.type = "*/*"
        intent.putExtra(EXTRA_TITLE, title)
        intent.putExtra(EXTRA_SUBJECT, subject)

        // Concatenar la descripción y la URL en el mensaje
        var message = ""
        if (!description.isNullOrEmpty()) {
            message += "$description\n"
        }
        if (!url.isNullOrEmpty()) {
            message += "$url"
        }
        intent.putExtra(EXTRA_TEXT, message)

        if (files != null && files.isNotEmpty()) {
            val uris = ArrayList<Uri>()
            for (filePath in files) {
                val file = File(filePath)
                val fileUri = FileProvider.getUriForFile(context, context.packageName + ".fileprovider", file)
                uris.add(fileUri)
            }
            intent.putExtra(EXTRA_STREAM, uris)
        }

        val chooserIntent = Intent.createChooser(intent, "Share")
        chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(chooserIntent)
    }

    private fun shareFile(title: String?, byteArray: ByteArray?) {
        val file = File(context.cacheDir, "shared_file.jpg")
        file.createNewFile()
        val fileOutputStream = FileOutputStream(file)
        fileOutputStream.write(byteArray)
        fileOutputStream.flush()
        fileOutputStream.close()

        val fileUri = FileProvider.getUriForFile(context, context.packageName + ".fileprovider", file)

        val intent = Intent(ACTION_SEND)
        intent.type = "image/jpeg"
        intent.putExtra(EXTRA_TITLE, title)
        intent.putExtra(EXTRA_STREAM, fileUri)
        val chooserIntent = Intent.createChooser(intent, "Share")
        chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(chooserIntent)
    }
}

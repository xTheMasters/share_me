package com.themonstersapp.share_me

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.content.Intent.ACTION_SEND
import android.content.Intent.EXTRA_SUBJECT
import android.content.Intent.EXTRA_TEXT
import android.content.Intent.EXTRA_TITLE
import android.content.Intent.EXTRA_STREAM
import android.net.Uri
import androidx.core.content.FileProvider
import java.io.File
import java.io.FileOutputStream

class ShareMePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var context: android.content.Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "share_me")
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
                share(title, url, description, subject)
                result.success(null)
            }            
            "share_me_file" -> {
                val name = call.argument<String>("name")
                val mimeType = call.argument<String>("mimeType")
                val file = call.argument<ByteArray>("file")
                shareFile(name, mimeType, file)
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun share(title: String?, url: String?, description: String?, subject: String?) {
        val intent = Intent(ACTION_SEND)
        intent.type = "text/plain"
        intent.putExtra(EXTRA_TITLE, title)
        intent.putExtra(EXTRA_SUBJECT, subject)
       
        var message = ""
        if (!description.isNullOrEmpty()) {
            message += "$description\n"
        }
        if (!url.isNullOrEmpty()) {
            message += "$url"
        }
        intent.putExtra(EXTRA_TEXT, message)      

        val chooserIntent = Intent.createChooser(intent, "Share")
        chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(chooserIntent)
    }

    private fun shareFile(name: String?, mimeType: String?, file: ByteArray?) {
        if (name == null || mimeType == null || file == null) {
            return
        }
        
        val xfile = File(context.cacheDir, name)
        xfile.createNewFile()
        FileOutputStream(xfile).use { it.write(file) }
    
        val fileUri = FileProvider.getUriForFile(
            context, 
            "${context.packageName}.fileprovider", 
            xfile
        )
    
        val intent = Intent(ACTION_SEND).apply {
            type = mimeType
            putExtra(EXTRA_TITLE, name)
            putExtra(EXTRA_STREAM, fileUri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        
        Intent.createChooser(intent, "Share")
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            .let { context.startActivity(it) }
    }
}
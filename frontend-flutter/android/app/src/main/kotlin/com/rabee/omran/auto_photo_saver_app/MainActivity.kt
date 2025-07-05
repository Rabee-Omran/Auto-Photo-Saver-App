package com.rabee.omran.auto_photo_saver_app

import android.content.Context
import android.net.*
import android.os.Build
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.Manifest
import android.app.Activity
import android.content.ContentValues
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import java.io.*
import java.net.HttpURLConnection
import java.net.URL

/**
 * MainActivity handles network connectivity monitoring and image saving to gallery
 * Provides Flutter method channels for network status and gallery operations
 */
class MainActivity: FlutterActivity() {
    // Method channel for network operations
    private val CHANNEL = "com.rabee.omran.network"
    // Event channel for network status updates
    private val EVENT_CHANNEL = "com.rabee.omran.network/events"
    private var eventSink: EventChannel.EventSink? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    // Method channel for gallery save operations
    private val GALLERY_CHANNEL = "com.rabee.omran.gallery"
    private val REQUEST_WRITE_EXTERNAL_STORAGE = 1001

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Set up network method channel
        MethodChannel(requireNotNull(flutterEngine?.dartExecutor?.binaryMessenger), CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getNetworkType") {
                result.success(getNetworkType())
            } else {
                result.notImplemented()
            }
        }

        // Set up network event channel for real-time updates
        EventChannel(requireNotNull(flutterEngine?.dartExecutor?.binaryMessenger), EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    registerNetworkCallback()
                    // Emit initial network state
                    eventSink?.success(getNetworkType())
                }

                override fun onCancel(arguments: Any?) {
                    unregisterNetworkCallback()
                    eventSink = null
                }
            }
        )

        // Set up gallery save method channel
        MethodChannel(requireNotNull(flutterEngine?.dartExecutor?.binaryMessenger), GALLERY_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveImageToGallery") {
                val url = call.argument<String>("url")
                val fileName = call.argument<String>("fileName")
                if (url != null && fileName != null) {
                    saveImageToGallery(url, fileName, result)
                } else {
                    result.error("INVALID_ARGUMENTS", "URL or fileName missing", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    /**
     * Get current network connection type (wifi, mobile, ethernet, or offline)
     */
    private fun getNetworkType(): String {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            cm.activeNetwork
        } else {
            // Fallback for older Android versions
            @Suppress("DEPRECATION")
            return when (cm.activeNetworkInfo?.type) {
                ConnectivityManager.TYPE_WIFI -> "wifi"
                ConnectivityManager.TYPE_ETHERNET -> "ethernet"
                ConnectivityManager.TYPE_MOBILE -> "mobile"
                else -> "offline"
            }
        }
        if (network == null) return "offline"
        val capabilities = cm.getNetworkCapabilities(network) ?: return "offline"
        return when {
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "wifi"
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> "ethernet"
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "mobile"
            else -> "offline"
        }
    }

    /**
     * Register network callback to monitor connectivity changes
     */
    private fun registerNetworkCallback() {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        if (networkCallback != null) return
        networkCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                runOnUiThread { eventSink?.success(getNetworkType()) }
            }
            override fun onLost(network: Network) {
                runOnUiThread { eventSink?.success(getNetworkType()) }
            }
            override fun onCapabilitiesChanged(network: Network, networkCapabilities: NetworkCapabilities) {
                runOnUiThread { eventSink?.success(getNetworkType()) }
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            cm.registerDefaultNetworkCallback(networkCallback!!)
        } else {
            val request = NetworkRequest.Builder().build()
            cm.registerNetworkCallback(request, networkCallback!!)
        }
    }

    /**
     * Unregister network callback to prevent memory leaks
     */
    private fun unregisterNetworkCallback() {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        if (networkCallback != null) {
            cm.unregisterNetworkCallback(networkCallback!!)
            networkCallback = null
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterNetworkCallback()
    }

    /**
     * Save image from URL to device gallery
     * Handles permissions and downloads image in background thread
     */
    private fun saveImageToGallery(url: String, fileName: String, result: MethodChannel.Result) {
        // Check storage permission for Android < 13
        if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE), REQUEST_WRITE_EXTERNAL_STORAGE)
                result.error("PERMISSION_DENIED", "Storage permission denied", null)
                return
            }
        }
        // Download and save image in background thread
        Thread {
            try {
                val bitmap = downloadBitmap(url)
                if (bitmap == null) {
                    runOnUiThread { result.error("DOWNLOAD_FAILED", "Failed to download image", null) }
                    return@Thread
                }
                val saved = saveBitmapToGallery(bitmap, fileName)
                runOnUiThread { result.success(saved) }
            } catch (e: Exception) {
                runOnUiThread { result.error("SAVE_FAILED", e.message, null) }
            }
        }.start()
    }

    /**
     * Download bitmap from URL
     */
    private fun downloadBitmap(urlStr: String): Bitmap? {
        return try {
            val url = URL(urlStr)
            val connection = url.openConnection() as HttpURLConnection
            connection.doInput = true
            connection.connect()
            val input = connection.inputStream
            BitmapFactory.decodeStream(input)
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Save bitmap to device gallery
     * Uses MediaStore API for Android 10+ and file system for older versions
     */
    private fun saveBitmapToGallery(bitmap: Bitmap, fileName: String): Boolean {
        val fos: OutputStream?
        try {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                // Use MediaStore API for Android 10+
                val resolver = contentResolver
                val contentValues = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                    put(MediaStore.MediaColumns.MIME_TYPE, "image/png")
                    put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_PICTURES)
                }
                val imageUri: Uri? = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
                fos = imageUri?.let { resolver.openOutputStream(it) }
            } else {
                // Use file system for older Android versions
                val imagesDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
                val image = File(imagesDir, fileName)
                fos = FileOutputStream(image)
            }
            fos?.use {
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, it)
            }
            return true
        } catch (e: Exception) {
            Log.e("GallerySaver", "Error saving image: ${e.message}")
            return false
        }
    }
}
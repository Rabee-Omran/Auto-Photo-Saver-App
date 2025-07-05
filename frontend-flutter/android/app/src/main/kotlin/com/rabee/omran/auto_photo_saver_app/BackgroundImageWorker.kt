package com.rabee.omran.auto_photo_saver_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ContentValues
import android.content.Context
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.work.Worker
import androidx.work.WorkerParameters
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStream
import java.net.HttpURLConnection
import java.net.URL

/**
 * Background worker for downloading and saving images to gallery
 * Handles image downloads in background thread with notifications
 */
class BackgroundImageWorker(
    private val context: Context,
    workerParams: WorkerParameters
) : Worker(context, workerParams) {

    companion object {
        // Notification channel and ID for background processing updates
        private const val NOTIFICATION_CHANNEL_ID = "auto_photo_saver_channel"
        private const val NOTIFICATION_ID = 1001
    }

    /**
     * Main work method - downloads image from URL and saves to gallery
     */
    override fun doWork(): androidx.work.ListenableWorker.Result {
        val imageUrl = inputData.getString("url")
        val fileName = inputData.getString("fileName")

        // Validate input parameters
        if (imageUrl.isNullOrEmpty() || fileName.isNullOrEmpty()) {
            Log.e("BackgroundImageWorker", "Missing URL or fileName")
            return androidx.work.ListenableWorker.Result.failure()
        }

        try {
            Log.d("BackgroundImageWorker", "Starting background download: $imageUrl")
            Log.d("BackgroundImageWorker", "File name: $fileName")
            
            // Download and save image
            val bitmap = downloadBitmap(imageUrl)
            if (bitmap != null) {
                val success = saveBitmapToGallery(bitmap, fileName)
                if (success) {
                    Log.d("BackgroundImageWorker", "Image saved successfully to gallery: $fileName")
                    showNotification("Image Saved", "New photo saved to gallery: $fileName")
                    return androidx.work.ListenableWorker.Result.success()
                } else {
                    Log.e("BackgroundImageWorker", "Failed to save image to gallery: $fileName")
                    showNotification("Save Failed", "Failed to save image to gallery")
                    return androidx.work.ListenableWorker.Result.failure()
                }
            } else {
                Log.e("BackgroundImageWorker", "Failed to download bitmap from: $imageUrl")
                showNotification("Download Failed", "Failed to download image")
                return androidx.work.ListenableWorker.Result.failure()
            }
        } catch (e: Exception) {
            Log.e("BackgroundImageWorker", "Error during background download: ${e.message}", e)
            showNotification("Error", "Error processing image: ${e.message}")
            return androidx.work.ListenableWorker.Result.failure()
        }
    }

    /**
     * Download bitmap from URL with timeout and error handling
     */
    private fun downloadBitmap(urlStr: String) =
        try {
            Log.d("BackgroundImageWorker", "Downloading from URL: $urlStr")
            val connection = URL(urlStr).openConnection() as HttpURLConnection
            connection.doInput = true
            // Set 30 second timeout for both connect and read operations
            connection.connectTimeout = 30000
            connection.readTimeout = 30000
            connection.connect()
            val input = connection.inputStream
            val bitmap = BitmapFactory.decodeStream(input)
            Log.d("BackgroundImageWorker", "Download completed, bitmap size: ${bitmap?.width}x${bitmap?.height}")
            bitmap
        } catch (e: Exception) {
            Log.e("BackgroundImageWorker", "Download error: ${e.message}", e)
            null
        }

    /**
     * Save bitmap to device gallery
     * Uses MediaStore API for Android 10+ and file system for older versions
     */
    private fun saveBitmapToGallery(bitmap: android.graphics.Bitmap, fileName: String): Boolean {
        val fos: OutputStream?
        return try {
            Log.d("BackgroundImageWorker", "Saving bitmap to gallery: $fileName")
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // Use MediaStore API for Android 10+
                val resolver = context.contentResolver
                val contentValues = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                    put(MediaStore.MediaColumns.MIME_TYPE, "image/png")
                    put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_PICTURES)
                }
                val uri: Uri? = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
                fos = uri?.let { resolver.openOutputStream(it) }
                Log.d("BackgroundImageWorker", "Using MediaStore API, URI: $uri")
            } else {
                // Use legacy file system API for older Android versions
                val dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
                val image = File(dir, fileName)
                fos = FileOutputStream(image)
                Log.d("BackgroundImageWorker", "Using legacy file API, path: ${image.absolutePath}")
            }

            // Compress and save bitmap
            fos?.use {
                bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, it)
            }
            Log.d("BackgroundImageWorker", "Image saved successfully to gallery")
            true
        } catch (e: Exception) {
            Log.e("BackgroundImageWorker", "Error saving image to gallery: ${e.message}", e)
            false
        }
    }

    /**
     * Show notification to user about background processing status
     * Creates notification channel for Android 8+ compatibility
     */
    private fun showNotification(title: String, message: String) {
        try {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            // Create notification channel for Android 8+
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    NOTIFICATION_CHANNEL_ID,
                    "Auto Photo Saver",
                    NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = "Background photo processing notifications"
                }
                notificationManager.createNotificationChannel(channel)
            }

            // Build and show notification
            val notification = NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID)
                .setContentTitle(title)
                .setContentText(message)
                .setSmallIcon(android.R.drawable.ic_menu_gallery)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setAutoCancel(true)
                .build()

            notificationManager.notify(NOTIFICATION_ID, notification)
            Log.d("BackgroundImageWorker", "Notification shown: $title - $message")
        } catch (e: Exception) {
            Log.e("BackgroundImageWorker", "Failed to show notification: ${e.message}", e)
        }
    }
} 
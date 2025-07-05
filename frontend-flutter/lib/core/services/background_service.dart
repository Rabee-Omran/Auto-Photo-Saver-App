import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:dio/dio.dart';
import '../../features/photo/data/datasources/photo_remote_data_source.dart';
import 'shared_prefs_service.dart';
import '../../core/utils/gallery_saver_utils.dart';

const fetchTaskName = 'fetchLatestPhotoTask';

// Top-level function for background task - must be outside any class
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == fetchTaskName) {
      try {
        // Initialize SharedPrefsService
        final prefs = SharedPrefsService();
        await prefs.init();
        SharedPrefsService.setInstance(prefs);

        final dio = Dio();
        final remoteDataSource = PhotoRemoteDataSourceImpl(dio);

        final lastId = prefs.lastPhotoId;

        final model = await remoteDataSource.getLatestPhoto();

        if (lastId != model.id) {
          // Schedule native Android worker for background image download
          if (Platform.isAndroid) {
            await Workmanager().registerOneOffTask(
              'image_download_${DateTime.now().millisecondsSinceEpoch}',
              'downloadImageTask',
              inputData: {
                'url': model.image,
                'fileName': model.originalFileName,
              },
              constraints: Constraints(
                networkType: NetworkType.connected,
                requiresBatteryNotLow: false,
                requiresCharging: false,
                requiresDeviceIdle: false,
                requiresStorageNotLow: false,
              ),
            );
          } else if (Platform.isIOS) {
            // On iOS, download and save the image directly
            try {
              await GallerySaverUtils.saveImageToGallery(
                model.image,
                model.originalFileName,
              );
            } catch (e) {
              debugPrint('BackgroundService: Failed to save image on iOS: $e');
            }
          }

          // Update preferences with new photo info
          await prefs.setLastDownloadDate(DateTime.now());
          await prefs.setLastPhotoId(model.id);
          await prefs.setLastPhotoPath(model.image);
          await prefs.setLastPhotoFileName(model.originalFileName);
          await prefs.setLastPhotoUploadedAt(
            model.uploadedAt.toIso8601String(),
          );
          await prefs.setLastPhotoFileSize(model.fileSize);
        }
      } catch (e) {
        debugPrint('BackgroundService: Error: $e');
      }
    }

    return Future.value(true);
  });
}

class BackgroundService {
  final SharedPrefsService sharedPrefsService;

  BackgroundService(this.sharedPrefsService);

  static Future<void> initialize() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      // Initialize WorkManager
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

      // Cancel any existing tasks
      await Workmanager().cancelAll();

      // Register periodic task
      await Workmanager().registerPeriodicTask(
        '1',
        fetchTaskName,
        frequency: const Duration(minutes: 15),
        initialDelay: const Duration(seconds: 10),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(minutes: 5),
      );
    } catch (e) {
      debugPrint('BackgroundService: Failed to initialize: $e');
    }
  }

  static Future<void> startService() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      await initialize();
    } catch (e) {
      debugPrint('BackgroundService: Failed to start service: $e');
    }
  }

  static Future<void> stopService() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      await Workmanager().cancelAll();
    } catch (e) {
      debugPrint('BackgroundService: Failed to stop service: $e');
    }
  }

  static Future<bool> isRunning() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return false;

    try {
      // Check if any tasks are registered
      // Note: WorkManager doesn't provide a direct way to check if tasks are running
      // We'll use a simple approach by checking if the service is enabled in preferences
      final prefs = SharedPrefsService();
      await prefs.init();
      return prefs.backgroundFetchEnabled;
    } catch (e) {
      debugPrint('BackgroundService: Failed to check running status: $e');
      return false;
    }
  }

  static Future<void> fetchLatestPhoto() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      // Trigger a one-time task immediately
      await Workmanager().registerOneOffTask(
        'manual_fetch_${DateTime.now().millisecondsSinceEpoch}',
        fetchTaskName,
        constraints: Constraints(
          networkType: NetworkType.unmetered,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
    } catch (e) {
      debugPrint('BackgroundService: Failed to trigger manual fetch: $e');
    }
  }
}

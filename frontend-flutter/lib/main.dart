import 'package:flutter/material.dart';
import 'app.dart';
import 'di/di.dart';
import 'core/services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();

  // Initialize background service
  await BackgroundService.initialize();

  runApp(const AutoPhotoSaverApp());
}

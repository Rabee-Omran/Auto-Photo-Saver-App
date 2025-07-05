// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class GallerySaverUtils {
  static const MethodChannel _channel = MethodChannel(
    'com.rabee.omran.gallery',
  );

  static Future<bool> saveImageToGallery(String url, String fileName) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final result = await _channel.invokeMethod('saveImageToGallery', {
        'url': url,
        'fileName': fileName,
      });
      return result == true;
    } else {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = response.bodyBytes;
          await FileSaver.instance.saveFile(name: fileName, bytes: data);
          return true;
        } else {
          debugPrint('Failed to download file: ${response.statusCode}');
          return false;
        }
      } catch (e) {
        debugPrint(e.toString());
        return false;
      }
    }
  }
}

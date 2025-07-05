import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static SharedPrefsService? _instance;
  static SharedPrefsService get instance => _instance!;

  SharedPreferences? _prefs;

  SharedPrefsService();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Language
  Future<void> setLanguage(String? lang) async {
    if (lang == null) {
      await _prefs?.remove('settings_language');
    } else {
      await _prefs?.setString('settings_language', lang);
    }
  }

  String? get language => _prefs?.getString('settings_language');

  // Theme
  Future<void> setTheme(String? theme) async {
    if (theme == null) {
      await _prefs?.remove('settings_theme');
    } else {
      await _prefs?.setString('settings_theme', theme);
    }
  }

  String? get theme => _prefs?.getString('settings_theme');

  // Background Fetch
  Future<void> setBackgroundFetchEnabled(bool enabled) async {
    await _prefs?.setInt('settings_background_fetch', enabled ? 1 : 0);
  }

  bool get backgroundFetchEnabled =>
      (_prefs?.getInt('settings_background_fetch') ?? 1) == 1;

  // Photo data
  Future<void> setLastPhotoId(int id) async =>
      await _prefs?.setInt('last_photo_id', id);
  int? get lastPhotoId => _prefs?.getInt('last_photo_id');

  Future<void> setLastPhotoPath(String path) async =>
      await _prefs?.setString('last_photo_path', path);
  String? get lastPhotoPath => _prefs?.getString('last_photo_path');

  Future<void> setLastPhotoFileName(String fileName) async =>
      await _prefs?.setString('last_photo_file_name', fileName);
  String? get lastPhotoFileName => _prefs?.getString('last_photo_file_name');

  Future<void> setLastPhotoUploadedAt(String uploadedAt) async =>
      await _prefs?.setString('last_photo_uploaded_at', uploadedAt);
  String? get lastPhotoUploadedAt =>
      _prefs?.getString('last_photo_uploaded_at');

  Future<void> setLastPhotoFileSize(int fileSize) async =>
      await _prefs?.setInt('last_photo_file_size', fileSize);
  int? get lastPhotoFileSize => _prefs?.getInt('last_photo_file_size');

  Future<void> setLastDownloadDate(DateTime date) async =>
      await _prefs?.setString('last_download_date', date.toIso8601String());
  DateTime? get lastDownloadDate {
    final str = _prefs?.getString('last_download_date');
    return str != null ? DateTime.tryParse(str) : null;
  }

  static void setInstance(SharedPrefsService service) {
    _instance = service;
  }
}

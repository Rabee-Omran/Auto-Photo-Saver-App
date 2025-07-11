import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

class AppStrings {
  static AppStrings of(BuildContext context) => AppStrings._(context);
  final BuildContext context;
  AppStrings._(this.context);

  String get appTitle => AppLocalizations.of(context).translate('app_title');
  String get latestDownload =>
      AppLocalizations.of(context).translate('latest_download');
  String get networkStatus =>
      AppLocalizations.of(context).translate('network_status');
  String get offline => AppLocalizations.of(context).translate('offline');
  String get mobileData =>
      AppLocalizations.of(context).translate('mobile_data');
  String get wifiEthernet =>
      AppLocalizations.of(context).translate('wifi_ethernet');
  String get noImage => AppLocalizations.of(context).translate('no_image');
  String get error => AppLocalizations.of(context).translate('error');
  String get settings => AppLocalizations.of(context).translate('settings');
  String get theme => AppLocalizations.of(context).translate('theme');
  String get themeSystem =>
      AppLocalizations.of(context).translate('theme_system');
  String get themeLight =>
      AppLocalizations.of(context).translate('theme_light');
  String get themeDark => AppLocalizations.of(context).translate('theme_dark');
  String get language => AppLocalizations.of(context).translate('language');
  String get backgroundFetch =>
      AppLocalizations.of(context).translate('background_fetch');
  String get languageEnglish =>
      AppLocalizations.of(context).translate('language_english');
  String get languageArabic =>
      AppLocalizations.of(context).translate('language_arabic');
  String get languageGerman =>
      AppLocalizations.of(context).translate('language_german');
  String get errorNoInternet =>
      AppLocalizations.of(context).translate('error_no_internet');
  String get errorServer =>
      AppLocalizations.of(context).translate('error_server');
  String get errorUnknown =>
      AppLocalizations.of(context).translate('error_unknown');
  String get sizeBytes => AppLocalizations.of(context).translate('size_bytes');
  String get sizeKilobytes =>
      AppLocalizations.of(context).translate('size_kilobytes');
  String get sizeMegabytes =>
      AppLocalizations.of(context).translate('size_megabytes');
  String get sizeGigabytes =>
      AppLocalizations.of(context).translate('size_gigabytes');
  String get retry => AppLocalizations.of(context).translate('retry');
  String get latestUpload =>
      AppLocalizations.of(context).translate('latest_upload');
  String get imageSavedToDownloads =>
      AppLocalizations.of(context).translate('image_saved_to_downloads');
  String get somethingWentWrong =>
      AppLocalizations.of(context).translate('something_went_wrong');
  String get imageSavedToGallery =>
      AppLocalizations.of(context).translate('image_saved_to_gallery');
  String get realTimeInfo =>
      AppLocalizations.of(context).translate('real_time_info');
}

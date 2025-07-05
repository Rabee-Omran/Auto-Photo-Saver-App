import 'package:flutter/widgets.dart';
import '../localization/app_strings.dart';
import '../localization/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppStrings get l10n => AppStrings.of(this);

  String tryTranslate(String key) {
    final str = AppLocalizations.of(this).translate(key);
    return (str == key || str.isEmpty) ? key : str;
  }
}

import 'package:auto_photo_saver_app/core/extensions/localization_extension.dart';
import 'package:flutter/material.dart';
import '../widgets/background_fetch_section.dart';
import '../widgets/language_section.dart';
import '../widgets/theme_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: ListView(
        children: [
          const ThemeSection(),
          const LanguageSection(),
          BackgroundFetchSection(),
        ],
      ),
    );
  }
}
